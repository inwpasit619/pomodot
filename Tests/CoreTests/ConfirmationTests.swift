import Foundation
import Testing
import Core

@Test("Given Focus 1/4 Ready, when Reset is chosen, then it happens without asking")
func resetWhenReadyDoesNotAsk() {
    // Given
    let timer = PomodoroTimer()

    // When
    let confirmation = timer.resetConfirmation

    // Then
    #expect(confirmation == nil)
}

@Test("Given a Focus that is Running or Paused, when Reset is chosen, then it asks first")
func resetOfAStartedPhaseAsks() {
    // Given
    var running = PomodoroTimer()
    running.start(at: at("09:00"))
    var paused = running
    _ = paused.pause(at: at("09:05"))

    // When
    let confirmations = [running.resetConfirmation, paused.resetConfirmation]

    // Then
    #expect(confirmations.allSatisfy { $0 != nil })
}

@Test("Given a 25-minute Focus that is Running, when Reset is chosen, then it asks 'Reset this Focus?' and says it will go back to 25:00 and won't count as a Pomodoro")
func resetFocusConfirmationText() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let confirmation = timer.resetConfirmation

    // Then
    #expect(confirmation == Confirmation(
        title: "Reset this Focus?",
        message: "It will go back to 25:00. It won't count as a Pomodoro.",
        confirmButtonTitle: "Reset"
    ))
}

@Test("Given a Short Break that is Paused and Short Break changed to 7 minutes in Settings, when Reset is chosen, then it asks 'Reset this Short Break?' and says it will go back to 07:00")
func resetBreakConfirmationTextUsesTheLatestSettings() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    timer.start(at: at("09:25"))
    _ = timer.pause(at: at("09:27"))
    var settings = TimerSettings()
    settings.shortBreakMinutes = 7
    timer.apply(settings)

    // When
    let confirmation = timer.resetConfirmation

    // Then
    #expect(confirmation == Confirmation(
        title: "Reset this Short Break?",
        message: "It will go back to 07:00.",
        confirmButtonTitle: "Reset"
    ))
}

@Test("Given Focus 1/4 Ready with done 0, when New Cycle is chosen, then it happens without asking")
func newCycleWithNoProgressDoesNotAsk() {
    // Given
    let timer = PomodoroTimer()

    // When
    let confirmation = timer.newCycleConfirmation

    // Then
    #expect(confirmation == nil)
}

@Test("Given Focus 2/4 Ready with done 1, when New Cycle is chosen, then it asks 'Start a new Cycle?' and says History is kept")
func newCycleWithAPomodoroAsks() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    _ = runPhase(&timer, from: at("09:25"), minutes: 5)

    // When
    let confirmation = timer.newCycleConfirmation

    // Then
    #expect(confirmation == Confirmation(
        title: "Start a new Cycle?",
        message: "Progress in this Cycle will be cleared. Your History is kept.",
        confirmButtonTitle: "New Cycle"
    ))
}

@Test("Given Short Break 1/4 Ready with done 0 after Focus 1/4 was skipped, when New Cycle is chosen, then it happens without asking")
func newCycleAfterSkippingTheFirstFocusDoesNotAsk() {
    // Given
    var timer = PomodoroTimer()
    _ = timer.skip(at: at("09:00"))

    // When
    let confirmation = timer.newCycleConfirmation

    // Then
    #expect(confirmation == nil)
}

@Test("Given Focus 1/4 Running with done 0, when New Cycle is chosen, then it asks first")
func newCycleWhileTheFirstFocusRunsAsks() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let confirmation = timer.newCycleConfirmation

    // Then
    #expect(confirmation != nil)
}

// Reset… and New Cycle… are greyed out when pressing them would change nothing.

@Test("Given Focus 1/4 Ready with done 0, when the menu opens, then Reset… and New Cycle… are greyed out, since pressing them would change nothing")
func nothingToResetOrClearAtTheStartOfACycle() {
    // Given
    let timer = PomodoroTimer()

    // When
    let canReset = timer.canReset
    let canStartNewCycle = timer.canStartNewCycle

    // Then
    #expect(canReset == false)
    #expect(canStartNewCycle == false)
}

@Test("Given Short Break 1/4 Ready with done 0 after Focus 1/4 was skipped, when the menu opens, then Reset… is greyed out but New Cycle… can be pressed, since it goes back to Focus 1/4")
func newCycleCanBePressedFromABreakThatHasNotStarted() {
    // Given
    var timer = PomodoroTimer()
    _ = timer.skip(at: at("09:00"))

    // When
    let canReset = timer.canReset
    let canStartNewCycle = timer.canStartNewCycle

    // Then
    #expect(canReset == false)
    #expect(canStartNewCycle == true)
}

@Test("Given Focus 2/4 Ready with done 1, when the menu opens, then Reset… is greyed out but New Cycle… can be pressed")
func newCycleCanBePressedOnceAPomodoroIsDone() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    _ = runPhase(&timer, from: at("09:25"), minutes: 5)

    // When
    let canReset = timer.canReset
    let canStartNewCycle = timer.canStartNewCycle

    // Then
    #expect(canReset == false)
    #expect(canStartNewCycle == true)
}

@Test("Given Focus 1/4 that is Running or Paused, when the menu opens, then Reset… and New Cycle… can both be pressed")
func bothCanBePressedOnceThePhaseHasStarted() {
    // Given
    var running = PomodoroTimer()
    running.start(at: at("09:00"))
    var paused = running
    _ = paused.pause(at: at("09:05"))

    // When
    let timers = [running, paused]

    // Then
    #expect(timers.allSatisfy { $0.canReset && $0.canStartNewCycle })
}
