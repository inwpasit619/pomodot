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
        // A Control-click opens the card's menu, which takes the release: if Core saw the
        // press, it would wait for a release that never comes.
        let opensMenu = event.type == .leftMouseDown && event.modifierFlags.contains(.control)
        if [.leftMouseDown, .leftMouseDragged, .leftMouseUp].contains(event.type), !opensMenu {
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
    /// Which middle, edge or corner the card grows from; kept after closing so the card shrinks back into it.
    var cardLayout: CardLayout?
    /// Where the card's buttons are, in `FloatingView.coordinateSpaceName`. A press on one never drags.
    @ObservationIgnored var buttonFrames: [CGRect] = []
    /// Where the card's ellipsis button is, in `FloatingView.coordinateSpaceName`; its menu opens below it.
    @ObservationIgnored var moreButtonFrame: CGRect = .zero
    /// The ellipsis button was pressed.
    @ObservationIgnored var openMenu: (() -> Void)?
}

/// Owns the Floating Window: shows, hides and floats it, and opens it into the card
/// when Core's rules say so. The panel never changes size: it is centred on the capsule
/// with room for the card to grow any way, plus `margin` for the bounce and the shadow.
/// Resizing a window during the animation would show a frame of the old layout in the
/// new size, so only the SwiftUI box grows and shrinks.
@MainActor
final class FloatingWindowController {
    /// Room around the card for the bounce and the shadow.
    private static let margin: CGFloat = 16
    /// The open and close animation: a spring with no bounce.
    private static let openClose = Animation.smooth(duration: 0.35)
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
    let cardMenu: CardMenuController
    private let panel: FloatingPanel
    private let hosting: NSView
    private let display = FloatingWindowDisplay()
    private var expansion: FloatingWindowExpansion
    private let content: PointerTrackingView
    private var checkTimer: Timer?
    private var pointerIsInside = false
    /// Where the capsule was when the mouse went down, to tell whether a drag moved it.
    private var capsuleAtPress: CGRect?

    init(model: AppModel, app: AppDelegate) {
        self.model = model
        cardMenu = CardMenuController(model: model, app: app)

        // The primary display (the one with the menu bar), not NSScreen.main:
        // .main follows the key window, and this app never activates.
        let visibleFrame = NSScreen.screens.first?.visibleFrame ?? .zero
        expansion = FloatingWindowExpansion(
            capsuleFrame: FloatingWindowPlacement.capsuleFrame(
                remembering: model.capsuleCenter,
                screens: NSScreen.screens.map(\.visibleFrame),
                mainScreen: visibleFrame
            )
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
        // ⌘H, Hide Pomodot and the Dock's Hide hide Settings and Statistics, never the capsule.
        panel.canHide = false
        // Pomodot is seldom active, and tooltips (More, Reset, Skip) only show for the active app otherwise.
        panel.allowsToolTipsWhenApplicationIsInactive = true
        // A click on the capsule must not take the keyboard from the app the user is typing in.
        panel.becomesKeyOnlyIfNeeded = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        // The view draws its own shadow inside the margin.
        panel.hasShadow = false
        let content = PointerTrackingView()
        let hosting = FirstClickHostingView(rootView: FloatingView(model: model, display: display))
        // The panel's size is fixed and its place follows Core, never the SwiftUI content.
        hosting.sizingOptions = []
        hosting.frame = content.bounds
        hosting.autoresizingMask = [.width, .height]
        content.addSubview(hosting)
        panel.contentView = content
        self.hosting = hosting
        self.content = content
        showGlass(animation: nil)

        content.onPointerChange = { [weak self] inside in self?.pointerMoved(inside: inside) }
        display.openMenu = { [weak self] in self?.openMenuBelowMoreButton() }
        // A right-click or Control-click anywhere on the glass, buttons included.
        hosting.menuProvider = { [weak self] in self?.contextMenu() }
        cardMenu.onOpen = { [weak self] in self?.menuOpened() }
        cardMenu.onClose = { [weak self] in self?.menuClosed() }
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
                // The pointer may already be on it, or have left while it was hidden.
                syncPointer()
            } else {
                panel.orderOut(nil)
                expansion.hide()
                // No exit arrives for a window that is gone.
                pointerIsInside = false
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
            expansion.pointerEntered()
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
            capsuleAtPress = expansion.capsuleFrame
            expansion.pressed(at: point, onButton: isOnButton(event))
        case .leftMouseDragged:
            // The screen under the pointer, so the capsule can be dragged onto another display.
            expansion.dragged(to: point, visibleFrame: usableArea(at: point))
            panel.setFrameOrigin(Self.panelFrame(around: expansion.capsuleFrame).origin)
        default:
            expansion.released(at: point, visibleFrame: screenArea)
            // Remembered once the drag ends, not on every step of it.
            if let capsuleAtPress, capsuleAtPress != expansion.capsuleFrame {
                rememberCapsule()
            }
            capsuleAtPress = nil
        }
        update()
    }

    /// Saves the collapsed capsule's centre, even while the card is open: the card grows
    /// from the capsule, which stays put.
    private func rememberCapsule() {
        model.capsuleCenter = CGPoint(x: expansion.capsuleFrame.midX, y: expansion.capsuleFrame.midY)
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
        // Not remembered: with the display plugged back in before the next launch,
        // the capsule goes back where it was dragged.
        expansion.moveCapsule(to: Self.capsuleFrame(inside: panel.frame))
    }

    // MARK: The card's menu

    /// The menu for a right-click at the pointer, only over the glass, not the transparent space around it.
    private func contextMenu() -> NSMenu? {
        glassFrame.contains(NSEvent.mouseLocation) ? cardMenu.menu : nil
    }

    /// Opens the menu below the ellipsis button, or above it, where Core says.
    private func openMenuBelowMoreButton() {
        // Screen coordinates: SwiftUI measures from the panel's top-left.
        let panelFrame = Self.panelFrame(around: expansion.capsuleFrame)
        let frame = display.moreButtonFrame
        let button = CGRect(
            x: panelFrame.minX + frame.minX,
            y: panelFrame.maxY - frame.maxY,
            width: frame.width,
            height: frame.height
        )
        // Filled now, only to measure it; AppKit asks for the items again as it opens.
        cardMenu.menu.items = cardMenu.items(for: .card)
        let corner = FloatingWindowPlacement.menuCorner(
            below: button,
            menuHeight: cardMenu.menu.size.height,
            in: usableArea(at: CGPoint(x: button.midX, y: button.midY))
        )
        // popUp doesn't return until the menu closes; let the button's click finish first.
        DispatchQueue.main.async { [cardMenu] in
            cardMenu.menu.popUp(positioning: nil, at: corner, in: nil)
        }
    }

    private func menuOpened() {
        expansion.menuOpened()
        update()
    }

    /// The pointer may have left, or come back, while the menu had it.
    private func menuClosed() {
        expansion.menuClosed(at: Date())
        syncPointer()
        update()
    }

    /// Opening Pomodot again while it runs: the Floating Window comes to the front,
    /// without activating the app.
    func bringToFront() {
        guard model.isFloatingWindowVisible else { return }
        panel.orderFrontRegardless()
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
        if expansion.isExpanded != display.isExpanded {
            showGlass(animation: animated ? Self.openClose : nil)
        } else if looksHovered != display.isHovered {
            showGlass(animation: animated ? Self.hover : nil)
        }

        checkTimer?.invalidate()
        checkTimer = nil
        // While the capsule looks hovered, look again now and then in case an exit went missing.
        if let nextCheck = expansion.nextCheck ?? (display.isHovered ? Date().addingTimeInterval(0.5) : nil) {
            let timer = Timer(fire: nextCheck, interval: 0, repeats: false) { [weak self] _ in
                MainActor.assumeIsolated { self?.check() }
            }
            RunLoop.main.add(timer, forMode: .common)
            checkTimer = timer
        }
    }

    /// Whether the capsule should look hovered: the pointer is on it and the card is closed.
    private var looksHovered: Bool { pointerIsInside && !expansion.isExpanded }

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
            // Set before the animation, so the card grows from the right place.
            display.cardLayout = cardLayout
        }
        withAnimation(Self.reduceMotion ? nil : animation) {
            display.isExpanded = expansion.isExpanded
            display.isHovered = looksHovered
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

/// Lets the first click on a card button act straight away, though the panel isn't key,
/// and opens the card's menu on a right-click or Control-click.
final class FirstClickHostingView<Content: View>: NSHostingView<Content> {
    var menuProvider: (() -> NSMenu?)?

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func menu(for event: NSEvent) -> NSMenu? {
        menuProvider?()
    }
}
