import Foundation
import Core

/// A clock time on one fixed day, e.g. `at("09:25:03")`.
func at(_ time: String) -> Date {
    let parts = time.split(separator: ":").map { Int($0)! }
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC")!
    let components = DateComponents(
        year: 2026, month: 10, day: 15,
        hour: parts[0], minute: parts[1], second: parts.count > 2 ? parts[2] : 0
    )
    return calendar.date(from: components)!
}

/// Starts the current Phase at `start` and ticks once `minutes` later.
func runPhase(_ timer: inout PomodoroTimer, from start: Date, minutes: Int) -> [Pomodoro] {
    timer.start(at: start)
    return timer.tick(at: start.addingTimeInterval(TimeInterval(minutes * 60)))
}

/// `t` seconds into a pointer scenario, e.g. `second(0.3)`.
func second(_ t: TimeInterval) -> Date {
    Date(timeIntervalSinceReferenceDate: 1_000_000 + t)
}
