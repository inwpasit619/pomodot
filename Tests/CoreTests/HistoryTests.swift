import Foundation
import Testing
import Core

// What enters History, and what never touches it.

@Test("Given Focus 1/4 started at 09:00 Bangkok time, when it runs to the end and its Pomodoro is recorded, then History holds one 1500-second Pomodoro ending 09:25 and Today counts it")
func aFinishedFocusIsRecorded() {
    // Given
    var timer = PomodoroTimer()
    var history = History()
    timer.start(at: iso("2026-10-15T09:00:00+07:00"))

    // When
    history.record(timer.tick(at: iso("2026-10-15T09:25:03+07:00")).pomodoros)

    // Then
    #expect(history.pomodoros == [Pomodoro(end: iso("2026-10-15T09:25:00+07:00"), durationSeconds: 1500)])
    let statistics = history.statistics(at: iso("2026-10-15T09:30:00+07:00"), calendar: bangkokCalendar())
    #expect(statistics.today == FocusTotal(pomodoros: 1, focusSeconds: 1500))
}

@Test("Given Focus 1/4 Running from 09:00, when it is skipped at 09:10, then nothing enters History")
func aSkippedFocusIsNotRecorded() {
    // Given
    var timer = PomodoroTimer()
    var history = History()
    timer.start(at: iso("2026-10-15T09:00:00+07:00"))

    // When
    history.record(timer.skip(at: iso("2026-10-15T09:10:00+07:00")).pomodoros)

    // Then
    #expect(history.pomodoros.isEmpty)
}

@Test("Given Focus 1/4 Running from 09:00, when it is reset at 09:10, then nothing enters History")
func aResetFocusIsNotRecorded() {
    // Given
    var timer = PomodoroTimer()
    var history = History()
    timer.start(at: iso("2026-10-15T09:00:00+07:00"))

    // When
    history.record(timer.reset(at: iso("2026-10-15T09:10:00+07:00")).pomodoros)

    // Then
    #expect(history.pomodoros.isEmpty)
}

@Test("Given 2 Pomodoros recorded in this Cycle, when a New Cycle is started, then History still holds both")
func aNewCycleKeepsHistory() {
    // Given
    var timer = PomodoroTimer()
    var history = History()
    history.record(runPhase(&timer, from: at("09:00"), minutes: 25))
    history.record(runPhase(&timer, from: at("09:25"), minutes: 5))
    history.record(runPhase(&timer, from: at("09:30"), minutes: 25))

    // When
    history.record(timer.newCycle(at: at("09:56")).pomodoros)

    // Then
    #expect(history.pomodoros == [
        Pomodoro(end: at("09:25"), durationSeconds: 1500),
        Pomodoro(end: at("09:55"), durationSeconds: 1500),
    ])
}

@Test("Given 3 Pomodoros today and Focus 2/4 Paused with 10:00 left, when History is cleared, then History is empty, Today is 0, and the timer is still Focus 2/4 Paused with 10:00 left")
func clearingHistoryLeavesTheTimerAlone() {
    // Given
    var timer = PomodoroTimer()
    var history = History()
    history.record(runPhase(&timer, from: at("09:00"), minutes: 25))
    _ = runPhase(&timer, from: at("09:25"), minutes: 5)
    timer.start(at: at("09:30"))
    _ = timer.pause(at: at("09:45"))
    history.record([
        Pomodoro(end: at("08:00"), durationSeconds: 1500),
        Pomodoro(end: at("08:30"), durationSeconds: 1500),
    ])

    // When
    history.clear()

    // Then
    #expect(history.pomodoros.isEmpty)
    let statistics = history.statistics(at: at("10:00"), calendar: bangkokCalendar())
    #expect(statistics.today == FocusTotal(pomodoros: 0, focusSeconds: 0))
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 2)
    #expect(timer.pomodorosDone == 1)
    #expect(timer.status == .paused)
    #expect(timer.remainingSeconds(at: at("10:00")) == 600)
}

/// `count` one-minute-apart Pomodoros.
private func history(of count: Int) -> History {
    History((0..<count).map { Pomodoro(end: at("09:00").addingTimeInterval(TimeInterval($0 * 60)), durationSeconds: 1500) })
}

@Test("Given 412 Pomodoros in History, when Clear History… is pressed, then it asks \"Delete all 412 Pomodoros?\" with \"This can't be undone.\" and the buttons Delete and Cancel")
func clearHistoryAsksWithTheCount() {
    // Given
    let history = history(of: 412)

    // When
    let confirmation = history.clearConfirmation

    // Then
    #expect(confirmation == Confirmation(
        title: "Delete all 412 Pomodoros?",
        message: "This can't be undone.",
        confirmButtonTitle: "Delete"
    ))
    #expect(confirmation?.cancelButtonTitle == "Cancel")
}

@Test("Given 1 Pomodoro in History, when Clear History… is pressed, then it asks \"Delete 1 Pomodoro?\"")
func clearHistoryAsksAboutOnePomodoro() {
    // Given
    let history = history(of: 1)

    // When
    let confirmation = history.clearConfirmation

    // Then
    #expect(confirmation?.title == "Delete 1 Pomodoro?")
}

@Test("Given an empty History, when Clear History… is asked about, then there is no question, so the button can't be pressed")
func clearHistoryIsOffWhenEmpty() {
    // Given
    let history = History()

    // When
    let confirmation = history.clearConfirmation

    // Then
    #expect(confirmation == nil)
}
