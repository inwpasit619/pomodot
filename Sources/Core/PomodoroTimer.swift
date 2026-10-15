import Foundation

public enum Phase: Sendable {
    case focus, shortBreak, longBreak
}

/// Ready: full or held, never run yet. Running: counting down. Paused: has run, now held.
public enum PhaseStatus: Sendable {
    case ready, running, paused
}

/// The values the timer reads from Settings. Defaults: 25 / 5 / 15 / 4, auto-start off.
public struct TimerSettings: Sendable {
    public var focusMinutes = 25
    public var shortBreakMinutes = 5
    public var longBreakMinutes = 15
    public var pomodorosPerCycle = 4
    public var autoStartBreaks = false
    /// Only from a Short Break: a new Cycle always waits for Start.
    public var autoStartFocus = false

    public init() {}

    func lengthSeconds(of phase: Phase) -> Int {
        switch phase {
        case .focus: focusMinutes * 60
        case .shortBreak: shortBreakMinutes * 60
        case .longBreak: longBreakMinutes * 60
        }
    }
}

/// A Focus that ran to completion.
public struct Pomodoro: Sendable, Equatable {
    /// Rounded to a whole second, as History stores it.
    public let end: Date
    public let durationSeconds: Int

    public init(end: Date, durationSeconds: Int) {
        self.end = Date(timeIntervalSince1970: end.timeIntervalSince1970.rounded())
        self.durationSeconds = durationSeconds
    }
}

/// The timer's rules. It never reads the clock: every event takes `now` from the caller.
/// While Running it remembers only when it started and how much was left then.
public struct PomodoroTimer: Sendable {
    public private(set) var settings: TimerSettings
    public private(set) var phase: Phase = .focus
    public private(set) var status: PhaseStatus = .ready
    /// The k in "k/N".
    public private(set) var displayNumber = 1
    public private(set) var pomodorosDone = 0
    /// The N of the current Cycle, which may differ from Settings.
    public private(set) var pomodorosPerCycle: Int
    /// The full length of the current Phase.
    public private(set) var phaseLengthSeconds: Int

    /// Seconds left when the timer last started, or the held value while not Running.
    private var remainingAtStart: TimeInterval
    private var runningSince: Date?

    public init(settings: TimerSettings = TimerSettings()) {
        self.settings = settings
        pomodorosPerCycle = settings.pomodorosPerCycle
        phaseLengthSeconds = settings.lengthSeconds(of: .focus)
        remainingAtStart = TimeInterval(phaseLengthSeconds)
    }

    /// Start when Ready, Resume when Paused. Does nothing while Running.
    public mutating func start(at now: Date) {
        guard status != .running else { return }
        runningSince = now
        status = .running
    }

    /// Holds the time left. First ends any Phase that already ran out (as `tick` does).
    /// - Returns: the Pomodoros that catching up produced.
    public mutating func pause(at now: Date) -> [Pomodoro] {
        let pomodoros = tick(at: now)
        guard status == .running else { return pomodoros }
        remainingAtStart = remaining(at: now)
        runningSince = nil
        status = .paused
        return pomodoros
    }

    /// The one Start / Pause / Resume button: Pause while Running, otherwise Start or Resume.
    public mutating func startPauseResume(at now: Date) -> [Pomodoro] {
        if status == .running {
            return pause(at: now)
        }
        start(at: now)
        return []
    }

    /// The Mac is about to sleep: Pause, so it wakes up Paused. Locking the screen is not sleep.
    public mutating func sleep(at now: Date) -> [Pomodoro] {
        pause(at: now)
    }

    /// Ends every Phase whose time is up by `now`, in order, each at its scheduled
    /// end rather than at `now`, so a late tick loses no time.
    /// - Returns: every Pomodoro this produced, oldest first.
    public mutating func tick(at now: Date) -> [Pomodoro] {
        var pomodoros: [Pomodoro] = []
        while let end = scheduledEnd, end <= now {
            if let pomodoro = endPhase(at: end) {
                pomodoros.append(pomodoro)
            }
        }
        return pomodoros
    }

    /// When the running Phase will run out; nil unless Running.
    private var scheduledEnd: Date? {
        runningSince?.addingTimeInterval(remainingAtStart)
    }

    /// Moves past the Phase that ran out at `end`. Returns the Pomodoro if it was a Focus.
    private mutating func endPhase(at end: Date) -> Pomodoro? {
        var pomodoro: Pomodoro?
        switch phase {
        case .focus:
            pomodoro = Pomodoro(end: end, durationSeconds: phaseLengthSeconds)
            pomodorosDone += 1
            // A Break keeps the number of the Focus before it, so a Long Break is always N/N.
            enter(pomodorosDone >= pomodorosPerCycle ? .longBreak : .shortBreak,
                  startingAt: settings.autoStartBreaks ? end : nil)
        case .shortBreak:
            displayNumber = pomodorosDone + 1
            enter(.focus, startingAt: settings.autoStartFocus ? end : nil)
        case .longBreak:
            pomodorosDone = 0
            displayNumber = 1
            pomodorosPerCycle = settings.pomodorosPerCycle
            enter(.focus)
        }
        return pomodoro
    }

    /// Whole seconds left, rounded up, so a fresh 25-minute Focus reads 25:00.
    public func remainingSeconds(at now: Date) -> Int {
        Int(remaining(at: now).rounded(.up))
    }

    private func remaining(at now: Date) -> TimeInterval {
        guard let runningSince else { return remainingAtStart }
        return remainingAtStart - now.timeIntervalSince(runningSince)
    }

    /// Sets up `next` at full length: Running from `start` when given, else Ready.
    private mutating func enter(_ next: Phase, startingAt start: Date? = nil) {
        phase = next
        phaseLengthSeconds = settings.lengthSeconds(of: next)
        remainingAtStart = TimeInterval(phaseLengthSeconds)
        runningSince = start
        status = start == nil ? .ready : .running
    }
}
