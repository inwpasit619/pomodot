import AppKit
import Core

/// Plays a macOS system sound once, at the Mac's volume: when a Phase runs out by itself,
/// or when one is chosen in Settings. The app plays it rather than the notification, so it
/// sounds even with notifications off or not allowed, or during Do Not Disturb, like an alarm
/// the user set.
@MainActor
final class SoundPlayer {
    /// Held while it plays: a sound that is let go stops early.
    private var playing: NSSound?

    /// Every sound in /System/Library/Sounds, by name without the extension ("Glass").
    static let systemSoundNames: [String] = {
        let folder = URL(fileURLWithPath: "/System/Library/Sounds", isDirectory: true)
        let files = (try? FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)) ?? []
        return files.map { $0.deletingPathExtension().lastPathComponent }
    }()

    /// - Parameter name: a system sound's name; nil (None) plays nothing.
    func play(_ name: String?) {
        guard let name else { return }
        guard let nsSound = NSSound(named: name) else {
            NSLog("Pomodot: missing system sound %@", name)
            return
        }
        playing?.stop()
        playing = nsSound
        nsSound.play()
    }
}
