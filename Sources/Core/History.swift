import Foundation

/// Every Pomodoro (when it ended and how long it was), kept until the user clears it.
/// New Cycle and Reset never touch it; a Focus that wasn't a Pomodoro never enters it.
public struct History: Sendable, Equatable {
    public private(set) var pomodoros: [Pomodoro]

    public init(_ pomodoros: [Pomodoro] = []) {
        self.pomodoros = pomodoros
    }

    /// Adds the Pomodoros the timer just produced, oldest first.
    public mutating func record(_ new: [Pomodoro]) {
        pomodoros += new
    }

    /// Clear History: every Pomodoro goes. The timer is a separate thing and stays as it is.
    public mutating func clear() {
        pomodoros = []
    }

    /// History split into days and weeks by `calendar`: the Mac's time zone now and its first
    /// weekday. A Pomodoro counts on the day it ended.
    public func statistics(at now: Date, calendar: Calendar) -> Statistics {
        let today = calendar.startOfDay(for: now)
        // Oldest first, ending today; a day with no Pomodoro still has its slot.
        let lastSevenDays = (-6...0).compactMap { calendar.date(byAdding: .day, value: $0, to: today) }
        // The week as the Mac's Language & Region sets it, so it starts on its first weekday.
        let thisWeek = calendar.dateInterval(of: .weekOfYear, for: now)
        return Statistics(
            today: total { calendar.startOfDay(for: $0.end) == today },
            thisWeek: total { thisWeek?.contains($0.end) ?? false },
            allTime: total { _ in true },
            lastSevenDays: lastSevenDays.map { day in
                DayTotal(day: day, isToday: day == today, total: total { calendar.startOfDay(for: $0.end) == day })
            }
        )
    }

    private func total(where included: (Pomodoro) -> Bool) -> FocusTotal {
        let counted = pomodoros.filter(included)
        return FocusTotal(pomodoros: counted.count, focusSeconds: counted.reduce(0) { $0 + $1.durationSeconds })
    }
}

/// How many Pomodoros, and how much Focus time they add up to.
public struct FocusTotal: Sendable, Equatable {
    public let pomodoros: Int
    public let focusSeconds: Int

    public init(pomodoros: Int, focusSeconds: Int) {
        self.pomodoros = pomodoros
        self.focusSeconds = focusSeconds
    }
}

/// What the Statistics window and the menu's Today line show.
public struct Statistics: Sendable, Equatable {
    public let today: FocusTotal
    public let thisWeek: FocusTotal
    public let allTime: FocusTotal
    /// One slot per day, oldest first, the last one today.
    public let lastSevenDays: [DayTotal]
}

/// One day of the Last 7 Days chart.
public struct DayTotal: Sendable, Equatable {
    /// The start of the day, in the calendar Statistics were read with.
    public let day: Date
    /// The chart labels this slot Today and draws its bar darker.
    public let isToday: Bool
    public let total: FocusTotal

    public init(day: Date, isToday: Bool, total: FocusTotal) {
        self.day = day
        self.isToday = isToday
        self.total = total
    }
}
