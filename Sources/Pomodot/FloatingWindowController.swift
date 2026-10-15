import AppKit
import Core
import SwiftUI

/// A borderless panel that floats over every app, full-screen ones included,
/// and never activates Pomodot when clicked.
final class FloatingPanel: NSPanel {
    /// Sees every mouse press and release before the content does.
    var onMouseEvent: ((NSEvent) -> Void)?

    // A borderless panel can't receive clicks on its buttons unless it can become key.
    override var canBecomeKey: Bool { true }

    override func sendEvent(_ event: NSEvent) {
        if event.type == .leftMouseDown || event.type == .leftMouseUp {
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
}

/// Owns the Floating Window: shows, hides and floats it, and opens it into the card
/// when Core's rules say so. The panel is larger than the capsule or card by `margin`
/// on every side, so the bounce and the shadow have room to draw.
@MainActor
final class FloatingWindowController {
    static let margin: CGFloat = 16
    /// The open and close animation.
    static let resizeDuration: TimeInterval = 0.35

    private let model: AppModel
    private let panel: FloatingPanel
    private let display = FloatingWindowDisplay()
    private var expansion: FloatingWindowExpansion
    private var checkTimer: Timer?
    private var pendingClose: Task<Void, Never>?
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
        // Simple drag for now; the real drag rules replace this in M2.
        panel.isMovableByWindowBackground = true

        let content = PointerTrackingView(margin: Self.margin)
        let hosting = FirstClickHostingView(rootView: FloatingView(model: model, display: display))
        // The panel's size comes from Core's frames, never from the SwiftUI content.
        hosting.sizingOptions = []
        hosting.frame = content.bounds
        hosting.autoresizingMask = [.width, .height]
        content.addSubview(hosting)
        panel.contentView = content

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
        pointerIsInside = inside
        if inside {
            expansion.pointerEntered(at: Date())
        } else {
            expansion.pointerExited(at: Date())
        }
        update()
    }

    private func mouse(_ event: NSEvent) {
        // Screen coordinates: a drag moves the panel along with the pointer.
        let point = NSEvent.mouseLocation
        if event.type == .leftMouseDown {
            expansion.pressed(at: point)
        } else {
            expansion.released(at: point, visibleFrame: screenArea)
        }
        update()
    }

    private func check() {
        // Enter and exit events can arrive late or out of order when the pointer jumps,
        // so trust where the pointer really is before acting on them.
        let inside = Self.contentFrame(inside: panel.frame).contains(NSEvent.mouseLocation)
        if inside != pointerIsInside {
            pointerMoved(inside: inside)
            return
        }
        expansion.check(at: Date(), visibleFrame: screenArea)
        update()
    }

    /// The panel was dragged while it was a capsule.
    private func panelMoved() {
        guard !display.isExpanded, display.cardLayout == nil else { return }
        expansion.moveCapsule(to: Self.contentFrame(inside: panel.frame))
    }

    /// The usable area of the screen the capsule is on.
    private var screenArea: CGRect {
        let center = CGPoint(x: expansion.capsuleFrame.midX, y: expansion.capsuleFrame.midY)
        let screen = NSScreen.screens.first { $0.frame.contains(center) } ?? NSScreen.screens.first
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

    private func open() {
        pendingClose?.cancel()
        pendingClose = nil
        // Grow the panel at once; the view then grows the card from the capsule's corner.
        display.cardLayout = expansion.cardLayout
        panel.setFrame(Self.panelFrame(around: expansion.frame), display: true)
        panel.isMovableByWindowBackground = false
        display.isExpanded = true
    }

    private func close(animated: Bool) {
        display.isExpanded = false
        let reduceMotion = NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        guard animated, !reduceMotion else {
            finishClosing()
            return
        }
        // Shrink the panel once the view has shrunk the card back into the capsule.
        pendingClose = Task { @MainActor [weak self] in
            try? await Task.sleep(for: .seconds(Self.resizeDuration))
            guard !Task.isCancelled else { return }
            self?.finishClosing()
        }
    }

    private func finishClosing() {
        pendingClose?.cancel()
        pendingClose = nil
        display.isExpanded = false
        display.cardLayout = nil
        panel.setFrame(Self.panelFrame(around: expansion.frame), display: true)
        panel.isMovableByWindowBackground = true
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
