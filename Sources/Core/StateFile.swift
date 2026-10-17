import CoreGraphics
import Foundation

/// The timer as a Pause at one moment: what state.json keeps. A Running timer is kept
/// with the time it had left then, so it always comes back Paused.
public struct TimerSnapshot: Sendable, Equatable {
    public var phase: Phase
    /// The k in "k/N".
    public var displayNumber: Int
    public var pomodorosDone: Int
    /// The N of the Cycle it was in, not the one in Settings.
    public var pomodorosPerCycle: Int
    /// The Phase's full length, for the time-left bar.
    public var phaseLengthSeconds: Int
    public var remainingSeconds: Int
    /// False comes back Ready, true comes back Paused.
    public var hasStarted: Bool

    public init(
        phase: Phase, displayNumber: Int, pomodorosDone: Int, pomodorosPerCycle: Int,
        phaseLengthSeconds: Int, remainingSeconds: Int, hasStarted: Bool
    ) {
        self.phase = phase
        self.displayNumber = displayNumber
        self.pomodorosDone = pomodorosDone
        self.pomodorosPerCycle = pomodorosPerCycle
        self.phaseLengthSeconds = phaseLengthSeconds
        self.remainingSeconds = remainingSeconds
        self.hasStarted = hasStarted
    }
}

/// Whether the Floating Window shows, floats on top, and where its capsule is; and whether
/// the notice on its first Hide has been shown.
public struct FloatingWindowState: Sendable, Equatable {
    /// Written as it is, but always true once loaded: the capsule shows whenever Pomodot opens.
    public var visible: Bool
    public var alwaysOnTop: Bool
    /// The collapsed capsule's centre in AppKit's global coordinates; nil until it is moved
    /// from the starting position.
    public var center: CGPoint?
    /// The notice on the first Hide has been shown. Kept here rather than in settings.json,
    /// so Restore Defaults leaves it alone.
    public var hideNoticeShown: Bool

    public init(visible: Bool = true, alwaysOnTop: Bool = true, center: CGPoint? = nil, hideNoticeShown: Bool = false) {
        self.visible = visible
        self.alwaysOnTop = alwaysOnTop
        self.center = center
        self.hideNoticeShown = hideNoticeShown
    }
}

/// Everything state.json keeps across a Quit.
public struct SavedState: Sendable, Equatable {
    public var timer: TimerSnapshot
    public var floatingWindow: FloatingWindowState

    public init(timer: TimerSnapshot, floatingWindow: FloatingWindowState) {
        self.timer = timer
        self.floatingWindow = floatingWindow
    }
}

/// state.json, version 1: the timer as a Pause, and the Floating Window.
public enum StateFile {
    /// - Parameters:
    ///   - data: the file's bytes, or nil when there is no file yet.
    ///   - settings: where a fresh timer, or a missing or wrong length, comes from.
    public static func decode(_ data: Data?, settings: TimerSettings) -> Loaded<SavedState> {
        // Focus 1/N at full length, Ready; the Floating Window showing, on top, at the starting position.
        let fresh = SavedState(timer: freshTimer(settings), floatingWindow: FloatingWindowState())
        guard let data else { return Loaded(value: fresh, moveAside: false) }
        // Not JSON, or written by a newer Pomodot: start fresh, and never write over it.
        guard let file = try? JSONDecoder().decode(FileBeingRead.self, from: data), file.version <= 1 else {
            return Loaded(value: fresh, moveAside: true)
        }
        return Loaded(
            value: SavedState(
                timer: file.timer?.snapshot(settings: settings) ?? fresh.timer,
                floatingWindow: file.floatingWindow?.state ?? fresh.floatingWindow
            ),
            moveAside: false
        )
    }

    private static func freshTimer(_ settings: TimerSettings) -> TimerSnapshot {
        let length = settings.lengthSeconds(of: .focus)
        return TimerSnapshot(
            phase: .focus, displayNumber: 1, pomodorosDone: 0, pomodorosPerCycle: settings.pomodorosPerCycle,
            phaseLengthSeconds: length, remainingSeconds: length, hasStarted: false
        )
    }

    /// The whole file, rewritten each time (the App writes it atomically).
    public static func encode(_ state: SavedState) -> Data {
        let timer = state.timer
        let window = state.floatingWindow
        let file = FileContents(
            version: 1,
            timer: TimerContents(
                phase: PhaseName(timer.phase),
                displayNumber: timer.displayNumber,
                pomodorosDone: timer.pomodorosDone,
                pomodorosPerCycle: timer.pomodorosPerCycle,
                phaseLengthSeconds: timer.phaseLengthSeconds,
                remainingSeconds: timer.remainingSeconds,
                hasStarted: timer.hasStarted
            ),
            floatingWindow: FloatingWindowContents(
                visible: window.visible,
                alwaysOnTop: window.alwaysOnTop,
                center: window.center.map { Center(x: $0.x, y: $0.y) },
                hideNoticeShown: window.hideNoticeShown
            )
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        // Whole numbers, booleans, strings and finite points: encoding can't fail.
        return try! encoder.encode(file)
    }

    private enum PhaseName: String, Codable {
        case focus, shortBreak, longBreak

        init(_ phase: Phase) {
            switch phase {
            case .focus: self = .focus
            case .shortBreak: self = .shortBreak
            case .longBreak: self = .longBreak
            }
        }

        var phase: Phase {
            switch self {
            case .focus: .focus
            case .shortBreak: .shortBreak
            case .longBreak: .longBreak
            }
        }
    }

    /// Written as { "x": …, "y": … }; CGPoint's own Codable would write [x, y].
    private struct Center: Codable {
        var x: CGFloat
        var y: CGFloat
    }

    private struct FileContents: Encodable {
        var version: Int
        var timer: TimerContents
        var floatingWindow: FloatingWindowContents
    }

    private struct TimerContents: Encodable {
        var phase: PhaseName
        var displayNumber: Int
        var pomodorosDone: Int
        var pomodorosPerCycle: Int
        var phaseLengthSeconds: Int
        var remainingSeconds: Int
        var hasStarted: Bool
    }

    private struct FloatingWindowContents: Encodable {
        var visible: Bool
        var alwaysOnTop: Bool
        var center: Center?
        var hideNoticeShown: Bool

        /// Writes `"center": null` for a capsule never moved, as the spec's format shows.
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(visible, forKey: .visible)
            try container.encode(alwaysOnTop, forKey: .alwaysOnTop)
            try container.encode(center, forKey: .center)
            try container.encode(hideNoticeShown, forKey: .hideNoticeShown)
        }

        private enum CodingKeys: String, CodingKey {
            case visible, alwaysOnTop, center, hideNoticeShown
        }
    }

    /// Reads leniently: a value that is missing or of the wrong type is nil, and only
    /// that value falls back to its default.
    private struct FileBeingRead: Decodable {
        var version: Int
        var timer: TimerBeingRead?
        var floatingWindow: FloatingWindowBeingRead?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            version = (try? container.decode(Int.self, forKey: .version)) ?? 1
            timer = try? container.decode(TimerBeingRead.self, forKey: .timer)
            floatingWindow = try? container.decode(FloatingWindowBeingRead.self, forKey: .floatingWindow)
        }

        private enum CodingKeys: String, CodingKey {
            case version, timer, floatingWindow
        }
    }

    private struct TimerBeingRead: Decodable {
        var phase: PhaseName?
        var displayNumber: Int?
        var pomodorosDone: Int?
        var pomodorosPerCycle: Int?
        var phaseLengthSeconds: Int?
        var remainingSeconds: Int?
        var hasStarted: Bool?

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            phase = try? container.decode(PhaseName.self, forKey: .phase)
            displayNumber = try? container.decode(Int.self, forKey: .displayNumber)
            pomodorosDone = try? container.decode(Int.self, forKey: .pomodorosDone)
            pomodorosPerCycle = try? container.decode(Int.self, forKey: .pomodorosPerCycle)
            phaseLengthSeconds = try? container.decode(Int.self, forKey: .phaseLengthSeconds)
            remainingSeconds = try? container.decode(Int.self, forKey: .remainingSeconds)
            hasStarted = try? container.decode(Bool.self, forKey: .hasStarted)
        }

        private enum CodingKeys: String, CodingKey {
            case phase, displayNumber, pomodorosDone, pomodorosPerCycle
            case phaseLengthSeconds, remainingSeconds, hasStarted
        }

        /// Each value checked on its own; one that is missing or out of range takes its
        /// default and the others are kept.
        func snapshot(settings: TimerSettings) -> TimerSnapshot {
            let phase = phase?.phase ?? .focus
            // As far as Settings allow: 1–10 Pomodoros per Cycle, Phases of 1–120 minutes.
            let perCycle = pomodorosPerCycle.flatMap { TimerSettings.pomodorosPerCycleRange.contains($0) ? $0 : nil }
                ?? settings.pomodorosPerCycle
            let done = pomodorosDone.flatMap { (0...perCycle).contains($0) ? $0 : nil } ?? 0
            let number = displayNumber.flatMap { (1...perCycle).contains($0) ? $0 : nil }
                ?? min(done + 1, perCycle)
            let length = phaseLengthSeconds.flatMap { TimerSettings.lengthSecondsRange.contains($0) ? $0 : nil }
                ?? settings.lengthSeconds(of: phase)
            let remaining = remainingSeconds.flatMap { (0...length).contains($0) ? $0 : nil } ?? length
            return TimerSnapshot(
                phase: phase, displayNumber: number, pomodorosDone: done, pomodorosPerCycle: perCycle,
                phaseLengthSeconds: length, remainingSeconds: remaining, hasStarted: hasStarted ?? false
            )
        }
    }

    private struct FloatingWindowBeingRead: Decodable {
        var state: FloatingWindowState

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let defaults = FloatingWindowState()
            // A null centre is a capsule never moved; a broken one is treated the same.
            let center = try? container.decode(Center.self, forKey: .center)
            state = FloatingWindowState(
                // `visible` isn't read: the capsule shows whenever Pomodot opens, even if it was hidden at Quit.
                visible: defaults.visible,
                alwaysOnTop: (try? container.decode(Bool.self, forKey: .alwaysOnTop)) ?? defaults.alwaysOnTop,
                center: center.map { CGPoint(x: $0.x, y: $0.y) },
                // A file from 0.9.0 has none: the notice hasn't been shown.
                hideNoticeShown: (try? container.decode(Bool.self, forKey: .hideNoticeShown)) ?? defaults.hideNoticeShown
            )
        }

        private enum CodingKeys: String, CodingKey {
            case alwaysOnTop, center, hideNoticeShown
        }
    }
}
