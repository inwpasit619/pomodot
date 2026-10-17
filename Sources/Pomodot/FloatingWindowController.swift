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
    // the glass away from where Core put it. Leave it be while the card's place is on a screen.
    // Where the card itself is under the menu bar (it showed up after Core placed it, say), move
    // only as far as the card needs, so it still sits flush against the menu bar. With no screen
    // left under it (its display went away), let AppKit bring it back.
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        let margin = FloatingWindowController.margin
        let card = frameRect.insetBy(dx: margin, dy: margin)
        if NSScreen.screens.contains(where: { $0.usableFrame.contains(card) }) {
            return frameRect
        }
        guard let area = NSScreen.screens.first(where: { $0.frame.intersects(card) })?.usableFrame,
              card.width <= area.width, card.height <= area.height else {
            return super.constrainFrameRect(frameRect, to: screen)
        }
        return frameRect.offsetBy(
            dx: min(max(card.minX, area.minX), area.maxX - card.width) - card.minX,
            dy: min(max(card.minY, area.minY), area.maxY - card.height) - card.minY
        )
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
    /// Which middle, edge or corner of the card the capsule sits in, open or closed: where the
    /// card grows from and shrinks back into, and where the panel sits around the capsule.
    var cardLayout: CardLayout?
    /// Where the card's buttons are, in `FloatingView.coordinateSpaceName`. A press on one never drags.
    @ObservationIgnored var buttonFrames: [CGRect] = []
    /// Where the card's ellipsis button is, in `FloatingView.coordinateSpaceName`; its menu opens below it.
    @ObservationIgnored var moreButtonFrame: CGRect = .zero
    /// The ellipsis button was pressed.
    @ObservationIgnored var openMenu: (() -> Void)?
}

/// Owns the Floating Window: shows, hides and floats it, and opens it into the card
/// when Core's rules say so. The panel never changes size: it is the card's place, open
/// or closed, plus `margin` for the hover, the bounce and the shadow. Resizing a window
/// during the animation would show a frame of the old layout in the new size, so only
/// the SwiftUI box grows and shrinks. A panel any bigger would reach far into the next
/// display near its edge, and macOS pushes such a window back.
@MainActor
final class FloatingWindowController {
    /// Room around the card for the hover, the bounce and the shadow.
    static let margin: CGFloat = 16
    /// The open and close animation: a spring with no bounce.
    private static let openClose = Animation.smooth(duration: 0.35)
    /// Widening on hover: quicker, with a little bounce, like the Dynamic Island.
    private static let hover = Animation.spring(duration: 0.3, bounce: 0.3)
    /// How much wider and taller the capsule gets on hover.
    private static let hoverGrowth = CGSize(width: 12, height: 4)

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
        let visibleFrame = NSScreen.screens.first?.usableFrame ?? .zero
        let capsule = FloatingWindowPlacement.capsuleFrame(
            remembering: model.capsuleCenter,
            screens: NSScreen.screens.map(\.usableFrame),
            mainScreen: visibleFrame
        )
        expansion = FloatingWindowExpansion(capsuleFrame: capsule)
        let capsuleScreen = NSScreen.screens.first { $0.frame.contains(CGPoint(x: capsule.midX, y: capsule.midY)) }
        let layout = CardLayout(capsule: capsule, visibleFrame: capsuleScreen?.usableFrame ?? visibleFrame)
        panel = FloatingPanel(
            contentRect: Self.panelFrame(around: capsule, layout: layout),
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
        NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { _ in
            MainActor.assumeIsolated { MenuBars.refresh() }
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

    /// The panel around a capsule: the card's place for `layout`, plus the margin.
    private static func panelFrame(around capsule: CGRect, layout: CardLayout) -> CGRect {
        layout.cardFrame(around: capsule).insetBy(dx: -margin, dy: -margin)
    }

    /// Where the capsule sits in the card: Core's while the card is open, else where
    /// the card would grow from it. Once a drag of the card ends the two are the same,
    /// so opening and closing never move the panel.
    private var layout: CardLayout {
        expansion.cardLayout ?? CardLayout(capsule: expansion.capsuleFrame, visibleFrame: screenArea)
    }

    /// The panel where Core's capsule says, even while macOS is still moving it.
    private var panelFrame: CGRect {
        Self.panelFrame(around: expansion.capsuleFrame, layout: layout)
    }

    /// Moves the panel to Core's capsule. Where the capsule now sits differently in the card,
    /// the panel moves around the glass, which is drawn at its new place in the same screen update.
    private func followCapsule() {
        if layout != display.cardLayout {
            showGlass(animation: nil)
        } else {
            panel.setFrameOrigin(panelFrame.origin)
        }
    }

    // MARK: Pointer

    private func pointerMoved(inside: Bool) {
        // A release can go missing (Mission Control during a drag, say). Once the button
        // is really up, end the press, or the card could never open or close again.
        if expansion.isPressed, NSEvent.pressedMouseButtons & 1 == 0 {
            release(at: NSEvent.mouseLocation)
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
            MenuBars.refresh()
            capsuleAtPress = expansion.capsuleFrame
            expansion.pressed(at: point, onButton: isOnButton(event))
        case .leftMouseDragged:
            // The screen under the pointer, so the capsule can be dragged onto another display.
            expansion.dragged(to: point, visibleFrame: usableArea(at: point))
            followCapsule()
        default:
            release(at: point)
        }
        update()
    }

    /// Ends a press. Letting go of a dragged card can tuck the capsule into another edge or
    /// corner of it; the card and the panel stay where they were.
    private func release(at point: CGPoint) {
        expansion.released(at: point, visibleFrame: screenArea)
        // macOS keeps a window's glass from going under a menu bar, even on a display whose
        // usable area says it may; the move it held back during the drag reached no one.
        followPanel()
        // A click that opens the card is shown by `update`, with its animation.
        if expansion.isExpanded == display.isExpanded {
            followCapsule()
        }
        // Remembered once the drag ends, not on every step of it.
        if let capsuleAtPress, capsuleAtPress != expansion.capsuleFrame {
            rememberCapsule()
        }
        capsuleAtPress = nil
    }

    /// Saves the collapsed capsule's centre, even while the card is open: it is where
    /// the card shrinks into.
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
        followPanel()
    }

    /// Where macOS put the panel somewhere other than Core said, the capsule goes along.
    private func followPanel() {
        let expected = panelFrame
        let dx = panel.frame.minX - expected.minX
        let dy = panel.frame.minY - expected.minY
        // Half a point either way is AppKit rounding, not a move.
        guard abs(dx) > 0.5 || abs(dy) > 0.5 else { return }
        expansion.moveCapsule(to: expansion.capsuleFrame.offsetBy(dx: dx, dy: dy))
    }

    // MARK: The card's menu

    /// The menu for a right-click at the pointer, only over the glass, not the transparent space around it.
    private func contextMenu() -> NSMenu? {
        glassFrame.contains(NSEvent.mouseLocation) ? cardMenu.menu : nil
    }

    /// Opens the menu below the ellipsis button, or above it, where Core says.
    private func openMenuBelowMoreButton() {
        // Screen coordinates: SwiftUI measures from the panel's top-left.
        let panelFrame = self.panelFrame
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
        return screen?.usableFrame ?? .zero
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
    /// and widens the capsule while the pointer is on it. Moves the panel too, where the capsule
    /// now sits differently in the card: the glass is drawn at its place in the moved panel in the
    /// same screen update, or it would blink to one side for a frame.
    private func showGlass(animation: Animation?) {
        let panelFrame = self.panelFrame
        // Half a point either way is AppKit rounding, not a move.
        let moves = abs(panel.frame.minX - panelFrame.minX) > 0.5 || abs(panel.frame.minY - panelFrame.minY) > 0.5
        if moves {
            panel.disableScreenUpdatesUntilFlush()
        }
        // Set before the animation, so the card grows from the right place.
        display.cardLayout = layout
        withAnimation(Self.reduceMotion ? nil : animation) {
            display.isExpanded = expansion.isExpanded
            display.isHovered = looksHovered
            display.boxFrame = boxFrame(of: glassFrame)
        }
        if moves {
            hosting.layoutSubtreeIfNeeded()
            panel.setFrameOrigin(panelFrame.origin)
        }
        content.trackingRect = content.convert(display.boxFrame, from: hosting)
        syncPointer()
    }

    /// `frame` (screen coordinates) inside the panel, measured from its top-left as SwiftUI does.
    private func boxFrame(of frame: CGRect) -> CGRect {
        let panelFrame = self.panelFrame
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

/// The menu bars on screen, in AppKit's coordinates. Looked up when the app opens, when the
/// displays change and when a drag starts, not on every step of it.
@MainActor
enum MenuBars {
    private(set) static var frames: [CGRect] = find()

    static func refresh() {
        frames = find()
    }

    private static func find() -> [CGRect] {
        let level = Int(CGWindowLevelForKey(.mainMenuWindow))
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        // Window bounds measure from the top of the primary display, downwards.
        let top = NSScreen.screens.first?.frame.maxY ?? 0
        return windows.compactMap { window in
            guard window[kCGWindowLayer as String] as? Int == level,
                  let bounds = window[kCGWindowBounds as String] as? NSDictionary,
                  let frame = CGRect(dictionaryRepresentation: bounds) else { return nil }
            return CGRect(x: frame.minX, y: top - frame.maxY, width: frame.width, height: frame.height)
        }
    }
}

extension NSScreen {
    /// Where the Floating Window may go: `visibleFrame`, also without the menu bar on displays
    /// where `visibleFrame` keeps it (an external one, say). macOS keeps the glass from going
    /// under any menu bar, so Core must not put it there.
    @MainActor
    var usableFrame: CGRect {
        let area = visibleFrame
        guard let bar = MenuBars.frames.first(where: { $0.intersects(frame) && $0.minY < area.maxY }) else {
            return area
        }
        return CGRect(x: area.minX, y: area.minY, width: area.width, height: max(0, bar.minY - area.minY))
    }
}
