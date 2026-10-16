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

@Test("Given Pomodoros of 1500, 1800 and 1200 seconds, when their total Focus time is shown, then it reads 1h 15m")
func totalFocusTimeReadsHoursAndMinutes() {
    // Given
    let seconds = 1500 + 1800 + 1200

    // When
    let text = TimeText.hoursMinutes(seconds)

    // Then
    #expect(text == "1h 15m")
}

@Test("Given 45 minutes of Focus, when the total is shown, then it reads 45m with no hours")
func totalFocusTimeUnderAnHourHasNoHours() {
    // Given
    let seconds = 45 * 60

    // When
    let text = TimeText.hoursMinutes(seconds)

    // Then
    #expect(text == "45m")
}

@Test("Given no Focus time, when the total is shown, then it reads 0m")
func noFocusTimeReadsZeroMinutes() {
    // Given
    let seconds = 0

    // When
    let text = TimeText.hoursMinutes(seconds)

    // Then
    #expect(text == "0m")
}

@Test("Given 125 minutes of Focus, when the total is shown, then the minutes have two digits: 2h 05m")
func totalFocusTimePadsMinutes() {
    // Given
    let seconds = 125 * 60

    // When
    let text = TimeText.hoursMinutes(seconds)

    // Then
    #expect(text == "2h 05m")
}

@Test("Given 10,300 minutes of Focus, when the total is shown, then the hours keep counting past a day: 171h 40m")
func totalFocusTimeKeepsCountingHours() {
    // Given
    let seconds = 10_300 * 60

    // When
    let text = TimeText.hoursMinutes(seconds)

    // Then
    #expect(text == "171h 40m")
}
