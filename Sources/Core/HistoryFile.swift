import Foundation

/// history.json, version 1: every Pomodoro's end (ISO 8601 UTC, whole seconds) and length in seconds.
public enum HistoryFile {
    /// - Parameter data: the file's bytes, or nil when there is no file yet.
    public static func decode(_ data: Data?) -> Loaded<History> {
        guard let data else { return Loaded(value: History(), moveAside: false) }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        // Not JSON, or written by a newer Pomodot: start empty, and never write over it.
        guard let file = try? decoder.decode(FileBeingRead.self, from: data), file.version <= 1 else {
            return Loaded(value: History(), moveAside: true)
        }
        // A broken entry is skipped on its own; the rest of History stays.
        let pomodoros = file.pomodoros.compactMap(\.entry).filter { $0.durationSeconds > 0 }
        return Loaded(
            value: History(pomodoros.map { Pomodoro(end: $0.end, durationSeconds: $0.durationSeconds) }),
            moveAside: false
        )
    }

    /// The whole file, rewritten each time (the App writes it atomically).
    public static func encode(_ history: History) -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let file = FileContents(
            version: 1,
            pomodoros: history.pomodoros.map { Entry(end: $0.end, durationSeconds: $0.durationSeconds) }
        )
        // Plain dates, whole numbers and strings: encoding can't fail.
        return try! encoder.encode(file)
    }

    private struct FileContents: Encodable {
        var version: Int
        var pomodoros: [Entry]
    }

    private struct Entry: Codable {
        var end: Date
        var durationSeconds: Int
    }

    /// Reads leniently: an entry that doesn't decode becomes nil instead of failing the file.
    private struct FileBeingRead: Decodable {
        var version: Int
        var pomodoros: [MaybeEntry]

        /// A missing key is one missing value, not a broken file: version 1, no Pomodoros.
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
            pomodoros = try container.decodeIfPresent([MaybeEntry].self, forKey: .pomodoros) ?? []
        }

        private enum CodingKeys: String, CodingKey {
            case version, pomodoros
        }
    }

    private struct MaybeEntry: Decodable {
        var entry: Entry?

        init(from decoder: Decoder) {
            entry = try? Entry(from: decoder)
        }
    }
}
