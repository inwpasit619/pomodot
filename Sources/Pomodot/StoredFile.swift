import Core
import Foundation

/// One of the app's data files in ~/Library/Application Support/com.teppasit.pomodot/.
/// Only reads, writes and renames; Core decides what the bytes mean.
@MainActor
final class StoredFile {
    private let name: String
    private let url: URL
    /// Off once a file couldn't be read or moved aside: never write over it.
    private var canWrite = true

    /// - Parameter name: without the extension, e.g. "history".
    init(name: String) {
        self.name = name
        let folder = URL.applicationSupportDirectory.appendingPathComponent("com.teppasit.pomodot", isDirectory: true)
        url = folder.appendingPathComponent("\(name).json")
    }

    /// Reads the file and lets Core decode it; a file Core can't read is renamed aside.
    func load<Value>(_ decode: (Data?) -> Loaded<Value>) -> Value {
        let data: Data?
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                data = try Data(contentsOf: url)
            } catch {
                NSLog("Pomodot: can't read %@, leaving it alone: %@", url.path, String(describing: error))
                canWrite = false
                return decode(nil).value
            }
        } else {
            data = nil
        }
        let loaded = decode(data)
        if loaded.moveAside {
            moveAside()
        }
        return loaded.value
    }

    /// Rewrites the whole file atomically, creating the folder the first time.
    func save(_ data: Data) {
        guard canWrite else { return }
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(), withIntermediateDirectories: true
            )
            try data.write(to: url, options: .atomic)
        } catch {
            NSLog("Pomodot: can't save %@: %@", url.path, String(describing: error))
        }
    }

    private func moveAside() {
        let aside = url.deletingLastPathComponent().appendingPathComponent(
            CorruptFile.name(of: name, at: Date(), timeZone: .current)
        )
        do {
            try FileManager.default.moveItem(at: url, to: aside)
            NSLog("Pomodot: %@ couldn't be read; moved it to %@ and started fresh", url.path, aside.lastPathComponent)
        } catch {
            NSLog("Pomodot: %@ couldn't be read or moved aside, leaving it alone: %@", url.path, String(describing: error))
            canWrite = false
        }
    }
}
