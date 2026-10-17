import Testing
import Core

@Test("Given the notice has never been shown, when the Floating Window is hidden, then the notice shows and is remembered as shown")
func firstHideShowsTheNotice() {
    // Given
    var shown = false

    // When
    let notice = HideNotice.onHiding(alreadyShown: &shown, showInDock: false)

    // Then
    #expect(notice != nil)
    #expect(shown)
}

@Test("Given the notice has been shown once, when the Floating Window is hidden again, then no notice shows")
func laterHidesShowNothing() {
    // Given
    var shown = false
    _ = HideNotice.onHiding(alreadyShown: &shown, showInDock: false)

    // When
    let notice = HideNotice.onHiding(alreadyShown: &shown, showInDock: false)

    // Then
    #expect(notice == nil)
    #expect(shown)
}

@Test("Given Show in Dock is off, when the notice shows, then it says to open Pomodot again from Spotlight or Launchpad, with one OK button")
func noticeWithoutTheDockIcon() {
    // Given
    var shown = false

    // When
    let notice = HideNotice.onHiding(alreadyShown: &shown, showInDock: false)

    // Then
    #expect(notice == HideNotice(
        title: "Pomodot keeps running",
        message: "To bring the Floating Window back, open Pomodot again from Spotlight or Launchpad."
    ))
    #expect(notice?.buttonTitle == "OK")
}

@Test("Given Show in Dock is on, when the notice shows, then it says to click Pomodot in the Dock, or open it again from Spotlight or Launchpad")
func noticeWithTheDockIcon() {
    // Given
    var shown = false

    // When
    let notice = HideNotice.onHiding(alreadyShown: &shown, showInDock: true)

    // Then
    #expect(notice == HideNotice(
        title: "Pomodot keeps running",
        message: "To bring the Floating Window back, click Pomodot in the Dock, or open it again from Spotlight or Launchpad."
    ))
}
