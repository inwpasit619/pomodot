import Foundation
import Testing
import Core

private func settings(focusMinutes: Int = 25, pomodorosPerCycle: Int = 4) -> TimerSettings {
    var settings = TimerSettings()
    settings.focusMinutes = focusMinutes
    settings.pomodorosPerCycle = pomodorosPerCycle
    return settings
}

@Test("Given Focus 2/4 Running since 09:30, when Focus is changed to 30 minutes, then this Focus still ends at 09:55 and Focus 3/4 is 30:00")
func aStartedPhaseKeepsItsLength() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    _ = runPhase(&timer, from: at("09:25"), minutes: 5)
    timer.start(at: at("09:30"))

    // When
    timer.apply(settings(focusMinutes: 30))

    // Then
    #expect(timer.tick(at: at("09:55")).pomodoros == [Pomodoro(end: at("09:55"), durationSeconds: 1500)])
    _ = runPhase(&timer, from: at("09:55"), minutes: 5)
    #expect(timer.displayNumber == 3)
    #expect(timer.remainingSeconds(at: at("10:00")) == 30 * 60)
}

@Test("Given Focus 1/4 Ready and never started, when Focus is changed to 30 minutes, then it reads 30:00 straight away")
func aPhaseNotYetStartedTakesTheNewLength() {
    // Given
    var timer = PomodoroTimer()

    // When
    timer.apply(settings(focusMinutes: 30))

    // Then
    #expect(timer.remainingSeconds(at: at("09:00")) == 30 * 60)
}

@Test("Given Focus 2/4 Ready with done 1, when Pomodoros per Cycle is changed to 6, then this Cycle stays x/4 to its end and the next Cycle is 1/6")
func aNewCycleLengthWaitsForTheNextCycle() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    _ = runPhase(&timer, from: at("09:25"), minutes: 5)

    // When
    timer.apply(settings(pomodorosPerCycle: 6))

    // Then
    #expect(timer.pomodorosPerCycle == 4)
    // Focus 2, Short Break, Focus 3, Short Break, Focus 4, Long Break.
    var start = at("09:30")
    for minutes in [25, 5, 25, 5, 25] {
        _ = runPhase(&timer, from: start, minutes: minutes)
        start.addTimeInterval(TimeInterval(minutes * 60))
        #expect(timer.pomodorosPerCycle == 4)
    }
    #expect(timer.phase == .longBreak)
    _ = runPhase(&timer, from: start, minutes: 15)
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 1)
    #expect(timer.pomodorosPerCycle == 6)
}

@Test("Given Focus 1/4 Ready with done 0, when Pomodoros per Cycle is changed to 6, then it is Focus 1/6 straight away")
func aCycleWithNoProgressTakesTheNewLength() {
    // Given
    var timer = PomodoroTimer()

    // When
    timer.apply(settings(pomodorosPerCycle: 6))

    // Then
    #expect(timer.displayNumber == 1)
    #expect(timer.pomodorosPerCycle == 6)
}
