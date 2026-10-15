import Testing
import Core

@Test("Given 14:02 left, when the time is shown, then it reads 14:02")
func timeLeftReadsMinutesAndSeconds() {
    // Given
    let seconds = 842

    // When
    let text = TimeText.minutesSeconds(seconds)

    // Then
    #expect(text == "14:02")
}

@Test("Given a 90-minute Phase, when its full length is shown, then it reads 90:00 with no hours")
func timeLeftOverAnHourHasNoHours() {
    // Given
    let seconds = 90 * 60

    // When
    let text = TimeText.minutesSeconds(seconds)

    // Then
    #expect(text == "90:00")
}
