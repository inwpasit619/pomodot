/// Said once ever, the first time the Floating Window is hidden: Pomodot is still running,
/// and how to bring the Floating Window back without the menu bar.
public struct HideNotice: Sendable, Equatable {
    public let title: String
    public let message: String
    public let buttonTitle = "OK"

    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    /// The Floating Window was just hidden, from any menu. The first time ever, returns the
    /// notice and sets `alreadyShown`; nil after that.
    /// - Parameter showInDock: whether Pomodot has a Dock icon to click.
    public static func onHiding(alreadyShown: inout Bool, showInDock: Bool) -> HideNotice? {
        guard !alreadyShown else { return nil }
        alreadyShown = true
        let howToBringItBack = showInDock
            ? "click Pomodot in the Dock, or open it again from Spotlight or Launchpad."
            : "open Pomodot again from Spotlight or Launchpad."
        return HideNotice(
            title: "Pomodot keeps running",
            message: "To bring the Floating Window back, \(howToBringItBack)"
        )
    }
}
