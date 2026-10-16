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

    /// Where the card goes when the capsule expands: the capsule never moves and
    /// the card grows toward the side of its screen with room.
    /// - Parameter visibleFrame: the usable area of the screen the capsule is on.
    public static func cardFrame(around capsule: CGRect, in visibleFrame: CGRect) -> CGRect {
        CardLayout(capsule: capsule, visibleFrame: visibleFrame).cardFrame(around: capsule)
    }
}

/// Which way the card grows from the capsule. Chosen when the card opens and kept
/// until it closes, so the card never jumps away from the pointer.
public struct CardLayout: Sendable, Equatable {
    public enum Vertical: Sendable { case down, up }
    /// Centred on the capsule, or lined up with the capsule's edge where centring would cross the screen's.
    public enum Horizontal: Sendable { case centered, rightEdges, leftEdges }

    public let vertical: Vertical
    public let horizontal: Horizontal

    public init(capsule: CGRect, visibleFrame: CGRect) {
        // Top half grows down (card top = capsule top); bottom half grows up.
        vertical = capsule.midY >= visibleFrame.midY ? .down : .up
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
        let y = vertical == .down ? capsule.maxY - size.height : capsule.minY
        let x = switch horizontal {
        case .centered: capsule.midX - size.width / 2
        case .rightEdges: capsule.maxX - size.width
        case .leftEdges: capsule.minX
        }
        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
