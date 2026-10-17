import CoreGraphics
import Foundation
import Testing
import Core

// state.json, version 1 (spec P1).

/// The spec's sample: Focus 2/4, started, 14:02 left of 25:00, the capsule at (720, 844).
private let sample = SavedState(
    timer: TimerSnapshot(
        phase: .focus, displayNumber: 2, pomodorosDone: 1, pomodorosPerCycle: 4,
        phaseLengthSeconds: 1500, remainingSeconds: 842, hasStarted: true
    ),
    floatingWindow: FloatingWindowState(visible: true, alwaysOnTop: true, center: CGPoint(x: 720, y: 844))
)

/// No file: Focus 1/4 at 25:00, Ready; the Floating Window showing, on top, at the starting position.
private let freshStart = SavedState(
    timer: TimerSnapshot(
        phase: .focus, displayNumber: 1, pomodorosDone: 0, pomodorosPerCycle: 4,
        phaseLengthSeconds: 1500, remainingSeconds: 1500, hasStarted: false
    ),
    floatingWindow: FloatingWindowState(visible: true, alwaysOnTop: true, center: nil)
)

@Test("Given the version 1 sample state.json from the spec, when it is loaded, then it is Focus 2/4 with 1 Pomodoro done, 842 of 1500 seconds left and started, and the Floating Window shows, on top, centred at (720, 844)")
func theSampleStateFileAlwaysReads() {
    // Given
    let data = fixture("state.json")

    // When
    let loaded = StateFile.decode(data, settings: TimerSettings())

    // Then
    #expect(loaded.value == sample)
    #expect(loaded.moveAside == false)
}

@Test("Given a Short Break 3/4 Ready with 2 Pomodoros done, the Floating Window not on top at (300.5, 400) and the hide notice already shown, when it is saved and loaded back, then every value is the same")
func savedStateLoadsBack() {
    // Given
    let state = SavedState(
        timer: TimerSnapshot(
            phase: .shortBreak, displayNumber: 3, pomodorosDone: 2, pomodorosPerCycle: 4,
            phaseLengthSeconds: 300, remainingSeconds: 300, hasStarted: false
        ),
        floatingWindow: FloatingWindowState(
            visible: true, alwaysOnTop: false, center: CGPoint(x: 300.5, y: 400), hideNoticeShown: true
        )
    )

    // When
    let loaded = StateFile.decode(StateFile.encode(state), settings: TimerSettings())

    // Then
    #expect(loaded.value == state)
    #expect(loaded.moveAside == false)
}

@Test("Given the spec's sample state, when it is saved, then the file holds exactly the keys and values of the spec's sample state.json")
func savedStateMatchesTheSampleFormat() throws {
    // Given
    let state = sample

    // When
    let data = StateFile.encode(state)

    // Then
    let saved = try #require(try JSONSerialization.jsonObject(with: data) as? NSDictionary)
    let expected = try #require(try JSONSerialization.jsonObject(with: fixture("state.json")) as? NSDictionary)
    #expect(saved == expected)
}

@Test("Given a capsule that was never moved, when the state is saved, then the file says \"center\": null")
func aCapsuleNeverMovedIsSavedAsNull() throws {
    // Given
    var state = sample
    state.floatingWindow.center = nil

    // When
    let data = StateFile.encode(state)

    // Then
    let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    let window = try #require(json["floatingWindow"] as? [String: Any])
    #expect(window["center"] is NSNull)
}

@Test("Given Focus 2/4 with 1 Pomodoro done, started at 09:00 at 25:00 and still Running, when it is saved at 09:10:58 and the app opens again at 12:00, then it is Paused with 842 seconds (14:02) left")
func stateSavedWhileRunningLoadsBackPaused() {
    // Given
    var timer = PomodoroTimer()
    _ = runPhase(&timer, from: at("08:30"), minutes: 25)
    _ = timer.skip(at: at("08:55"))
    timer.start(at: at("09:00"))

    // When
    let data = StateFile.encode(SavedState(timer: timer.snapshot(at: at("09:10:58")), floatingWindow: FloatingWindowState()))
    let reopened = PomodoroTimer(restoring: StateFile.decode(data, settings: TimerSettings()).value.timer, settings: TimerSettings())

    // Then
    #expect(reopened.status == .paused)
    #expect(reopened.phase == .focus)
    #expect(reopened.displayNumber == 2)
    #expect(reopened.pomodorosDone == 1)
    #expect(reopened.remainingSeconds(at: at("12:00")) == 842)
}

@Test("Given the sample state of Focus 2/4 and Settings since changed to 6 Pomodoros per Cycle, when the app opens again, then it is still 2/4, not 2/6")
func theCycleKeepsItsOwnPomodorosPerCycle() {
    // Given
    var settings = TimerSettings()
    settings.pomodorosPerCycle = 6

    // When
    let state = StateFile.decode(fixture("state.json"), settings: settings).value
    let timer = PomodoroTimer(restoring: state.timer, settings: settings)

    // Then
    #expect(timer.displayNumber == 2)
    #expect(timer.pomodorosPerCycle == 4)
}

@Test("Given there is no state.json yet, when the state is loaded, then it is Focus 1/4 at 25:00 Ready, and the Floating Window shows, on top, at the starting position")
func noStateFileMeansAFreshStart() {
    // Given
    let data: Data? = nil

    // When
    let loaded = StateFile.decode(data, settings: TimerSettings())
    let timer = PomodoroTimer(restoring: loaded.value.timer, settings: TimerSettings())

    // Then
    #expect(timer.phase == .focus)
    #expect(timer.displayNumber == 1)
    #expect(timer.pomodorosDone == 0)
    #expect(timer.pomodorosPerCycle == 4)
    #expect(timer.status == .ready)
    #expect(timer.remainingSeconds(at: at("09:00")) == 25 * 60)
    #expect(loaded.value.floatingWindow == FloatingWindowState(visible: true, alwaysOnTop: true, center: nil))
    #expect(loaded.moveAside == false)
}

@Test("Given a state.json that isn't JSON, when the state is loaded, then it is a fresh start and the file is to be moved aside")
func unreadableStateFileIsMovedAside() {
    // Given
    let data = Data(#"{ "version": 1, "timer": { "phase": "focus""#.utf8)

    // When
    let loaded = StateFile.decode(data, settings: TimerSettings())

    // Then
    #expect(loaded.value == freshStart)
    #expect(loaded.moveAside == true)
}

@Test("Given a state.json at version 2 from a newer Pomodot, when the state is loaded, then it is a fresh start and the file is to be moved aside")
func newerStateFileIsMovedAside() {
    // Given
    let data = Data("""
    {
      "version": 2,
      "timer": { "phase": "longBreak", "displayNumber": 4, "pomodorosDone": 4, "pomodorosPerCycle": 4,
                 "phaseLengthSeconds": 900, "remainingSeconds": 60, "hasStarted": true },
      "floatingWindow": { "visible": false, "alwaysOnTop": false, "center": { "x": 300, "y": 400 } }
    }
    """.utf8)

    // When
    let loaded = StateFile.decode(data, settings: TimerSettings())

    // Then
    #expect(loaded.value == freshStart)
    #expect(loaded.moveAside == true)
}

@Test("Given the sample state.json but with remainingSeconds -5, when the state is loaded, then only the time left goes back to the full 1500 seconds and everything else is kept")
func aWrongTimeLeftIsFixedOnItsOwn() {
    // Given
    let data = Data(String(decoding: fixture("state.json"), as: UTF8.self)
        .replacingOccurrences(of: "\"remainingSeconds\": 842", with: "\"remainingSeconds\": -5").utf8)

    // When
    let loaded = StateFile.decode(data, settings: TimerSettings())

    // Then
    var expected = sample
    expected.timer.remainingSeconds = 1500
    #expect(loaded.value == expected)
    #expect(loaded.moveAside == false)
}

@Test("Given a state.json with no floatingWindow, a phase of \"nap\" and no hasStarted, when the state is loaded, then only those take their defaults: Focus, Ready, the Floating Window showing on top at the starting position")
func missingAndWrongValuesTakeTheirDefaultsAlone() {
    // Given
    let data = Data("""
    {
      "version": 1,
      "timer": { "phase": "nap", "displayNumber": 3, "pomodorosDone": 2, "pomodorosPerCycle": 4,
                 "phaseLengthSeconds": 1500, "remainingSeconds": 600 }
    }
    """.utf8)

    // When
    let loaded = StateFile.decode(data, settings: TimerSettings())

    // Then
    #expect(loaded.value == SavedState(
        timer: TimerSnapshot(
            phase: .focus, displayNumber: 3, pomodorosDone: 2, pomodorosPerCycle: 4,
            phaseLengthSeconds: 1500, remainingSeconds: 600, hasStarted: false
        ),
        floatingWindow: FloatingWindowState(visible: true, alwaysOnTop: true, center: nil)
    ))
    #expect(loaded.moveAside == false)
}

@Test("Given a state.json whose floatingWindow says visible is \"yes\" and alwaysOnTop is false, when the state is loaded, then the Floating Window shows (the default) and stays off top")
func aValueOfTheWrongTypeIsFixedOnItsOwn() {
    // Given
    let data = Data(String(decoding: fixture("state.json"), as: UTF8.self)
        .replacingOccurrences(of: "\"visible\": true", with: "\"visible\": \"yes\"")
        .replacingOccurrences(of: "\"alwaysOnTop\": true", with: "\"alwaysOnTop\": false").utf8)

    // When
    let loaded = StateFile.decode(data, settings: TimerSettings())

    // Then
    var expected = sample
    expected.floatingWindow.alwaysOnTop = false
    #expect(loaded.value == expected)
    #expect(loaded.moveAside == false)
}

@Test("Given the sample state.json but with 11 Pomodoros per Cycle and a 121-minute Phase, beyond what Settings allow (1–10, 1–120 minutes), when the state is loaded, then those two take their defaults, 4 and 1500 seconds, and the rest is kept")
func valuesBeyondWhatSettingsAllowAreFixed() {
    // Given
    let data = Data(String(decoding: fixture("state.json"), as: UTF8.self)
        .replacingOccurrences(of: "\"pomodorosPerCycle\": 4", with: "\"pomodorosPerCycle\": 11")
        .replacingOccurrences(of: "\"phaseLengthSeconds\": 1500", with: "\"phaseLengthSeconds\": 7260").utf8)

    // When
    let loaded = StateFile.decode(data, settings: TimerSettings())

    // Then
    #expect(loaded.value == sample)
    #expect(loaded.moveAside == false)
}

// MARK: M6: the capsule shows on every launch

@Test("Given a state.json saved with the Floating Window hidden, off top and moved to (300, 400), when the state is loaded, then the Floating Window shows, still off top at (300, 400)")
func hiddenFloatingWindowShowsOnLaunch() {
    // Given
    let data = Data(String(decoding: fixture("state.json"), as: UTF8.self)
        .replacingOccurrences(of: "\"visible\": true", with: "\"visible\": false")
        .replacingOccurrences(of: "\"alwaysOnTop\": true", with: "\"alwaysOnTop\": false")
        .replacingOccurrences(of: "{ \"x\": 720, \"y\": 844 }", with: "{ \"x\": 300, \"y\": 400 }")
        .utf8)

    // When
    let window = StateFile.decode(data, settings: TimerSettings()).value.floatingWindow

    // Then
    #expect(window == FloatingWindowState(visible: true, alwaysOnTop: false, center: CGPoint(x: 300, y: 400)))
}

@Test("Given the Floating Window is hidden, when the state is saved, then state.json still says visible is false")
func hiddenIsStillWritten() throws {
    // Given
    var state = sample
    state.floatingWindow.visible = false

    // When
    let data = StateFile.encode(state)

    // Then
    let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    let window = try #require(json["floatingWindow"] as? [String: Any])
    #expect(window["visible"] as? Bool == false)
}

@Test("Given a state.json from 0.9.0 with no hideNoticeShown, when the state is loaded, then the notice counts as never shown")
func missingHideNoticeShownIsFalse() {
    // Given
    let data = Data(String(decoding: fixture("state.json"), as: UTF8.self)
        .replacingOccurrences(of: ",\n    \"hideNoticeShown\": false", with: "")
        .utf8)

    // When
    let window = StateFile.decode(data, settings: TimerSettings()).value.floatingWindow

    // Then
    #expect(!String(decoding: data, as: UTF8.self).contains("hideNoticeShown"))
    #expect(window.hideNoticeShown == false)
}

@Test("Given the sample state.json with hideNoticeShown true, when the state is loaded, then the notice counts as shown")
func hideNoticeShownLoads() {
    // Given
    let data = Data(String(decoding: fixture("state.json"), as: UTF8.self)
        .replacingOccurrences(of: "\"hideNoticeShown\": false", with: "\"hideNoticeShown\": true")
        .utf8)

    // When
    let window = StateFile.decode(data, settings: TimerSettings()).value.floatingWindow

    // Then
    #expect(window.hideNoticeShown == true)
}

