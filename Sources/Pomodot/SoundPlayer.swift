import AppKit
import Core

/// Plays a macOS system sound once, at the Mac's volume, when a Phase runs out by itself.
/// The app plays it rather than the notification, so it sounds even with notifications
/// off or not allowed, or during Do Not Disturb, like an alarm the user set.
@MainActor
final class SoundPlayer {
    /// Held while it plays: a sound that is let go stops early.
    private var playing: NSSound?

    func play(_ sound: Sound) {
        let name = sound.defaultSystemSoundName
        guard let nsSound = NSSound(named: name) else {
            NSLog("Pomodot: missing system sound %@", name)
            return
        }
        playing?.stop()
        playing = nsSound
        nsSound.play()
    }
}
