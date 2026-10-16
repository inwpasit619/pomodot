import Foundation
import Testing
import Core

// history.json, version 1 (spec P1).

@Test("Given there is no history.json yet, when History is loaded, then it is empty and there is no file to move aside")
func noHistoryFileMeansEmptyHistory() {
    // Given
    let data: Data? = nil

    // When
    let loaded = HistoryFile.decode(data)

    // Then
    #expect(loaded.value == History())
    #expect(loaded.moveAside == false)
}

@Test("Given the version 1 sample history.json from the spec, when it is loaded, then History holds its 2 Pomodoros with their exact ends and lengths")
func theSampleHistoryFileAlwaysReads() {
    // Given
    let data = fixture("history.json")

    // When
    let loaded = HistoryFile.decode(data)

    // Then
    #expect(loaded.value.pomodoros == [
        Pomodoro(end: iso("2026-10-14T17:10:00Z"), durationSeconds: 1500),
        Pomodoro(end: iso("2026-10-15T02:55:00Z"), durationSeconds: 1800),
    ])
    #expect(loaded.moveAside == false)
}

@Test("Given a History of 2 Pomodoros, when it is saved and loaded back, then it is the same History")
func savedHistoryLoadsBack() {
    // Given
    let history = History([
        Pomodoro(end: iso("2026-10-14T17:10:00Z"), durationSeconds: 1500),
        Pomodoro(end: iso("2026-10-15T02:55:00Z"), durationSeconds: 1800),
    ])

    // When
    let loaded = HistoryFile.decode(HistoryFile.encode(history))

    // Then
    #expect(loaded.value == history)
    #expect(loaded.moveAside == false)
}

@Test("Given a History of 2 Pomodoros, when it is saved, then the file is version 1 with each end in ISO 8601 UTC and each length in seconds")
func savedHistoryMatchesTheSampleFormat() throws {
    // Given
    let history = History([Pomodoro(end: iso("2026-10-14T17:10:00Z"), durationSeconds: 1500)])

    // When
    let data = HistoryFile.encode(history)

    // Then
    let json = try #require(try JSONSerialization.jsonObject(with: data) as? [String: Any])
    #expect(json["version"] as? Int == 1)
    let pomodoros = try #require(json["pomodoros"] as? [[String: Any]])
    #expect(pomodoros.count == 1)
    #expect(pomodoros[0]["end"] as? String == "2026-10-14T17:10:00Z")
    #expect(pomodoros[0]["durationSeconds"] as? Int == 1500)
}

@Test("Given a history.json that isn't JSON, when History is loaded, then it is empty and the file is to be moved aside")
func unreadableHistoryFileIsMovedAside() {
    // Given
    let data = Data("{ \"version\": 1, \"pomodoros\": [".utf8)

    // When
    let loaded = HistoryFile.decode(data)

    // Then
    #expect(loaded.value == History())
    #expect(loaded.moveAside == true)
}

@Test("Given a history.json at version 2 from a newer Pomodot, when History is loaded, then it is empty and the file is to be moved aside")
func newerHistoryFileIsMovedAside() {
    // Given
    let data = Data("""
    { "version": 2, "pomodoros": [ { "end": "2026-10-14T17:10:00Z", "durationSeconds": 1500 } ] }
    """.utf8)

    // When
    let loaded = HistoryFile.decode(data)

    // Then
    #expect(loaded.value == History())
    #expect(loaded.moveAside == true)
}

@Test("Given a history.json with one entry missing its end and one with a negative length among 2 good ones, when History is loaded, then only the 2 good Pomodoros are kept and the file stays where it is")
func brokenHistoryEntriesAreSkipped() {
    // Given
    let data = Data("""
    {
      "version": 1,
      "pomodoros": [
        { "end": "2026-10-14T17:10:00Z", "durationSeconds": 1500 },
        { "durationSeconds": 1500 },
        { "end": "2026-10-15T01:00:00Z", "durationSeconds": -5 },
        { "end": "2026-10-15T02:55:00Z", "durationSeconds": 1800 }
      ]
    }
    """.utf8)

    // When
    let loaded = HistoryFile.decode(data)

    // Then
    #expect(loaded.value.pomodoros == [
        Pomodoro(end: iso("2026-10-14T17:10:00Z"), durationSeconds: 1500),
        Pomodoro(end: iso("2026-10-15T02:55:00Z"), durationSeconds: 1800),
    ])
    #expect(loaded.moveAside == false)
}

@Test("Given a History of 5,000 Pomodoros, when it is saved and loaded back, then all 5,000 come back with exactly the same ends")
func aLongHistoryLoadsBackExactly() {
    // Given: one every 31 minutes and 7 seconds from 1 Jan 2020, so no two ends share a pattern.
    let first = iso("2020-01-01T00:00:00Z")
    let history = History((0..<5_000).map {
        Pomodoro(end: first.addingTimeInterval(TimeInterval($0 * 1867)), durationSeconds: 1500)
    })

    // When
    let loaded = HistoryFile.decode(HistoryFile.encode(history))

    // Then
    #expect(loaded.value.pomodoros.count == 5_000)
    #expect(loaded.value.pomodoros.last?.end == iso("2020-04-18T00:32:13Z"))
    #expect(loaded.value == history)
}

@Test("Given history.json can't be read at 09:30:05 on 15 Oct 2026, when it is moved aside, then it is renamed history.corrupt-2026-10-15T09-30-05.json")
func aFileMovedAsideIsNamedWithTheTime() {
    // Given
    let now = iso("2026-10-15T09:30:05Z")

    // When
    let name = CorruptFile.name(of: "history", at: now, timeZone: TimeZone(identifier: "UTC")!)

    // Then
    #expect(name == "history.corrupt-2026-10-15T09-30-05.json")
}

@Test("Given a history.json with no version but 1 good Pomodoro, when History is loaded, then the Pomodoro is kept and the file stays where it is")
func historyFileWithoutAVersionStillReads() {
    // Given
    let data = Data("""
    { "pomodoros": [ { "end": "2026-10-14T17:10:00Z", "durationSeconds": 1500 } ] }
    """.utf8)

    // When
    let loaded = HistoryFile.decode(data)

    // Then
    #expect(loaded.value.pomodoros == [Pomodoro(end: iso("2026-10-14T17:10:00Z"), durationSeconds: 1500)])
    #expect(loaded.moveAside == false)
}

@Test("Given a history.json with a version but no list of Pomodoros, when History is loaded, then History is empty and the file stays where it is")
func historyFileWithoutPomodorosIsEmpty() {
    // Given
    let data = Data(#"{ "version": 1 }"#.utf8)

    // When
    let loaded = HistoryFile.decode(data)

    // Then
    #expect(loaded.value == History())
    #expect(loaded.moveAside == false)
}
