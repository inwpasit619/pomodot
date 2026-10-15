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

    // AppKit would push the panel's transparent edges out from under the menu bar, moving
    // the capsule away from where Core put it. Leave it be while the capsule is on a screen;
    // otherwise (its display went away, say) let AppKit bring it back.
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        let capsule = FloatingWindowController.capsuleFrame(inside: frameRect)
        if NSScreen.screens.contains(where: { $0.visibleFrame.contains(capsule) }) {
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
    /// The pointer is on the capsule: it widens a little, to say it can be clicked.
    var isHovered = false
    /// The glass box inside the panel, in `FloatingView.coordinateSpaceName`: the capsule,
    /// or the card while open. Changing it animates the box between the two.
    var boxFrame: CGRect = .zero
    /// Which corner or edge the card grows from; kept after closing so the card shrinks back into it.
    var cardLayout: CardLayout?
    /// Where the card's buttons are, in `FloatingView.coordinateSpaceName`. A press on one never drags.
    @ObservationIgnored var buttonFrames: [CGRect] = []
}

/// Owns the Floating Window: shows, hides and floats it, and opens it into the card
/// when Core's rules say so. The panel never changes size: it is centred on the capsule
/// with room for the card to grow any way, plus `margin` for the bounce and the shadow.
/// Resizing a window during the animation would show a frame of the old layout in the
/// new size, so only the SwiftUI box grows and shrinks.
@MainActor
final class FloatingWindowController {
    static let margin: CGFloat = 16
    /// The open and close animation: a spring with no bounce.
    static let resize = Animation.smooth(duration: 0.35)
    /// Widening on hover: quicker, with a little bounce, like the Dynamic Island.
    private static let hover = Animation.spring(duration: 0.3, bounce: 0.3)
    /// How much wider and taller the capsule gets on hover.
    private static let hoverGrowth = CGSize(width: 12, height: 4)
    /// How far past the capsule the panel reaches on every side.
    private static let reach = CGSize(
        width: FloatingWindowPlacement.cardSize.width - FloatingWindowPlacement.capsuleSize.width + margin,
        height: FloatingWindowPlacement.cardSize.height - FloatingWindowPlacement.capsuleSize.height + margin
    )

    private let model: AppModel
    private let panel: FloatingPanel
    private let hosting: NSView
    private let display = FloatingWindowDisplay()
    private var expansion: FloatingWindowExpansion
    private let content: PointerTrackingView
    private var checkTimer: Timer?
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
            contentRect: Self.panelFrame(around: expansion.capsuleFrame),
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
        let content = PointerTrackingView()
        let hosting = FirstClickHostingView(rootView: FloatingView(model: model, display: display))
        // The panel's size comes from Core's frames, never from the SwiftUI content.
        hosting.sizingOptions = []
        hosting.frame = content.bounds
        hosting.autoresizingMask = [.width, .height]
        content.addSubview(hosting)
        panel.contentView = content
        self.hosting = hosting
        self.content = content
        showGlass(animation: nil)

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

    /// The panel around a capsule: centred on it, with room for the card on every side.
    private static func panelFrame(around capsule: CGRect) -> CGRect {
        capsule.insetBy(dx: -reach.width, dy: -reach.height)
    }

    /// The capsule at the centre of a panel frame.
    static func capsuleFrame(inside panelFrame: CGRect) -> CGRect {
        panelFrame.insetBy(dx: reach.width, dy: reach.height)
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
            // Only the glass counts, not the transparent space around it.
            guard glassFrame.contains(point) else { return }
            expansion.pressed(at: point, onButton: isOnButton(event))
        case .leftMouseDragged:
            // The screen under the pointer, so the capsule can be dragged onto another display.
            expansion.dragged(to: point, visibleFrame: usableArea(at: point))
            panel.setFrameOrigin(Self.panelFrame(around: expansion.capsuleFrame).origin)
        default:
            expansion.released(at: point, visibleFrame: screenArea)
        }
        update()
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
        expansion.check(at: Date())
        update()
    }

    /// Enter and exit events can arrive late or out of order when the pointer jumps, and go
    /// missing when the tracked area changes under it, so trust where the pointer really is.
    /// - Returns: whether it was somewhere else than the events said.
    @discardableResult
    private func syncPointer() -> Bool {
        // A hidden window has no pointer over it.
        guard panel.isVisible else { return false }
        let inside = glassFrame.contains(NSEvent.mouseLocation)
        guard inside != pointerIsInside else { return false }
        pointerMoved(inside: inside)
        return true
    }

    /// macOS moved the capsule itself, for example off a display that went away.
    private func panelMoved() {
        // Drags set the frame from Core already.
        guard !expansion.isPressed else { return }
        expansion.moveCapsule(to: Self.capsuleFrame(inside: panel.frame))
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

        if expansion.isExpanded != display.isExpanded {
            showGlass(animation: animated ? Self.resize : nil)
        } else if isHovered != display.isHovered {
            showGlass(animation: animated ? Self.hover : nil)
        }
    }

    private var isHovered: Bool { pointerIsInside && !expansion.isExpanded }

    /// The glass on screen: the card while open, else the capsule, a little wider on hover.
    /// Leaving is judged against the wider capsule, so its edge doesn't flicker.
    private var glassFrame: CGRect {
        guard !expansion.isExpanded, display.isHovered else { return expansion.frame }
        return expansion.capsuleFrame.insetBy(dx: -Self.hoverGrowth.width / 2, dy: -Self.hoverGrowth.height / 2)
    }

    private static var reduceMotion: Bool {
        NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
    }

    /// Grows the glass box from the capsule into the card, or shrinks it back, as Core says,
    /// and widens the capsule while the pointer is on it.
    private func showGlass(animation: Animation?) {
        if let cardLayout = expansion.cardLayout {
            // Set before the animation, so the card grows from the right corner.
            display.cardLayout = cardLayout
        }
        withAnimation(Self.reduceMotion ? nil : animation) {
            display.isExpanded = expansion.isExpanded
            display.isHovered = isHovered
            display.boxFrame = boxFrame(of: glassFrame)
        }
        content.trackingRect = content.convert(display.boxFrame, from: hosting)
        syncPointer()
    }

    /// `frame` (screen coordinates) inside the panel, measured from its top-left as SwiftUI does.
    /// The panel is always where Core's capsule says, even while macOS is still moving it.
    private func boxFrame(of frame: CGRect) -> CGRect {
        let panelFrame = Self.panelFrame(around: expansion.capsuleFrame)
        return CGRect(
            x: frame.minX - panelFrame.minX,
            y: panelFrame.maxY - frame.maxY,
            width: frame.width,
            height: frame.height
        )
    }
}

/// The panel's content: reports the pointer entering and leaving the visible capsule
/// or card (not the transparent space around it), even while another app is active.
final class PointerTrackingView: NSView {
    var onPointerChange: ((Bool) -> Void)?
    /// The capsule or card, in this view's coordinates.
    var trackingRect: CGRect = .zero {
        didSet { updateTrackingAreas() }
    }
    private var trackingArea: NSTrackingArea?

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea {
            removeTrackingArea(trackingArea)
        }
        let area = NSTrackingArea(
            rect: trackingRect,
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
