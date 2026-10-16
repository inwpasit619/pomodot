import Foundation
import Testing
import Core

// The Expected finish table from the spec, with the default 25 / 5 / 15 / 4 Settings.

/// Focus 2/4 (done 1) started at 13:45, so 10:00 is left at 14:00.
private func focusTwoRunning() -> PomodoroTimer {
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("13:00"), minutes: 25)
    _ = runPhase(&timer, from: at("13:25"), minutes: 5)
    timer.start(at: at("13:45"))
    return timer
}

@Test("Given Focus 1/4 Ready at full length, when it is 09:00, then the Phase ends 09:25 and the Cycle ends 11:10")
func expectedFinishOfAFreshCycle() {
    // Given
    let timer = PomodoroTimer()

    // When
    let finish = timer.expectedFinish(at: at("09:00"))

    // Then
    #expect(finish.phaseEnds == at("09:25"))
    #expect(finish.cycleEnds == at("11:10"))
}

@Test("Given Focus 2/4 Running (done 1) with 10:00 left, when it is 14:00, then the Phase ends 14:10 and the Cycle ends 15:25")
func expectedFinishWhileRunning() {
    // Given
    let timer = focusTwoRunning()

    // When
    let finish = timer.expectedFinish(at: at("14:00"))

    // Then
    #expect(finish.phaseEnds == at("14:10"))
    #expect(finish.cycleEnds == at("15:25"))
}

@Test("Given Focus 2/4 Running as above, when 5 minutes pass with no Pause and it is 14:05, then the Phase still ends 14:10 and the Cycle still ends 15:25")
func expectedFinishStaysPutWhileRunning() {
    // Given
    let timer = focusTwoRunning()

    // When
    let finish = timer.expectedFinish(at: at("14:05"))

    // Then
    #expect(finish.phaseEnds == at("14:10"))
    #expect(finish.cycleEnds == at("15:25"))
}

@Test("Given Focus 2/4 Paused at 14:00 with 10:00 left, when it is 14:20, then the Phase ends 14:30 and the Cycle ends 15:45")
func expectedFinishMovesOnWhilePaused() {
    // Given
    var timer = focusTwoRunning()
    _ = timer.pause(at: at("14:00"))

    // When
    let finish = timer.expectedFinish(at: at("14:20"))

    // Then
    #expect(finish.phaseEnds == at("14:30"))
    #expect(finish.cycleEnds == at("15:45"))
}

@Test("Given Focus 2/4 (done 1) is skipped at 14:00, so Short Break 2/4 is Ready, when it is 14:00, then the Phase ends 14:05 and the Cycle ends 15:45")
func skippingAFocusPushesTheCycleBack() {
    // Given
    var timer = focusTwoRunning()
    _ = timer.skip(at: at("14:00"))

    // When
    let finish = timer.expectedFinish(at: at("14:00"))

    // Then
    #expect(finish.phaseEnds == at("14:05"))
    #expect(finish.cycleEnds == at("15:45"))
}

@Test("Given Focus 2/4 ran to the end at 14:00 (done 2), so Short Break 2/4 is Ready, when it is 14:00, then the Phase ends 14:05 and the Cycle ends 15:15")
func expectedFinishAfterAPomodoro() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("13:00"), minutes: 25)
    _ = runPhase(&timer, from: at("13:25"), minutes: 5)
    _ = runPhase(&timer, from: at("13:35"), minutes: 25)

    // When
    let finish = timer.expectedFinish(at: at("14:00"))

    // Then
    #expect(finish.phaseEnds == at("14:05"))
    #expect(finish.cycleEnds == at("15:15"))
}

@Test("Given Long Break 4/4 Running with 07:00 left, when it is 16:00, then the Phase and the Cycle both end 16:07")
func expectedFinishInTheLongBreak() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("10:00"), minutes: 25)
    _ = runPhase(&timer, from: at("10:25"), minutes: 5)
    _ = runPhase(&timer, from: at("10:30"), minutes: 25)
    _ = runPhase(&timer, from: at("10:55"), minutes: 5)
    _ = runPhase(&timer, from: at("11:00"), minutes: 25)
    _ = runPhase(&timer, from: at("11:25"), minutes: 5)
    _ = runPhase(&timer, from: at("11:30"), minutes: 25)
    timer.start(at: at("15:52"))

    // When
    let finish = timer.expectedFinish(at: at("16:00"))

    // Then
    #expect(timer.phase == .longBreak)
    #expect(finish.phaseEnds == at("16:07"))
    #expect(finish.cycleEnds == at("16:07"))
}

@Test("Given Focus 2/4 Running with 10:00 left at 14:00, when Settings change to 30-minute Focuses and 6 per Cycle, then the Phase still ends 14:10 and the Cycle ends 15:35: later Focuses take 30 minutes, but this Cycle still has 4")
func expectedFinishUsesNewLengthsButThisCyclesCount() {
    // Given
    var timer = focusTwoRunning()
    var settings = TimerSettings()
    settings.focusMinutes = 30
    settings.pomodorosPerCycle = 6

    // When
    timer.apply(settings)
    let finish = timer.expectedFinish(at: at("14:00"))

    // Then
    #expect(finish.phaseEnds == at("14:10"))
    #expect(finish.cycleEnds == at("15:35"))
}

@Test("Given Focus 2/4 Running is due to end at 14:10, when it is 14:10:30 and no tick has come yet, then the Phase still ends 14:10 and the Cycle still ends 15:25")
func expectedFinishStaysPutPastTheEndBeforeATick() {
    // Given
    let timer = focusTwoRunning()

    // When
    let finish = timer.expectedFinish(at: at("14:10:30"))

    // Then
    #expect(finish.phaseEnds == at("14:10"))
    #expect(finish.cycleEnds == at("15:25"))
}
