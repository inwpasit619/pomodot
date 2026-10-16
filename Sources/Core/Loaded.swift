import Foundation

/// What reading one of the app's data files gave. The App reads and writes the disk;
/// Core decides what the bytes mean.
public struct Loaded<Value: Sendable>: Sendable {
    public let value: Value
    /// The file couldn't be read: the App renames it aside and never writes over it.
    public let moveAside: Bool
}

/// A data file that couldn't be read, moved aside in its own folder.
public enum CorruptFile {
    /// `history.corrupt-2026-10-15T09-30-05.json`: the file's name and when it was moved,
    /// in the Mac's time zone.
    public static func name(of name: String, at now: Date, timeZone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = timeZone
        formatter.dateFormat = "yyyy-MM-dd'T'HH-mm-ss"
        return "\(name).corrupt-\(formatter.string(from: now)).json"
    }
}
