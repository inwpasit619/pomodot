import Foundation

/// A moment written as ISO 8601, e.g. `iso("2026-10-14T17:10:00Z")` or `iso("2026-10-15T00:10:00+07:00")`.
func iso(_ text: String) -> Date {
    try! Date(text, strategy: .iso8601)
}

/// The Mac's calendar in Bangkok (UTC+7), with the week starting on `firstWeekday` (1 = Sunday, 2 = Monday).
func bangkokCalendar(firstWeekday: Int = 2) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Bangkok")!
    calendar.firstWeekday = firstWeekday
    return calendar
}

/// A sample data file from spec P1, read straight from Tests/CoreTests/Fixtures.
func fixture(_ name: String) -> Data {
    let url = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
        .appendingPathComponent("Fixtures").appendingPathComponent(name)
    return try! Data(contentsOf: url)
}
