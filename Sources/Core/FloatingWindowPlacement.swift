import CoreGraphics

/// Where the Floating Window sits on screen. Rects use AppKit's global
/// coordinates: the origin is bottom-left and y grows upwards.
public enum FloatingWindowPlacement {
    /// The collapsed capsule's size in points.
    public static let capsuleSize = CGSize(width: 128, height: 38)

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
}
