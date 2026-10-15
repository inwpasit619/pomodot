import CoreGraphics
import Foundation

/// When the Floating Window opens into the card and closes back into the capsule.
/// It owns no timer: it says when it next needs a `check`, and the caller brings `now`.
public struct FloatingWindowExpansion: Sendable {
    /// How long the pointer must rest on the capsule before it opens.
    static let restBeforeExpanding: TimeInterval = 0.3
    /// How long the pointer must stay away from the card before it closes.
    static let awayBeforeCollapsing: TimeInterval = 0.5
    /// How far the pointer may move between press and release and still be a click.
    static let clickTolerance: CGFloat = 3

    public private(set) var capsuleFrame: CGRect
    /// Chosen as the card opens and kept until it closes; nil while collapsed.
    public private(set) var cardLayout: CardLayout?

    private var pointerEnteredAt: Date?
    private var pointerExitedAt: Date?
    private var pressedAt: CGPoint?

    public init(capsuleFrame: CGRect) {
        self.capsuleFrame = capsuleFrame
    }

    public var isExpanded: Bool { cardLayout != nil }

    /// When the caller should next call `check`; nil while nothing is pending.
    public var nextCheck: Date? {
        if isExpanded {
            pointerExitedAt?.addingTimeInterval(Self.awayBeforeCollapsing)
        } else {
            pointerEnteredAt?.addingTimeInterval(Self.restBeforeExpanding)
        }
    }

    /// Where the window is: the card while open, otherwise the capsule.
    public var frame: CGRect {
        cardLayout?.cardFrame(around: capsuleFrame) ?? capsuleFrame
    }

    public mutating func pointerEntered(at now: Date) {
        pointerEnteredAt = now
        pointerExitedAt = nil
    }

    public mutating func pointerExited(at now: Date) {
        pointerEnteredAt = nil
        pointerExitedAt = now
    }

    /// The mouse button went down at `point` (screen coordinates).
    public mutating func pressed(at point: CGPoint) {
        pressedAt = point
        // A press may start a drag: resting no longer opens the card until the pointer comes back.
        pointerEnteredAt = nil
    }

    /// The mouse button came up at `point`. Moving no more than ~3 pt is a click,
    /// and a click opens the card at once; anything further was a drag.
    public mutating func released(at point: CGPoint, visibleFrame: CGRect) {
        defer { pressedAt = nil }
        guard let pressedAt, hypot(point.x - pressedAt.x, point.y - pressedAt.y) <= Self.clickTolerance else { return }
        expand(in: visibleFrame)
    }

    /// Applies whatever is due by `now`.
    /// - Parameter visibleFrame: the usable area of the screen the capsule is on.
    public mutating func check(at now: Date, visibleFrame: CGRect) {
        if let pointerEnteredAt, now.timeIntervalSince(pointerEnteredAt) >= Self.restBeforeExpanding {
            expand(in: visibleFrame)
        }
        if let pointerExitedAt, now.timeIntervalSince(pointerExitedAt) >= Self.awayBeforeCollapsing {
            cardLayout = nil
            self.pointerExitedAt = nil
        }
    }

    /// The capsule was dragged to `frame`.
    public mutating func moveCapsule(to frame: CGRect) {
        capsuleFrame = frame
    }

    /// The Floating Window was hidden; no exit arrives for a window that is gone.
    public mutating func hide() {
        cardLayout = nil
        pointerEnteredAt = nil
        pointerExitedAt = nil
        pressedAt = nil
    }

    private mutating func expand(in visibleFrame: CGRect) {
        guard cardLayout == nil else { return }
        cardLayout = CardLayout(capsule: capsuleFrame, visibleFrame: visibleFrame)
    }
}
