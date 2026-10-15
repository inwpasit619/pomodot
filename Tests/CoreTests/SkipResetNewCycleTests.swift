import Foundation
import Testing
import Core

/// Focus `k`/4 Ready at 09:00 + 30 min × (k − 1), after k − 1 Pomodoros and their Short Breaks.
private func readyAtFocus(_ k: Int, settings: TimerSettings = TimerSettings()) -> PomodoroTimer {
    var timer = PomodoroTimer(settings: settings)
    var start = at("09:00")
    for _ in 1..<k {
        _ = runPhase(&timer, from: start, minutes: 25)
        _ = runPhase(&timer, from: start.addingTimeInterval(25 * 60), minutes: 5)
        start.addTimeInterval(30 * 60)
    }
    return timer
}

@Test("Given Focus 2/4 with done 1, when it is skipped, then it moves to Short Break 2/4, done stays 1, and the next Focus is 2/4 again")
func skippingAFocusIsNotAPomodoro() {
    // Given
    var timer = readyAtFocus(2)
    timer.start(at: at("09:30"))

    // When
    let pomodoros = timer.skip(at: at("09:40"))

    // Then
    #expect(pomodoros.isEmpty)
    #expect(timer.phase == .shortBreak)
    #expect(timer.displayNumber == 2)
    #expect(timer.pomodorosDone == 1)
    _ = runPhase(&timer, from: at("09:40"), minutes: 5)
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 2)
}

@Test("Given Focus 4/4 with done 3, when it is skipped, then it moves to Short Break 4/4, not the Long Break")
func skippingTheLastFocusStillLeadsToAShortBreak() {
    // Given
    var timer = readyAtFocus(4)

    // When
    _ = timer.skip(at: at("10:30"))

    // Then
    #expect(timer.phase == .shortBreak)
    #expect(timer.displayNumber == 4)
    #expect(timer.pomodorosDone == 3)
}

@Test("Given Short Break 2/4 after Focus 2/4 ran to the end, when it is skipped, then the timer is at Focus 3/4, Ready")
func skippingAShortBreakMovesToTheNextFocus() {
    // Given
    var timer = readyAtFocus(2)
    _ = runPhase(&timer, from: at("09:30"), minutes: 25)

    // When
    _ = timer.skip(at: at("09:56"))

    // Then
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 3)
    #expect(timer.pomodorosDone == 2)
    #expect(timer.status == .ready)
}

@Test("Given Start Focus automatically is on and the Long Break 4/4 is Running, when it is skipped, then Focus 1/4 of a new Cycle is Ready with done 0")
func skippingTheLongBreakStartsANewCycleReady() {
    // Given
    var settings = TimerSettings()
    settings.autoStartFocus = true
    var timer = readyAtFocus(4, settings: settings)
    _ = runPhase(&timer, from: at("10:30"), minutes: 25)
    timer.start(at: at("10:55"))

    // When
    _ = timer.skip(at: at("11:00"))

    // Then
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 1)
    #expect(timer.pomodorosDone == 0)
    #expect(timer.status == .ready)
}

@Test("Given Start breaks automatically is on and Focus 1/4 is Running, when it is skipped at 09:10, then the Short Break is Running from 09:10")
func skipUsesTheSameAutoStartRules() {
    // Given
    var settings = TimerSettings()
    settings.autoStartBreaks = true
    var timer = PomodoroTimer(settings: settings)
    timer.start(at: at("09:00"))

    // When
    _ = timer.skip(at: at("09:10"))

    // Then
    #expect(timer.phase == .shortBreak)
    #expect(timer.status == .running)
    #expect(timer.remainingSeconds(at: at("09:12")) == 3 * 60)
}

@Test("Given Focus 2/4 Running with 10:00 left, when it is reset, then it is Focus 2/4 at 25:00, Ready, done stays 1, and there is no Pomodoro")
func resetPutsThePhaseBackToFullLength() {
    // Given
    var timer = readyAtFocus(2)
    timer.start(at: at("09:30"))

    // When
    let pomodoros = timer.reset(at: at("09:45"))

    // Then
    #expect(pomodoros.isEmpty)
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 2)
    #expect(timer.pomodorosDone == 1)
    #expect(timer.status == .ready)
    #expect(timer.remainingSeconds(at: at("10:00")) == 25 * 60)
}

@Test("Given Focus 2/4 Running and Focus changed to 30 minutes in Settings, when it is reset, then it goes back to 30:00")
func resetUsesTheLatestSettings() {
    // Given
    var timer = readyAtFocus(2)
    timer.start(at: at("09:30"))
    var settings = TimerSettings()
    settings.focusMinutes = 30
    timer.apply(settings)

    // When
    _ = timer.reset(at: at("09:45"))

    // Then
    #expect(timer.remainingSeconds(at: at("09:45")) == 30 * 60)
}

@Test("Given Short Break 3/4 Running with done 3, when a New Cycle is started, then the timer is at Focus 1/4, Ready, with done 0")
func newCycleGoesBackToTheFirstFocus() {
    // Given
    var timer = readyAtFocus(3)
    _ = runPhase(&timer, from: at("10:00"), minutes: 25)
    timer.start(at: at("10:25"))

    // When
    let pomodoros = timer.newCycle(at: at("10:27"))

    // Then
    #expect(pomodoros.isEmpty)
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 1)
    #expect(timer.pomodorosDone == 0)
    #expect(timer.status == .ready)
    #expect(timer.remainingSeconds(at: at("10:30")) == 25 * 60)
}
