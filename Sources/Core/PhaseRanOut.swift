/// One of the two sounds: the end of a Focus, or the end of a Short or Long Break.
public enum Sound: Sendable, Equatable {
    case focus, `break`

    /// The macOS system sound each one plays until Settings can change it (M5).
    public var defaultSystemSoundName: String {
        switch self {
        case .focus: "Glass"
        case .break: "Hero"
        }
    }
}

/// The macOS banner's title and body.
public struct Banner: Sendable, Equatable {
    public let title: String
    public let body: String

    public init(title: String, body: String) {
        self.title = title
        self.body = body
    }
}

/// A Phase that ran out by itself, and where the timer went next.
/// Only this is announced: Skip, Reset, New Cycle and sleep never are.
public struct PhaseRanOut: Sendable, Equatable {
    /// The Phase that ran out, numbered k/N as it was.
    let phase: Phase
    let number: Int
    let pomodorosPerCycle: Int
    /// The Phase the timer moved to, numbered k/N, at its full length.
    let next: Phase
    let nextNumber: Int
    let nextMinutes: Int
    /// Running already, rather than waiting for Start.
    let nextStarted: Bool

    public var sound: Sound { phase == .focus ? .focus : .break }

    /// Nil when Show notifications is off. The sound plays either way.
    public func banner(showNotifications: Bool) -> Banner? {
        guard showNotifications else { return nil }
        switch phase {
        case .focus:
            let nextBreak = "\(nextMinutes)-minute \(next.name)"
            let finished = next == .longBreak ? "Cycle complete" : "Focus complete"
            return Banner(
                title: "\(finished) 🍅 \(number)/\(pomodorosPerCycle)",
                body: nextStarted ? "\(nextBreak) started." : "Time for a \(nextBreak)."
            )
        case .longBreak:
            // A new Cycle always waits for Start.
            return Banner(title: "Long Break over", body: "Ready for a new Cycle.")
        case .shortBreak:
            let focus = "Focus \(nextNumber)/\(pomodorosPerCycle)"
            return Banner(title: "Break over", body: nextStarted ? "\(focus) started." : "Time for \(focus).")
        }
    }
}
