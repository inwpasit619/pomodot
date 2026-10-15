import Foundation
import Testing
import Core

@Test("Given a Focus started at 08:55 and paused at 09:00 with 20:00 left, when it is resumed at 09:10, then it is Running from 20:00 and 15:00 is left at 09:15")
func pauseThenResumeKeepsTheTimeLeft() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("08:55"))
    _ = timer.pause(at: at("09:00"))

    // When
    timer.start(at: at("09:10"))

    // Then
    #expect(timer.status == .running)
    #expect(timer.remainingSeconds(at: at("09:10")) == 20 * 60)
    #expect(timer.remainingSeconds(at: at("09:15")) == 15 * 60)
}

@Test("Given a Focus Ready at 25:00, when the one Start / Pause / Resume button is pressed at 09:00, 09:05 and 09:10, then it goes Running, Paused with 20:00 left, then Running again")
func oneButtonStartsPausesAndResumes() {
    // Given
    var timer = PomodoroTimer()
    var seen: [PhaseStatus] = []

    // When
    for time in ["09:00", "09:05", "09:10"] {
        _ = timer.startPauseResume(at: at(time))
        seen.append(timer.status)
    }

    // Then
    #expect(seen == [.running, .paused, .running])
    #expect(timer.remainingSeconds(at: at("09:10")) == 20 * 60)
}

@Test("Given Focus 1/4 started at 09:00, when it runs to the end, then it is a Pomodoro and the timer is at Short Break 1/4, Ready")
func focusThatRunsOutBecomesAPomodoroAndMovesToShortBreak() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let pomodoros = timer.tick(at: at("09:25"))

    // Then
    #expect(pomodoros.count == 1)
    #expect(timer.phase == .shortBreak)
    #expect(timer.displayNumber == 1)
    #expect(timer.pomodorosDone == 1)
    #expect(timer.status == .ready)
    #expect(timer.remainingSeconds(at: at("09:26")) == 5 * 60)
}

@Test("Given a 25-minute Focus started at 09:00 and never paused, when the first tick after its end comes at 09:25:03, then the Pomodoro ends at 09:25:00")
func pomodoroEndsAtItsScheduledTimeNotAtTheTick() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let pomodoros = timer.tick(at: at("09:25:03"))

    // Then
    #expect(pomodoros == [Pomodoro(end: at("09:25:00"), durationSeconds: 1500)])
}

@Test("Given a Focus started at 09:00 and paused from 09:10 to 09:20, when it runs to the end at 09:35, then it is still a Pomodoro")
func pausedFocusThatRunsOutIsStillAPomodoro() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))
    _ = timer.pause(at: at("09:10"))
    timer.start(at: at("09:20"))

    // When
    let pomodoros = timer.tick(at: at("09:35"))

    // Then
    #expect(pomodoros == [Pomodoro(end: at("09:35"), durationSeconds: 1500)])
    #expect(timer.pomodorosDone == 1)
}

@Test("Given a new Cycle with default Settings, when every Phase runs to the end, then the timer goes Focus 1/4 → Short Break 1/4 → … → Focus 4/4 → Long Break 4/4 → Focus 1/4 Ready with done 0")
func phasesFollowTheNormalOrderThroughACycle() {
    // Given
    var timer = PomodoroTimer()
    var seen: [String] = []
    func note() { seen.append("\(timer.phase) \(timer.displayNumber)/\(timer.pomodorosPerCycle) done \(timer.pomodorosDone) \(timer.status)") }
    note()

    // When
    // Focus 25, Short Break 5, Long Break 15.
    for (hour, minutes) in zip(9..., [25, 5, 25, 5, 25, 5, 25, 15, 25]) {
        _ = runPhase(&timer, from: at("\(hour):00"), minutes: minutes)
        note()
    }

    // Then
    #expect(seen == [
        "focus 1/4 done 0 ready",
        "shortBreak 1/4 done 1 ready",
        "focus 2/4 done 1 ready",
        "shortBreak 2/4 done 2 ready",
        "focus 3/4 done 2 ready",
        "shortBreak 3/4 done 3 ready",
        "focus 4/4 done 3 ready",
        "longBreak 4/4 done 4 ready",
        "focus 1/4 done 0 ready",
        "shortBreak 1/4 done 1 ready",
    ])
}

@Test("Given Start breaks automatically is on and a Focus started at 09:00, when the tick at 09:25:03 finds it ended, then a Short Break is Running from 09:25:00")
func autoStartBreakStartsAtTheScheduledEnd() {
    // Given
    var settings = TimerSettings()
    settings.autoStartBreaks = true
    var timer = PomodoroTimer(settings: settings)
    timer.start(at: at("09:00"))

    // When
    _ = timer.tick(at: at("09:25:03"))

    // Then
    #expect(timer.phase == .shortBreak)
    #expect(timer.status == .running)
    #expect(timer.remainingSeconds(at: at("09:26")) == 4 * 60)
}

@Test("Given Start Focus automatically is on and Short Break 1/4 started at 09:25, when it ends at 09:30, then Focus 2/4 is Running")
func autoStartFocusStartsTheNextFocusAfterAShortBreak() {
    // Given
    var settings = TimerSettings()
    settings.autoStartFocus = true
    var timer = PomodoroTimer(settings: settings)
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    timer.start(at: at("09:25"))

    // When
    _ = timer.tick(at: at("09:30"))

    // Then
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 2)
    #expect(timer.status == .running)
}

@Test("Given Start Focus automatically is on and the Long Break 4/4 started at 10:55, when it ends at 11:10, then Focus 1/4 of a new Cycle is Ready with done 0")
func autoStartFocusStillStopsAfterTheLongBreak() {
    // Given
    var settings = TimerSettings()
    settings.autoStartFocus = true
    var timer = PomodoroTimer(settings: settings)
    timer.start(at: at("09:00"))
    // Each Short Break is started by hand; the Focus after it starts itself.
    for (shortBreakStart, nextFocusEnd) in [("09:25", "09:55"), ("09:55", "10:25"), ("10:25", "10:55")] {
        _ = timer.tick(at: at(shortBreakStart))
        timer.start(at: at(shortBreakStart))
        _ = timer.tick(at: at(nextFocusEnd))
    }
    timer.start(at: at("10:55"))

    // When
    _ = timer.tick(at: at("11:10"))

    // Then
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 1)
    #expect(timer.pomodorosDone == 0)
    #expect(timer.status == .ready)
}

@Test("Given both auto-start switches are on and a Focus started at 09:00, when the first tick comes late at 09:31, then there is one Pomodoro ending 09:25 and Focus 2/4 is Running with 24:00 left")
func lateTickCatchesUpEveryPhaseThatEnded() {
    // Given
    var settings = TimerSettings()
    settings.autoStartBreaks = true
    settings.autoStartFocus = true
    var timer = PomodoroTimer(settings: settings)
    timer.start(at: at("09:00"))

    // When
    let pomodoros = timer.tick(at: at("09:31"))

    // Then
    #expect(pomodoros == [Pomodoro(end: at("09:25"), durationSeconds: 1500)])
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 2)
    #expect(timer.status == .running)
    #expect(timer.remainingSeconds(at: at("09:31")) == 24 * 60)
}

@Test("Given a Focus started at 09:00, when the Mac goes to sleep at 09:10, then it is Paused with 15:00 left, even an hour later, and there is no Pomodoro")
func sleepPausesTheRunningPhase() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let pomodoros = timer.sleep(at: at("09:10"))

    // Then
    #expect(pomodoros.isEmpty)
    #expect(timer.status == .paused)
    #expect(timer.remainingSeconds(at: at("10:10")) == 15 * 60)
    #expect(timer.tick(at: at("10:10")).isEmpty)
}

@Test("Given a Focus started at 09:00 and no tick since, when the Mac goes to sleep at 09:25:01, then the Focus still counts as a Pomodoro ending 09:25:00 and the Short Break 1/4 is Ready")
func sleepAfterTheEndStillRecordsThePomodoro() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let pomodoros = timer.sleep(at: at("09:25:01"))

    // Then
    #expect(pomodoros == [Pomodoro(end: at("09:25"), durationSeconds: 1500)])
    #expect(timer.phase == .shortBreak)
    #expect(timer.status == .ready)
}
