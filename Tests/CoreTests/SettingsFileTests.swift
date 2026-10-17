import Foundation
import Testing
import Core

// settings.json, version 1 (spec P1).

/// The defaults as the spec lists them: 25 / 5 / 15 / 4, both auto-starts off,
/// Show notifications on, Glass / Hero and Appearance System.
private func expectTheSpecDefaults(_ settings: Settings, sourceLocation: SourceLocation = #_sourceLocation) {
    #expect(settings.timer.focusMinutes == 25, sourceLocation: sourceLocation)
    #expect(settings.timer.shortBreakMinutes == 5, sourceLocation: sourceLocation)
    #expect(settings.timer.longBreakMinutes == 15, sourceLocation: sourceLocation)
    #expect(settings.timer.pomodorosPerCycle == 4, sourceLocation: sourceLocation)
    #expect(settings.timer.autoStartBreaks == false, sourceLocation: sourceLocation)
    #expect(settings.timer.autoStartFocus == false, sourceLocation: sourceLocation)
    #expect(settings.showNotifications == true, sourceLocation: sourceLocation)
    #expect(settings.focusEndSound == "Glass", sourceLocation: sourceLocation)
    #expect(settings.breakEndSound == "Hero", sourceLocation: sourceLocation)
    #expect(settings.appearance == .system, sourceLocation: sourceLocation)
    #expect(settings.showInDock == true, sourceLocation: sourceLocation)
}

@Test("Given the version 1 sample settings.json from the spec, when it is loaded, then it is 25 / 5 / 15 / 4, both auto-starts off, Show notifications on, Glass / Hero and Appearance System")
func theSampleSettingsFileAlwaysReads() {
    // Given
    let data = fixture("settings.json")

    // When
    let loaded = SettingsFile.decode(data)

    // Then
    expectTheSpecDefaults(loaded.value)
    #expect(loaded.moveAside == false)
}

/// Every value changed from its default: 30 / 10 / 20 / 6, both auto-starts on,
/// Show notifications off, no sound at the end of a Focus, Ping after a Break, Dark, Show in Dock off.
private func everyValueChanged() -> Settings {
    var settings = Settings()
    settings.timer.focusMinutes = 30
    settings.timer.shortBreakMinutes = 10
    settings.timer.longBreakMinutes = 20
    settings.timer.pomodorosPerCycle = 6
    settings.timer.autoStartBreaks = true
    settings.timer.autoStartFocus = true
    settings.showNotifications = false
    settings.focusEndSound = nil
    settings.breakEndSound = "Ping"
    settings.appearance = .dark
    settings.showInDock = false
    return settings
}

/// The sample settings.json with some lines swapped, e.g. `("\"focusMinutes\": 25", "\"focusMinutes\": 121")`.
private func sample(_ swaps: (line: String, replacement: String)...) -> Data {
    var text = String(decoding: fixture("settings.json"), as: UTF8.self)
    for swap in swaps {
        precondition(text.contains(swap.line), "the sample has no \(swap.line)")
        text = text.replacingOccurrences(of: swap.line, with: swap.replacement)
    }
    return Data(text.utf8)
}

@Test("Given Settings of 30 / 10 / 20 / 6, both auto-starts on, Show notifications off, no end of Focus sound, Ping after a Break, Dark and Show in Dock off, when they are saved and loaded back, then every value is the same")
func savedSettingsLoadBack() {
    // Given
    let settings = everyValueChanged()

    // When
    let loaded = SettingsFile.decode(SettingsFile.encode(settings))

    // Then
    #expect(loaded.value == settings)
    #expect(loaded.moveAside == false)
}

@Test("Given the default Settings, when they are saved, then the file holds exactly the keys and values of the spec's sample settings.json")
func savedSettingsMatchTheSampleFormat() throws {
    // Given
    let settings = Settings()

    // When
    let data = SettingsFile.encode(settings)

    // Then
    let saved = try #require(try JSONSerialization.jsonObject(with: data) as? NSDictionary)
    let expected = try #require(try JSONSerialization.jsonObject(with: fixture("settings.json")) as? NSDictionary)
    #expect(saved == expected)
}

@Test("Given None chosen for the end of Focus sound, when Settings are saved, then the file says \"focusEndSound\": null")
func noSoundIsSavedAsNull() throws {
    // Given
    var settings = Settings()
    settings.focusEndSound = nil

    // When
    let data = SettingsFile.encode(settings)

    // Then
    let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    #expect(json["focusEndSound"] is NSNull)
}

@Test("Given a settings.json without the breakEndSound key, when Settings are loaded, then the end of Break sound is the default Hero, not None")
func aMissingSoundIsTheDefault() {
    // Given
    let data = sample((#""breakEndSound": "Hero","#, ""))

    // When
    let loaded = SettingsFile.decode(data)

    // Then
    #expect(loaded.value.breakEndSound == "Hero")
    #expect(loaded.moveAside == false)
}

@Test("Given there is no settings.json yet, when Settings are loaded, then they are 25 / 5 / 15 / 4, both auto-starts off, Show notifications on, Glass / Hero and Appearance System")
func noSettingsFileMeansTheDefaults() {
    // Given
    let data: Data? = nil

    // When
    let loaded = SettingsFile.decode(data)

    // Then
    expectTheSpecDefaults(loaded.value)
    #expect(loaded.moveAside == false)
}

@Test("Given a settings.json with every value changed but no appearance key, when Settings are loaded, then Appearance is System and every other value is kept")
func aMissingAppearanceIsSystem() throws {
    // Given
    var json = try #require(
        try JSONSerialization.jsonObject(with: SettingsFile.encode(everyValueChanged())) as? [String: Any]
    )
    json["appearance"] = nil
    let data = try JSONSerialization.data(withJSONObject: json)

    // When
    let loaded = SettingsFile.decode(data)

    // Then
    var expected = everyValueChanged()
    expected.appearance = .system
    #expect(loaded.value == expected)
    #expect(loaded.moveAside == false)
}

@Test("Given a settings.json with focusMinutes out of range and Short Break 10 minutes, when Settings are loaded, then Focus is 25 minutes and Short Break is still 10", arguments: [-5, 121])
func aFocusLengthOutOfRangeIs25(focusMinutes: Int) {
    // Given
    let data = sample(
        (#""focusMinutes": 25"#, #""focusMinutes": \#(focusMinutes)"#),
        (#""shortBreakMinutes": 5"#, #""shortBreakMinutes": 10"#)
    )

    // When
    let loaded = SettingsFile.decode(data)

    // Then
    #expect(loaded.value.timer.focusMinutes == 25)
    #expect(loaded.value.timer.shortBreakMinutes == 10)
    #expect(loaded.moveAside == false)
}

@Test("Given a settings.json with pomodorosPerCycle out of range and Focus 30 minutes, when Settings are loaded, then it is 4 Pomodoros per Cycle and Focus is still 30", arguments: [0, 11])
func aCycleLengthOutOfRangeIs4(pomodorosPerCycle: Int) {
    // Given
    let data = sample(
        (#""pomodorosPerCycle": 4"#, #""pomodorosPerCycle": \#(pomodorosPerCycle)"#),
        (#""focusMinutes": 25"#, #""focusMinutes": 30"#)
    )

    // When
    let loaded = SettingsFile.decode(data)

    // Then
    #expect(loaded.value.timer.pomodorosPerCycle == 4)
    #expect(loaded.value.timer.focusMinutes == 30)
    #expect(loaded.moveAside == false)
}

@Test("Given a settings.json that isn't JSON, when Settings are loaded, then they are the defaults and the file is to be moved aside")
func unreadableSettingsFileIsMovedAside() {
    // Given
    let data = Data(#"{ "version": 1, "focusMinutes": 30"#.utf8)

    // When
    let loaded = SettingsFile.decode(data)

    // Then
    expectTheSpecDefaults(loaded.value)
    #expect(loaded.moveAside == true)
}

@Test("Given a settings.json at version 2 from a newer Pomodot, when Settings are loaded, then they are the defaults and the file is to be moved aside")
func newerSettingsFileIsMovedAside() {
    // Given
    let data = sample((#""version": 1"#, #""version": 2"#), (#""focusMinutes": 25"#, #""focusMinutes": 30"#))

    // When
    let loaded = SettingsFile.decode(data)

    // Then
    expectTheSpecDefaults(loaded.value)
    #expect(loaded.moveAside == true)
}

@Test("Given Settings with every value changed, when Restore Defaults is pressed, then they are 25 / 5 / 15 / 4, both auto-starts off, Show notifications on, Glass / Hero and System, and settings.json still holds nothing of the Floating Window")
func restoreDefaultsGoesBackToTheDefaults() throws {
    // Given
    var settings = everyValueChanged()

    // When
    settings.restoreDefaults()

    // Then
    expectTheSpecDefaults(settings)
    // Where the capsule is, whether it shows and Always on Top live in state.json, out of reach.
    let saved = try #require(try JSONSerialization.jsonObject(with: SettingsFile.encode(settings)) as? [String: Any])
    #expect(saved["floatingWindow"] == nil && saved["visible"] == nil && saved["alwaysOnTop"] == nil && saved["center"] == nil)
}

@Test("Given the Appearance choices in Settings, when they are listed, then they read System, Light, Dark in that order")
func theAppearanceChoicesReadSystemLightDark() {
    // Given
    let choices = Appearance.allCases

    // When
    let names = choices.map(\.name)

    // Then
    #expect(names == ["System", "Light", "Dark"])
}

// MARK: M6: Show in Dock

@Test("Given a settings.json from 0.9.0 with no showInDock key, when Settings are loaded, then Show in Dock is on and every other value is kept")
func aMissingShowInDockIsOn() {
    // Given
    let data = sample(
        (",\n  \"showInDock\": true", ""),
        ("\"focusMinutes\": 25", "\"focusMinutes\": 30")
    )

    // When
    let settings = SettingsFile.decode(data).value

    // Then
    #expect(settings.showInDock == true)
    #expect(settings.timer.focusMinutes == 30)
}

@Test("Given Show in Dock turned off, when Settings are saved and loaded back, then it is still off and the file says \"showInDock\": false")
func showInDockOffLoadsBack() throws {
    // Given
    var settings = Settings()
    settings.showInDock = false

    // When
    let data = SettingsFile.encode(settings)
    let loaded = SettingsFile.decode(data).value

    // Then
    #expect(loaded.showInDock == false)
    let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    #expect(json["showInDock"] as? Bool == false)
}

@Test("Given Show in Dock turned off, when Restore Defaults is pressed, then it is on again")
func restoreDefaultsTurnsShowInDockOn() {
    // Given
    var settings = Settings()
    settings.showInDock = false

    // When
    settings.restoreDefaults()

    // Then
    #expect(settings.showInDock == true)
}

