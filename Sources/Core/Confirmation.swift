/// A question asked before an action that would lose progress.
public struct Confirmation: Sendable, Equatable {
    public let title: String
    public let message: String
    public let confirmButtonTitle: String
    public let cancelButtonTitle = "Cancel"

    public init(title: String, message: String, confirmButtonTitle: String) {
        self.title = title
        self.message = message
        self.confirmButtonTitle = confirmButtonTitle
    }
}

extension PomodoroTimer {
    /// Asked only when Reset would lose time: the current Phase has started (Running or Paused).
    public var resetConfirmation: Confirmation? {
        guard status != .ready else { return nil }
        let fullLength = TimeText.minutesSeconds(settings.lengthSeconds(of: phase))
        var message = "It will go back to \(fullLength)."
        if phase == .focus {
            message += " It won't count as a Pomodoro."
        }
        return Confirmation(title: "Reset this \(phase.name)?", message: message, confirmButtonTitle: "Reset")
    }

    /// Asked only when New Cycle would lose progress: a Pomodoro in this Cycle,
    /// or a current Phase that has started.
    public var newCycleConfirmation: Confirmation? {
        guard pomodorosDone >= 1 || status != .ready else { return nil }
        return Confirmation(
            title: "Start a new Cycle?",
            message: "Progress in this Cycle will be cleared. Your History is kept.",
            confirmButtonTitle: "New Cycle"
        )
    }
}
