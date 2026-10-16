import Foundation
import Testing
import Core

// The sound and the banner when a Phase runs out by itself.

@Test("Given Focus 2/4 is Running and Start Breaks automatically is off, when it runs out, then the banner reads \"Focus complete 🍅 2/4\" / \"Time for a 5-minute Short Break.\" and the Focus sound plays")
func aFocusRunningOutBeforeAShortBreakThatWaits() throws {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    _ = runPhase(&timer, from: at("09:25"), minutes: 5)
    timer.start(at: at("09:30"))

    // When
    let outcome = timer.tick(at: at("09:55"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.sound == .focus)
    #expect(ranOut.banner(showNotifications: true) == Banner(title: "Focus complete 🍅 2/4", body: "Time for a 5-minute Short Break."))
}

@Test("Given Focus 2/4 is Running and Start Breaks automatically is on, when it runs out, then the banner reads \"Focus complete 🍅 2/4\" / \"5-minute Short Break started.\"")
func aFocusRunningOutIntoAShortBreakThatStartsByItself() throws {
    // Given
    var settings = TimerSettings()
    settings.autoStartBreaks = true
    var timer = PomodoroTimer(settings: settings)
    _ = runPhase(&timer, from: at("09:00"), minutes: 30)
    timer.start(at: at("09:30"))

    // When
    let outcome = timer.tick(at: at("09:55"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.banner(showNotifications: true) == Banner(title: "Focus complete 🍅 2/4", body: "5-minute Short Break started."))
}

/// Focus 4/4 Running from 10:30, after three Pomodoros and their Short Breaks from 09:00.
private func runningLastFocus(settings: TimerSettings = TimerSettings()) -> PomodoroTimer {
    var timer = PomodoroTimer(settings: settings)
    var start = at("09:00")
    for _ in 1...3 {
        _ = runPhase(&timer, from: start, minutes: 25)
        if timer.status == .ready {
            timer.start(at: start.addingTimeInterval(25 * 60))
        }
        _ = timer.tick(at: start.addingTimeInterval(30 * 60))
        start.addTimeInterval(30 * 60)
    }
    timer.start(at: at("10:30"))
    return timer
}

@Test("Given Focus 4/4 is Running and Start Breaks automatically is off, when it runs out, then the banner reads \"Cycle complete 🍅 4/4\" / \"Time for a 15-minute Long Break.\"")
func theLastFocusRunningOutBeforeALongBreakThatWaits() throws {
    // Given
    var timer = runningLastFocus()

    // When
    let outcome = timer.tick(at: at("10:55"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.banner(showNotifications: true) == Banner(title: "Cycle complete 🍅 4/4", body: "Time for a 15-minute Long Break."))
}

@Test("Given Focus 4/4 is Running and Start Breaks automatically is on, when it runs out, then the banner reads \"Cycle complete 🍅 4/4\" / \"15-minute Long Break started.\"")
func theLastFocusRunningOutIntoALongBreakThatStartsByItself() throws {
    // Given
    var settings = TimerSettings()
    settings.autoStartBreaks = true
    var timer = runningLastFocus(settings: settings)

    // When
    let outcome = timer.tick(at: at("10:55"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.banner(showNotifications: true) == Banner(title: "Cycle complete 🍅 4/4", body: "15-minute Long Break started."))
}

@Test("Given Short Break 2/4 is Running and Start Focus automatically is off, when it runs out, then the banner reads \"Break over\" / \"Time for Focus 3/4.\" and the Break sound plays")
func aShortBreakRunningOutBeforeAFocusThatWaits() throws {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    _ = runPhase(&timer, from: at("09:25"), minutes: 5)
    _ = runPhase(&timer, from: at("09:30"), minutes: 25)
    timer.start(at: at("09:55"))

    // When
    let outcome = timer.tick(at: at("10:00"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.sound == .break)
    #expect(ranOut.banner(showNotifications: true) == Banner(title: "Break over", body: "Time for Focus 3/4."))
}

@Test("Given Short Break 2/4 is Running and Start Focus automatically is on, when it runs out, then the banner reads \"Break over\" / \"Focus 3/4 started.\"")
func aShortBreakRunningOutIntoAFocusThatStartsByItself() throws {
    // Given
    var settings = TimerSettings()
    settings.autoStartFocus = true
    var timer = PomodoroTimer(settings: settings)
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    timer.start(at: at("09:25"))
    _ = timer.tick(at: at("09:55"))
    timer.start(at: at("09:55"))

    // When
    let outcome = timer.tick(at: at("10:00"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.banner(showNotifications: true) == Banner(title: "Break over", body: "Focus 3/4 started."))
}

@Test("Given Long Break 4/4 is Running with both automatic starts on, when it runs out, then the banner reads \"Long Break over\" / \"Ready for a new Cycle.\" and the Break sound plays")
func theLongBreakRunningOutAlwaysWaits() throws {
    // Given
    var settings = TimerSettings()
    settings.autoStartBreaks = true
    settings.autoStartFocus = true
    var timer = runningLastFocus(settings: settings)
    _ = timer.tick(at: at("10:55"))

    // When
    let outcome = timer.tick(at: at("11:10"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.sound == .break)
    #expect(ranOut.banner(showNotifications: true) == Banner(title: "Long Break over", body: "Ready for a new Cycle."))
}

@Test("Given Short Break is 7 minutes and Focus 1/4 is Running, when it runs out, then the banner body reads \"Time for a 7-minute Short Break.\"")
func theBannerUsesTheShortBreakLengthFromSettings() throws {
    // Given
    var settings = TimerSettings()
    settings.shortBreakMinutes = 7
    var timer = PomodoroTimer(settings: settings)
    timer.start(at: at("09:00"))

    // When
    let outcome = timer.tick(at: at("09:25"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.banner(showNotifications: true)?.body == "Time for a 7-minute Short Break.")
}

@Test("Given 6 Pomodoros per Cycle and Focus 6/6 is Running, when it runs out, then the banner title reads \"Cycle complete 🍅 6/6\"")
func theBannerUsesTheCycleLengthFromSettings() throws {
    // Given
    var settings = TimerSettings()
    settings.pomodorosPerCycle = 6
    var timer = PomodoroTimer(settings: settings)
    var start = at("09:00")
    for _ in 1...5 {
        _ = runPhase(&timer, from: start, minutes: 25)
        _ = runPhase(&timer, from: start.addingTimeInterval(25 * 60), minutes: 5)
        start.addTimeInterval(30 * 60)
    }
    timer.start(at: at("11:30"))

    // When
    let outcome = timer.tick(at: at("11:55"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.banner(showNotifications: true)?.title == "Cycle complete 🍅 6/6")
}

@Test("Given Show notifications is off, when a Focus runs out, then there is no banner but the Focus sound still plays")
func noBannerWhenNotificationsAreOffButTheFocusSoundPlays() throws {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let outcome = timer.tick(at: at("09:25"))

    // Then
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.banner(showNotifications: false) == nil)
    #expect(ranOut.sound == .focus)
}

@Test("Given Focus 1/4 is Running, when it is skipped, then nothing is announced: no sound and no banner")
func skippingIsNotAnnounced() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let outcome = timer.skip(at: at("09:10"))

    // Then
    #expect(outcome.ranOut == nil)
}

@Test("Given Short Break 1/4 is Running, when it is skipped, then nothing is announced")
func skippingABreakIsNotAnnounced() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    timer.start(at: at("09:25"))

    // When
    let outcome = timer.skip(at: at("09:27"))

    // Then
    #expect(outcome.ranOut == nil)
}

@Test("Given Focus 1/4 is Running, when it is reset, then nothing is announced")
func resettingIsNotAnnounced() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let outcome = timer.reset(at: at("09:10"))

    // Then
    #expect(outcome.ranOut == nil)
}

@Test("Given Focus 2/4 is Running, when a New Cycle is started, then nothing is announced")
func aNewCycleIsNotAnnounced() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("09:00"), minutes: 25)
    _ = runPhase(&timer, from: at("09:25"), minutes: 5)
    timer.start(at: at("09:30"))

    // When
    let outcome = timer.newCycle(at: at("09:40"))

    // Then
    #expect(outcome.ranOut == nil)
}

@Test("Given Focus 1/4 is Running, when the Mac sleeps and the timer pauses itself, then nothing is announced")
func sleepIsNotAnnounced() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let outcome = timer.sleep(at: at("09:10"))

    // Then
    #expect(outcome.ranOut == nil)
}

@Test("Given both automatic starts are on and Focus 1/4 is Running from 09:00, when the next tick comes late at 09:31, then only the Short Break that ran out last is announced: \"Break over\" / \"Focus 2/4 started.\" with the Break sound")
func aLateTickAnnouncesOnlyTheLastPhaseThatRanOut() throws {
    // Given
    var settings = TimerSettings()
    settings.autoStartBreaks = true
    settings.autoStartFocus = true
    var timer = PomodoroTimer(settings: settings)
    timer.start(at: at("09:00"))

    // When
    let outcome = timer.tick(at: at("09:31"))

    // Then
    #expect(outcome.pomodoros.count == 1)
    let ranOut = try #require(outcome.ranOut)
    #expect(ranOut.sound == .break)
    #expect(ranOut.banner(showNotifications: true) == Banner(title: "Break over", body: "Focus 2/4 started."))
}

@Test("Given Focus 1/4 is Running, when a tick comes before it runs out, then nothing is announced")
func aTickBeforeTheEndIsNotAnnounced() {
    // Given
    var timer = PomodoroTimer()
    timer.start(at: at("09:00"))

    // When
    let outcome = timer.tick(at: at("09:24:59"))

    // Then
    #expect(outcome.ranOut == nil)
}

@Test("Given the default Settings, when a sound plays, then the end of a Focus plays Glass and the end of a Break plays Hero")
func theDefaultSoundsAreGlassAndHero() {
    // Given, When, Then
    #expect(Sound.focus.defaultSystemSoundName == "Glass")
    #expect(Sound.break.defaultSystemSoundName == "Hero")
}
