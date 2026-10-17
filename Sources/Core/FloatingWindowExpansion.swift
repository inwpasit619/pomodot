import CoreGraphics
import Foundation

/// When the Floating Window opens into the card and closes back into the capsule.
/// A click opens it; resting the pointer on the capsule doesn't.
/// It owns no timer: it says when it next needs a `check`, and the caller brings `now`.
public struct FloatingWindowExpansion: Sendable {
    /// How long the pointer must stay away from the card before it closes.
    static let awayBeforeCollapsing: TimeInterval = 0.5
    /// How far the pointer may move between press and release and still be a click.
    static let clickTolerance: CGFloat = 3

    public private(set) var capsuleFrame: CGRect
    /// Chosen as the card opens and kept until it closes; nil while collapsed.
    public private(set) var cardLayout: CardLayout?

    private var pointerExitedAt: Date?
    private var press: Press?
    /// The card's menu is open: the pointer is on the menu's items, perhaps outside the card.
    private var isMenuOpen = false

    /// A mouse press on the Floating Window, kept until the button comes up.
    private struct Press {
        let point: CGPoint
        /// Where the capsule was when the press began; a drag moves it from here.
        let capsuleFrame: CGRect
        /// Set once the pointer has moved more than `clickTolerance`, even if it comes back.
        var isDrag = false

        func isBeyondClick(_ other: CGPoint) -> Bool {
            hypot(other.x - point.x, other.y - point.y) > FloatingWindowExpansion.clickTolerance
        }
    }

    public init(capsuleFrame: CGRect) {
        self.capsuleFrame = capsuleFrame
    }

    public var isExpanded: Bool { cardLayout != nil }

    /// When the caller should next call `check`; nil while nothing is pending.
    public var nextCheck: Date? {
        // Nothing closes while the button is down or the menu is open;
        // `released` or `menuClosed` says what happens next.
        guard press == nil, !isMenuOpen, isExpanded else { return nil }
        return pointerExitedAt?.addingTimeInterval(Self.awayBeforeCollapsing)
    }

    /// Where the window is: the card while open, otherwise the capsule.
    public var frame: CGRect {
        cardLayout?.cardFrame(around: capsuleFrame) ?? capsuleFrame
    }

    public mutating func pointerEntered() {
        pointerExitedAt = nil
    }

    public mutating func pointerExited(at now: Date) {
        pointerExitedAt = now
    }

    /// Between a press that can drag and its release.
    public var isPressed: Bool { press != nil }

    /// The mouse button went down at `point` (screen coordinates). A press on one of
    /// the card's buttons belongs to the button: it never drags or opens anything.
    public mutating func pressed(at point: CGPoint, onButton: Bool = false) {
        guard !onButton else { return }
        press = Press(point: point, capsuleFrame: capsuleFrame)
    }

    /// The mouse button came up at `point`. Moving no more than ~3 pt is a click,
    /// and a click opens the card at once; anything further was a drag.
    public mutating func released(at point: CGPoint, visibleFrame: CGRect) {
        defer { press = nil }
        guard let press, !press.isDrag, !press.isBeyondClick(point) else { return }
        expand(in: visibleFrame)
    }

    /// The pointer moved to `point` with the button down. Once it is more than ~3 pt
    /// from where it was pressed, this is a drag: the capsule (and the card, if open) follows the pointer,
    /// kept inside `visibleFrame`, the usable area of the screen the pointer is on.
    public mutating func dragged(to point: CGPoint, visibleFrame: CGRect) {
        guard var press, press.isDrag || press.isBeyondClick(point) else { return }
        press.isDrag = true
        self.press = press
        let moved = press.capsuleFrame.offsetBy(dx: point.x - press.point.x, dy: point.y - press.point.y)
        // Keep whatever is showing inside, the whole card while it is open.
        let shown = cardLayout?.cardFrame(around: moved) ?? moved
        let nudge = Self.nudge(keeping: shown, inside: visibleFrame)
        capsuleFrame = moved.offsetBy(dx: nudge.dx, dy: nudge.dy)
    }

    /// Applies whatever is due by `now`: closing the card once the pointer has been away long enough.
    public mutating func check(at now: Date) {
        guard press == nil, !isMenuOpen else { return }
        if let pointerExitedAt, now.timeIntervalSince(pointerExitedAt) >= Self.awayBeforeCollapsing {
            cardLayout = nil
            self.pointerExitedAt = nil
        }
    }

    /// The card's menu opened. Until it closes, nothing closes the card.
    public mutating func menuOpened() {
        isMenuOpen = true
    }

    /// The card's menu closed at `now`. If the pointer left the card meanwhile,
    /// the half second before closing starts counting now, not from when it left.
    public mutating func menuClosed(at now: Date) {
        isMenuOpen = false
        if pointerExitedAt != nil {
            pointerExitedAt = now
        }
    }

    /// Something other than a drag moved the capsule to `frame`, such as macOS
    /// bringing it back after its display went away.
    public mutating func moveCapsule(to frame: CGRect) {
        capsuleFrame = frame
    }

    /// The Floating Window was hidden; no exit arrives for a window that is gone.
    public mutating func hide() {
        cardLayout = nil
        pointerExitedAt = nil
        press = nil
    }

    /// How far to move `frame` so it sits inside `area`.
    private static func nudge(keeping frame: CGRect, inside area: CGRect) -> CGVector {
        func along(_ low: CGFloat, _ high: CGFloat, _ minimum: CGFloat, _ maximum: CGFloat) -> CGFloat {
            if high > maximum { return maximum - high }
            if low < minimum { return minimum - low }
            return 0
        }
        return CGVector(
            dx: along(frame.minX, frame.maxX, area.minX, area.maxX),
            dy: along(frame.minY, frame.maxY, area.minY, area.maxY)
        )
    }

    private mutating func expand(in visibleFrame: CGRect) {
        guard cardLayout == nil else { return }
        cardLayout = CardLayout(capsule: capsuleFrame, visibleFrame: visibleFrame)
        // A click means the pointer is on it, whatever an old exit said.
        pointerExitedAt = nil
    }
}
