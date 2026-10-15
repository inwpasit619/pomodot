import AppKit
import Core
import SwiftUI

/// A borderless panel that floats over every app, full-screen ones included,
/// and never activates Pomodot when clicked.
final class FloatingPanel: NSPanel {
    /// Sees every mouse press, drag and release before the content does.
    var onMouseEvent: ((NSEvent) -> Void)?

    // A borderless panel can't receive clicks on its buttons unless it can become key.
    override var canBecomeKey: Bool { true }

    // AppKit would push the transparent margin out from under the menu bar, moving the
    // capsule away from where Core put it. Leave it be while the glass is on a screen;
    // otherwise (its display went away, say) let AppKit bring it back.
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        let glass = frameRect.insetBy(dx: FloatingWindowController.margin, dy: FloatingWindowController.margin)
        if NSScreen.screens.contains(where: { $0.visibleFrame.contains(glass) }) {
            return frameRect
        }
        return super.constrainFrameRect(frameRect, to: screen)
    }

    override func sendEvent(_ event: NSEvent) {
        if [.leftMouseDown, .leftMouseDragged, .leftMouseUp].contains(event.type) {
            onMouseEvent?(event)
        }
        super.sendEvent(event)
    }
}

/// What the Floating Window's view draws: capsule or card, and where the card grows.
@MainActor
@Observable
final class FloatingWindowDisplay {
    var isExpanded = false
    /// Kept through the closing animation so the capsule doesn't move while the card shrinks.
    var cardLayout: CardLayout?
    /// Where the card's buttons are, in `FloatingView.coordinateSpaceName`. A press on one never drags.
    @ObservationIgnored var buttonFrames: [CGRect] = []
}

/// Owns the Floating Window: shows, hides and floats it, and opens it into the card
/// when Core's rules say so. The panel is larger than the capsule or card by `margin`
/// on every side, so the bounce and the shadow have room to draw.
@MainActor
final class FloatingWindowController {
    static let margin: CGFloat = 16
    /// The open and close animation: a spring with no bounce.
    static let resize = Animation.smooth(duration: 0.35)

    private let model: AppModel
    private let panel: FloatingPanel
    private let hosting: NSView
    private let display = FloatingWindowDisplay()
    private var expansion: FloatingWindowExpansion
    private var checkTimer: Timer?
    /// Counts opens, so a close that finishes after the card opened again is ignored.
    private var openings = 0
    private var pointerIsInside = false

    init(model: AppModel) {
        self.model = model

        // The primary display (the one with the menu bar), not NSScreen.main:
        // .main follows the key window, and this app never activates.
        let visibleFrame = NSScreen.screens.first?.visibleFrame ?? .zero
        expansion = FloatingWindowExpansion(
            capsuleFrame: FloatingWindowPlacement.startingCapsuleFrame(in: visibleFrame)
        )
        panel = FloatingPanel(
            contentRect: Self.panelFrame(around: expansion.frame),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .canJoinAllApplications]
        // NSPanel defaults to true, which would hide it whenever Pomodot isn't active.
        panel.hidesOnDeactivate = false
        // A click on the capsule must not take the keyboard from the app the user is typing in.
        panel.becomesKeyOnlyIfNeeded = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        // The view draws its own shadow inside the margin.
        panel.hasShadow = false
        let content = PointerTrackingView(margin: Self.margin)
        let hosting = FirstClickHostingView(rootView: FloatingView(model: model, display: display))
        // The panel's size comes from Core's frames, never from the SwiftUI content.
        hosting.sizingOptions = []
        hosting.frame = content.bounds
        hosting.autoresizingMask = [.width, .height]
        content.addSubview(hosting)
        panel.contentView = content
        self.hosting = hosting

        content.onPointerChange = { [weak self] inside in self?.pointerMoved(inside: inside) }
        panel.onMouseEvent = { [weak self] event in self?.mouse(event) }
        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification, object: panel, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.panelMoved() }
        }

        apply()
    }

    /// Applies the model to the panel, then waits for the next change.
    private func apply() {
        withObservationTracking {
            panel.level = model.isAlwaysOnTop ? .floating : .normal
            if model.isFloatingWindowVisible {
                // Shows the panel without activating the app.
                panel.orderFrontRegardless()
            } else {
                panel.orderOut(nil)
                expansion.hide()
                update(animated: false)
            }
        } onChange: { [weak self] in
            // Called before the change lands, so read the new values on the next turn.
            Task { @MainActor in self?.apply() }
        }
    }

    /// The panel is the capsule or card plus the margin on every side.
    private static func panelFrame(around frame: CGRect) -> CGRect {
        frame.insetBy(dx: -margin, dy: -margin)
    }

    /// The capsule or card inside a panel frame.
    private static func contentFrame(inside panelFrame: CGRect) -> CGRect {
        panelFrame.insetBy(dx: margin, dy: margin)
    }

    // MARK: Pointer

    private func pointerMoved(inside: Bool) {
        // A release can go missing (Mission Control during a drag, say). Once the button
        // is really up, end the press, or the card could never open or close again.
        if expansion.isPressed, NSEvent.pressedMouseButtons & 1 == 0 {
            expansion.released(at: NSEvent.mouseLocation, visibleFrame: screenArea)
        }
        pointerIsInside = inside
        if inside {
            expansion.pointerEntered(at: Date())
        } else {
            expansion.pointerExited(at: Date())
        }
        update()
    }

    /// Pomodot's own drag: Core decides click or drag and keeps the window on screen.
    private func mouse(_ event: NSEvent) {
        // Screen coordinates: the panel moves along with the pointer, so window ones barely change.
        let point = NSEvent.mouseLocation
        switch event.type {
        case .leftMouseDown:
            // Only the glass counts, not the transparent margin around it.
            guard shownFrame.contains(point) else { return }
            expansion.pressed(at: point, onButton: isOnButton(event))
        case .leftMouseDragged:
            // The screen under the pointer, so the capsule can be dragged onto another display.
            expansion.dragged(to: point, visibleFrame: usableArea(at: point))
            panel.setFrame(Self.panelFrame(around: shownFrame), display: true)
        default:
            expansion.released(at: point, visibleFrame: screenArea)
        }
        update()
    }

    /// The capsule or card the view is drawing, including a card that is still closing.
    private var shownFrame: CGRect {
        display.cardLayout?.cardFrame(around: expansion.capsuleFrame) ?? expansion.capsuleFrame
    }

    private func isOnButton(_ event: NSEvent) -> Bool {
        var point = hosting.convert(event.locationInWindow, from: nil)
        // SwiftUI measures from the top-left.
        if !hosting.isFlipped {
            point.y = hosting.bounds.height - point.y
        }
        return display.buttonFrames.contains { $0.contains(point) }
    }

    private func check() {
        if syncPointer() { return }
        expansion.check(at: Date(), visibleFrame: screenArea)
        update()
    }

    /// Enter and exit events can arrive late or out of order when the pointer jumps, and go
    /// missing when the panel resizes under it, so trust where the pointer really is.
    /// - Returns: whether it was somewhere else than the events said.
    @discardableResult
    private func syncPointer() -> Bool {
        // A hidden window has no pointer over it.
        guard panel.isVisible else { return false }
        let inside = Self.contentFrame(inside: panel.frame).contains(NSEvent.mouseLocation)
        guard inside != pointerIsInside else { return false }
        pointerMoved(inside: inside)
        return true
    }

    /// macOS moved the capsule itself, for example off a display that went away.
    private func panelMoved() {
        // Drags and the card set the frame from Core already.
        guard !expansion.isPressed, !display.isExpanded, display.cardLayout == nil else { return }
        expansion.moveCapsule(to: Self.contentFrame(inside: panel.frame))
    }

    /// The usable area of the screen the capsule is on.
    private var screenArea: CGRect {
        usableArea(at: CGPoint(x: expansion.capsuleFrame.midX, y: expansion.capsuleFrame.midY))
    }

    /// The usable area of the screen at `point`, else of the capsule's screen, else of the main one.
    private func usableArea(at point: CGPoint) -> CGRect {
        let capsule = CGPoint(x: expansion.capsuleFrame.midX, y: expansion.capsuleFrame.midY)
        let screen = NSScreen.screens.first { $0.frame.contains(point) }
            ?? NSScreen.screens.first { $0.frame.contains(capsule) }
            ?? NSScreen.screens.first
        return screen?.visibleFrame ?? .zero
    }

    // MARK: Opening and closing

    /// Brings the panel and the view in line with Core, and asks to be woken for the next check.
    private func update(animated: Bool = true) {
        checkTimer?.invalidate()
        checkTimer = nil
        if let nextCheck = expansion.nextCheck {
            let timer = Timer(fire: nextCheck, interval: 0, repeats: false) { [weak self] _ in
                MainActor.assumeIsolated { self?.check() }
            }
            RunLoop.main.add(timer, forMode: .common)
            checkTimer = timer
        }

        if expansion.isExpanded, !display.isExpanded {
            open()
        } else if !expansion.isExpanded, display.isExpanded {
            close(animated: animated)
        } else if !expansion.isExpanded, display.cardLayout != nil, !animated {
            finishClosing()
        }
    }

    private static var reduceMotion: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    private func open() {
        openings += 1
        // Grow the panel at once; the view then grows the card from the capsule's corner.
        display.cardLayout = expansion.cardLayout
        panel.setFrame(Self.panelFrame(around: expansion.frame), display: true)
        withAnimation(Self.reduceMotion ? nil : Self.resize) {
            display.isExpanded = true
        }
    }

    private func close(animated: Bool) {
        guard animated, !Self.reduceMotion else {
            finishClosing()
            return
        }
        let opening = openings
        // Shrink the panel only once the spring has fully settled, so its tail isn't cut off.
        withAnimation(Self.resize, completionCriteria: .removed) {
            display.isExpanded = false
        } completion: { [weak self] in
            guard let self, self.openings == opening, !self.display.isExpanded else { return }
            self.finishClosing()
        }
    }

    private func finishClosing() {
        display.isExpanded = false
        display.cardLayout = nil
        panel.setFrame(Self.panelFrame(around: expansion.frame), display: true)
        syncPointer()
    }
}

/// The panel's content: reports the pointer entering and leaving the visible capsule
/// or card (not the transparent margin), even while another app is active.
final class PointerTrackingView: NSView {
    var onPointerChange: ((Bool) -> Void)?
    private let margin: CGFloat
    private var trackingArea: NSTrackingArea?

    init(margin: CGFloat) {
        self.margin = margin
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not used") }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        let area = NSTrackingArea(
            rect: bounds.insetBy(dx: margin, dy: margin),
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        onPointerChange?(true)
    }

    override func mouseExited(with event: NSEvent) {
        onPointerChange?(false)
    }
}

/// Lets the first click on a card button act straight away, though the panel isn't key.
final class FirstClickHostingView<Content: View>: NSHostingView<Content> {
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }
}
