import Foundation
import Testing
import Core

// History by day and week, in Bangkok (UTC+7) unless a test says otherwise.

@Test("Given a 1500-second Pomodoro that ended 2026-10-14T17:10:00Z (00:10 on 15 Oct in Bangkok), when Statistics are read, then it counts on 15 Oct, not 14 Oct")
func aPomodoroAcrossMidnightCountsOnTheDayItEnded() {
    // Given
    let history = History([Pomodoro(end: iso("2026-10-14T17:10:00Z"), durationSeconds: 1500)])

    // When
    let on15th = history.statistics(at: iso("2026-10-15T12:00:00+07:00"), calendar: bangkokCalendar())
    let on14th = history.statistics(at: iso("2026-10-14T23:00:00+07:00"), calendar: bangkokCalendar())

    // Then
    #expect(on15th.today == FocusTotal(pomodoros: 1, focusSeconds: 1500))
    #expect(on14th.today == FocusTotal(pomodoros: 0, focusSeconds: 0))
}

/// Pomodoros on Saturday 10, Sunday 11 and Monday 12 October 2026, Bangkok time.
private let weekendAndMonday = History([
    Pomodoro(end: iso("2026-10-10T10:00:00+07:00"), durationSeconds: 1500),
    Pomodoro(end: iso("2026-10-11T10:00:00+07:00"), durationSeconds: 1800),
    Pomodoro(end: iso("2026-10-12T10:00:00+07:00"), durationSeconds: 1200),
])

@Test("Given it is Wednesday 14 Oct at 12:00 and the Mac's week starts on Monday, when Statistics are read, then This Week starts on Monday 12 Oct")
func thisWeekStartsOnMonday() {
    // Given
    let calendar = bangkokCalendar(firstWeekday: 2)

    // When
    let statistics = weekendAndMonday.statistics(at: iso("2026-10-14T12:00:00+07:00"), calendar: calendar)

    // Then
    #expect(statistics.thisWeek == FocusTotal(pomodoros: 1, focusSeconds: 1200))
}

@Test("Given it is Wednesday 14 Oct at 12:00 and the Mac's week starts on Sunday, when Statistics are read, then This Week starts on Sunday 11 Oct")
func thisWeekStartsOnSunday() {
    // Given
    let calendar = bangkokCalendar(firstWeekday: 1)

    // When
    let statistics = weekendAndMonday.statistics(at: iso("2026-10-14T12:00:00+07:00"), calendar: calendar)

    // Then
    #expect(statistics.thisWeek == FocusTotal(pomodoros: 2, focusSeconds: 3000))
}

@Test("Given Pomodoros of 1500, 1800 and 1200 seconds on different days, when Statistics are read, then All Time counts all 3 and adds their own lengths to 4500 seconds")
func allTimeAddsEveryPomodorosOwnLength() {
    // Given
    let history = weekendAndMonday

    // When
    let statistics = history.statistics(at: iso("2026-10-14T12:00:00+07:00"), calendar: bangkokCalendar())

    // Then
    #expect(statistics.allTime == FocusTotal(pomodoros: 3, focusSeconds: 4500))
}

@Test("Given Pomodoros only today (Wed 14 Oct) and 3 days before, plus one 8 days ago, when the Last 7 Days chart is read, then it has 7 days from 8 Oct to today, only the last one is today, and days without a Pomodoro are 0")
func lastSevenDaysHasEveryDayEvenWithoutPomodoros() {
    // Given
    let history = History([
        Pomodoro(end: iso("2026-10-06T20:00:00+07:00"), durationSeconds: 1500),
        Pomodoro(end: iso("2026-10-11T09:00:00+07:00"), durationSeconds: 1800),
        Pomodoro(end: iso("2026-10-14T09:00:00+07:00"), durationSeconds: 1500),
        Pomodoro(end: iso("2026-10-14T11:00:00+07:00"), durationSeconds: 1500),
    ])

    // When
    let days = history.statistics(at: iso("2026-10-14T12:00:00+07:00"), calendar: bangkokCalendar()).lastSevenDays

    // Then
    let none = FocusTotal(pomodoros: 0, focusSeconds: 0)
    #expect(days == [
        DayTotal(day: iso("2026-10-08T00:00:00+07:00"), isToday: false, total: none),
        DayTotal(day: iso("2026-10-09T00:00:00+07:00"), isToday: false, total: none),
        DayTotal(day: iso("2026-10-10T00:00:00+07:00"), isToday: false, total: none),
        DayTotal(day: iso("2026-10-11T00:00:00+07:00"), isToday: false, total: FocusTotal(pomodoros: 1, focusSeconds: 1800)),
        DayTotal(day: iso("2026-10-12T00:00:00+07:00"), isToday: false, total: none),
        DayTotal(day: iso("2026-10-13T00:00:00+07:00"), isToday: false, total: none),
        DayTotal(day: iso("2026-10-14T00:00:00+07:00"), isToday: true, total: FocusTotal(pomodoros: 2, focusSeconds: 3000)),
    ])
}
