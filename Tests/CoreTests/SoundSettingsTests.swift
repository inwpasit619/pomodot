import Foundation
import Testing
import Core

// The two sound dropdowns and the Show notifications warning (spec M5 › หน้าต่าง Settings).

/// The sounds in /System/Library/Sounds on the Mac these tests imagine.
private let soundsOnThisMac = ["Basso", "Glass", "Hero", "Ping", "Submarine"]

@Test("Given Submarine saved for the end of a Focus and Ping for the end of a Break, both on this Mac, when sounds missing from this Mac are replaced, then both are kept")
func savedSoundsOnThisMacAreKept() {
    // Given
    var settings = Settings()
    settings.focusEndSound = "Submarine"
    settings.breakEndSound = "Ping"

    // When
    settings.replaceMissingSounds(onThisMac: soundsOnThisMac)

    // Then
    #expect(settings.focusEndSound == "Submarine")
    #expect(settings.breakEndSound == "Ping")
}

@Test("Given Blip saved for both sounds and no Blip on this Mac, when sounds missing from this Mac are replaced, then the end of a Focus plays Glass and the end of a Break plays Hero")
func aSavedSoundMissingFromThisMacIsTheDefault() {
    // Given
    var settings = Settings()
    settings.focusEndSound = "Blip"
    settings.breakEndSound = "Blip"

    // When
    settings.replaceMissingSounds(onThisMac: soundsOnThisMac)

    // Then
    #expect(settings.focusEndSound == "Glass")
    #expect(settings.breakEndSound == "Hero")
}

@Test("Given None chosen for both sounds, when sounds missing from this Mac are replaced, then both are still None")
func noneIsKept() {
    // Given
    var settings = Settings()
    settings.focusEndSound = nil
    settings.breakEndSound = nil

    // When
    settings.replaceMissingSounds(onThisMac: soundsOnThisMac)

    // Then
    #expect(settings.focusEndSound == nil)
    #expect(settings.breakEndSound == nil)
}

@Test("Given Submarine for the end of a Focus and Ping for the end of a Break, when the sound for each is looked up, then the end of a Focus plays Submarine and the end of a Break plays Ping")
func eachSlotPlaysItsChosenSound() {
    // Given
    var settings = Settings()
    settings.focusEndSound = "Submarine"
    settings.breakEndSound = "Ping"

    // When
    let afterFocus = settings.soundName(for: .focus)
    let afterBreak = settings.soundName(for: .break)

    // Then
    #expect(afterFocus == "Submarine")
    #expect(afterBreak == "Ping")
}

@Test("Given None chosen for the end of a Focus, when the sound for each is looked up, then the end of a Focus plays nothing and the end of a Break still plays Hero")
func noneIsSilent() {
    // Given
    var settings = Settings()
    settings.focusEndSound = nil

    // When
    let afterFocus = settings.soundName(for: .focus)
    let afterBreak = settings.soundName(for: .break)

    // Then
    #expect(afterFocus == nil)
    #expect(afterBreak == "Hero")
}

@Test("Given the default sounds Glass and Hero, when Ping is picked for the end of a Focus and None for the end of a Break, then those are the two sounds")
func aPickedSoundGoesInItsOwnSlot() {
    // Given
    var settings = Settings()

    // When
    settings.setSoundName("Ping", for: .focus)
    settings.setSoundName(nil, for: .break)

    // Then
    #expect(settings.focusEndSound == "Ping")
    #expect(settings.breakEndSound == nil)
}

@Test("Given Hero, Basso and Glass on this Mac, when the sound dropdown is filled, then it is None, Basso, Glass, Hero")
func theDropdownHasNoneFirstThenEverySoundInOrder() {
    // Given
    let sounds = ["Hero", "Basso", "Glass"]

    // When
    let choices = Settings.soundChoices(onThisMac: sounds)

    // Then
    #expect(choices == [nil, "Basso", "Glass", "Hero"])
}

@Test("Given Show notifications is on, when macOS has turned Pomodot's notifications off, then the orange warning shows")
func theWarningShowsWhenMacOSHasTurnedNotificationsOff() {
    // Given
    let settings = Settings()

    // When
    let warns = settings.warnsNotificationsAreOff(turnedOffInSystemSettings: true)

    // Then
    #expect(warns == true)
}

@Test("Given Show notifications is on, when macOS allows Pomodot's notifications, then there is no warning")
func noWarningWhenMacOSAllowsNotifications() {
    // Given
    let settings = Settings()

    // When
    let warns = settings.warnsNotificationsAreOff(turnedOffInSystemSettings: false)

    // Then
    #expect(warns == false)
}

@Test("Given Show notifications is off, when macOS has turned Pomodot's notifications off, then there is no warning")
func noWarningWhenShowNotificationsIsOff() {
    // Given
    var settings = Settings()
    settings.showNotifications = false

    // When
    let warns = settings.warnsNotificationsAreOff(turnedOffInSystemSettings: true)

    // Then
    #expect(warns == false)
}
