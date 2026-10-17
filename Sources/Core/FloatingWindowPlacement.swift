import CoreGraphics

/// Where the Floating Window sits on screen. Rects use AppKit's global
/// coordinates: the origin is bottom-left and y grows upwards.
public enum FloatingWindowPlacement {
    /// The collapsed capsule's size in points.
    public static let capsuleSize = CGSize(width: 128, height: 38)
    /// The expanded card's size in points.
    public static let cardSize = CGSize(width: 284, height: 200)

    /// Gap between the menu bar and the capsule's top edge.
    static let gapBelowMenuBar: CGFloat = 12

    /// Top centre of the main display, just below the menu bar. Used the first
    /// time the app opens, when no position is remembered.
    /// - Parameter visibleFrame: the main display's usable area
    ///   (`NSScreen.visibleFrame`, without the menu bar and the Dock).
    public static func startingCapsuleFrame(in visibleFrame: CGRect) -> CGRect {
        let top: CGFloat = visibleFrame.maxY - gapBelowMenuBar
        let origin = CGPoint(
            x: visibleFrame.midX - capsuleSize.width / 2,
            y: top - capsuleSize.height
        )
        return CGRect(origin: origin, size: capsuleSize)
    }

    /// Where the capsule goes when the app opens: centred on the remembered point while that
    /// is on some display's usable area, otherwise (a display unplugged, a resolution changed,
    /// never moved) the starting position on the main display.
    /// - Parameters:
    ///   - center: the collapsed capsule's centre from state.json, or nil.
    ///   - screens: every display's usable area (`NSScreen.visibleFrame`).
    ///   - mainScreen: the main display's usable area.
    public static func capsuleFrame(remembering center: CGPoint?, screens: [CGRect], mainScreen: CGRect) -> CGRect {
        guard let center, screens.contains(where: { $0.contains(center) }) else {
            return startingCapsuleFrame(in: mainScreen)
        }
        let origin = CGPoint(x: center.x - capsuleSize.width / 2, y: center.y - capsuleSize.height / 2)
        return CGRect(origin: origin, size: capsuleSize)
    }

    /// Gap between the card's ellipsis button and its menu.
    static let menuGap: CGFloat = 4

    /// Where the card's menu puts its top-left corner: just below the ellipsis button, its left
    /// edge lined up with the button's, or just above the button when the screen has no room
    /// below (AppKit would make the menu scroll).
    /// - Parameter visibleFrame: the usable area of the screen the button is on.
    public static func menuCorner(below button: CGRect, menuHeight: CGFloat, in visibleFrame: CGRect) -> CGPoint {
        let below = button.minY - menuGap
        let fitsBelow = below - menuHeight >= visibleFrame.minY
        return CGPoint(x: button.minX, y: fitsBelow ? below : button.maxY + menuGap + menuHeight)
    }

    /// Where the card goes when the capsule expands: the capsule never moves and
    /// the card grows toward the side of its screen with room.
    /// - Parameter visibleFrame: the usable area of the screen the capsule is on.
    public static func cardFrame(around capsule: CGRect, in visibleFrame: CGRect) -> CGRect {
        CardLayout(capsule: capsule, visibleFrame: visibleFrame).cardFrame(around: capsule)
    }
}

/// Which way the card grows from the capsule. Chosen when the card opens and again when
/// a drag of the card ends; never while it moves, so the card never jumps away from the pointer.
public struct CardLayout: Sendable, Equatable {
    /// Centred on the capsule, or growing away from the top or bottom edge where centring would cross it.
    public enum Vertical: Sendable { case centered, down, up }
    /// Centred on the capsule, or lined up with the capsule's edge where centring would cross the screen's.
    public enum Horizontal: Sendable { case centered, rightEdges, leftEdges }

    public let vertical: Vertical
    public let horizontal: Horizontal

    init(vertical: Vertical, horizontal: Horizontal) {
        self.vertical = vertical
        self.horizontal = horizontal
    }

    /// The way a card already at `card` grows from a capsule tucked into it: lined up with each
    /// edge of the screen it is near, centred where it is near none, so it shrinks into that edge
    /// or corner. "Near" is asked of the growing rule, so opening it again lands the card on `card`
    /// whatever the card's and capsule's sizes.
    public init(tucking card: CGRect, visibleFrame: CGRect) {
        func growing(fromCapsuleIn layout: CardLayout) -> CardLayout {
            CardLayout(capsule: layout.capsuleFrame(inside: card), visibleFrame: visibleFrame)
        }
        let topRight = growing(fromCapsuleIn: CardLayout(vertical: .down, horizontal: .rightEdges))
        let bottomLeft = growing(fromCapsuleIn: CardLayout(vertical: .up, horizontal: .leftEdges))
        vertical = topRight.vertical == .down ? .down : bottomLeft.vertical == .up ? .up : .centered
        horizontal = topRight.horizontal == .rightEdges ? .rightEdges
            : bottomLeft.horizontal == .leftEdges ? .leftEdges : .centered
    }

    public init(capsule: CGRect, visibleFrame: CGRect) {
        // Near the top it grows down (card top = capsule top); near the bottom, up.
        let halfHeight = FloatingWindowPlacement.cardSize.height / 2
        if capsule.midY + halfHeight > visibleFrame.maxY {
            vertical = .down
        } else if capsule.midY - halfHeight < visibleFrame.minY {
            vertical = .up
        } else {
            vertical = .centered
        }
        let halfCard = FloatingWindowPlacement.cardSize.width / 2
        if capsule.midX + halfCard > visibleFrame.maxX {
            horizontal = .rightEdges
        } else if capsule.midX - halfCard < visibleFrame.minX {
            horizontal = .leftEdges
        } else {
            horizontal = .centered
        }
    }

    public func cardFrame(around capsule: CGRect) -> CGRect {
        let size = FloatingWindowPlacement.cardSize
        let y = switch vertical {
        case .centered: capsule.midY - size.height / 2
        case .down: capsule.maxY - size.height
        case .up: capsule.minY
        }
        let x = switch horizontal {
        case .centered: capsule.midX - size.width / 2
        case .rightEdges: capsule.maxX - size.width
        case .leftEdges: capsule.minX
        }
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }

    /// Where the capsule sits inside `card`: the middle, edge or corner the card grows from.
    public func capsuleFrame(inside card: CGRect) -> CGRect {
        let size = FloatingWindowPlacement.capsuleSize
        let y = switch vertical {
        case .centered: card.midY - size.height / 2
        case .down: card.maxY - size.height
        case .up: card.minY
        }
        let x = switch horizontal {
        case .centered: card.midX - size.width / 2
        case .rightEdges: card.maxX - size.width
        case .leftEdges: card.minX
        }
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
