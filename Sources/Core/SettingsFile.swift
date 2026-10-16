import Foundation

/// How every window, the capsule included, is drawn: following the Mac, or always Light or Dark.
public enum Appearance: String, Sendable, Equatable, CaseIterable {
    case system, light, dark

    /// As the Settings window writes it: "System", "Light", "Dark".
    public var name: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }
}

/// Every value in the Settings window, as settings.json keeps it. Defaults: 25 / 5 / 15 / 4,
/// both auto-starts off, Show notifications on, Glass / Hero, Appearance System.
/// The Floating Window's place, whether it shows and Always on Top are not Settings:
/// they live in state.json, and Restore Defaults never touches them.
public struct Settings: Sendable, Equatable {
    /// The Phase lengths, Pomodoros per Cycle and the two auto-starts.
    public var timer = TimerSettings()
    /// Off: no permission asked and no banners, but the sounds still play.
    public var showNotifications = true
    /// A macOS system sound's name, or nil for None.
    public var focusEndSound: String? = Sound.focus.defaultSystemSoundName
    public var breakEndSound: String? = Sound.break.defaultSystemSoundName
    public var appearance = Appearance.system

    public init() {}

    /// Restore Defaults: every value in Settings goes back to its default. Nothing else changes.
    public mutating func restoreDefaults() {
        self = Settings()
    }

    /// The system sound that plays when a Phase runs out by itself; nil for None.
    public func soundName(for sound: Sound) -> String? {
        switch sound {
        case .focus: focusEndSound
        case .break: breakEndSound
        }
    }

    /// A sound picked in a dropdown: nil for None.
    public mutating func setSoundName(_ name: String?, for sound: Sound) {
        switch sound {
        case .focus: focusEndSound = name
        case .break: breakEndSound = name
        }
    }

    /// A saved sound this Mac doesn't have goes back to that slot's default (Glass / Hero).
    /// None stays None.
    /// - Parameter sounds: the names in /System/Library/Sounds, without the extension.
    public mutating func replaceMissingSounds(onThisMac sounds: [String]) {
        for sound in [Sound.focus, .break] {
            if let name = soundName(for: sound), !sounds.contains(name) {
                setSoundName(sound.defaultSystemSoundName, for: sound)
            }
        }
    }

    /// Each sound dropdown: None at the top, then every sound on this Mac in alphabetical order.
    public static func soundChoices(onThisMac sounds: [String]) -> [String?] {
        [nil] + sounds.sorted()
    }

    /// The orange line under Show notifications: only while it is on and macOS has turned
    /// Pomodot's notifications off. With it off, nothing is asked or posted, so nothing to warn about.
    public func warnsNotificationsAreOff(turnedOffInSystemSettings: Bool) -> Bool {
        showNotifications && turnedOffInSystemSettings
    }
}

/// settings.json, version 1: every value in the Settings window.
public enum SettingsFile {
    /// - Parameter data: the file's bytes, or nil when there is no file yet.
    public static func decode(_ data: Data?) -> Loaded<Settings> {
        guard let data else { return Loaded(value: Settings(), moveAside: false) }
        // Not JSON, or written by a newer Pomodot: use the defaults, and never write over it.
        guard let file = try? JSONDecoder().decode(FileBeingRead.self, from: data), file.version <= 1 else {
            return Loaded(value: Settings(), moveAside: true)
        }
        return Loaded(value: file.settings, moveAside: false)
    }

    /// The whole file, rewritten each time (the App writes it atomically).
    public static func encode(_ settings: Settings) -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        // Whole numbers, booleans and strings: encoding can't fail.
        return try! encoder.encode(FileContents(settings: settings))
    }

    private enum CodingKeys: String, CodingKey {
        case version, focusMinutes, shortBreakMinutes, longBreakMinutes, pomodorosPerCycle
        case autoStartBreaks, autoStartFocus, showNotifications, focusEndSound, breakEndSound, appearance
    }

    private struct FileContents: Encodable {
        let settings: Settings

        /// Writes None as `null`, which reads back as None; a missing key would read back as the default.
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(1, forKey: .version)
            try container.encode(settings.timer.focusMinutes, forKey: .focusMinutes)
            try container.encode(settings.timer.shortBreakMinutes, forKey: .shortBreakMinutes)
            try container.encode(settings.timer.longBreakMinutes, forKey: .longBreakMinutes)
            try container.encode(settings.timer.pomodorosPerCycle, forKey: .pomodorosPerCycle)
            try container.encode(settings.timer.autoStartBreaks, forKey: .autoStartBreaks)
            try container.encode(settings.timer.autoStartFocus, forKey: .autoStartFocus)
            try container.encode(settings.showNotifications, forKey: .showNotifications)
            try container.encode(settings.focusEndSound, forKey: .focusEndSound)
            try container.encode(settings.breakEndSound, forKey: .breakEndSound)
            try container.encode(settings.appearance.rawValue, forKey: .appearance)
        }
    }

    /// Reads leniently: a value that is missing, of the wrong type or out of range takes its
    /// default, and the others are kept.
    private struct FileBeingRead: Decodable {
        var version: Int
        var settings: Settings

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let defaults = Settings()
            version = (try? container.decode(Int.self, forKey: .version)) ?? 1

            func number(_ key: CodingKeys, in range: ClosedRange<Int>, else fallback: Int) -> Int {
                (try? container.decode(Int.self, forKey: key)).flatMap { range.contains($0) ? $0 : nil } ?? fallback
            }
            func flag(_ key: CodingKeys, else fallback: Bool) -> Bool {
                (try? container.decode(Bool.self, forKey: key)) ?? fallback
            }
            /// `null` is None; a missing key, or one that isn't a name, is the default.
            func sound(_ key: CodingKeys, else fallback: String?) -> String? {
                if (try? container.decodeNil(forKey: key)) == true { return nil }
                return (try? container.decode(String.self, forKey: key)) ?? fallback
            }

            settings = Settings()
            let minutes = TimerSettings.minutesRange
            settings.timer.focusMinutes = number(.focusMinutes, in: minutes, else: defaults.timer.focusMinutes)
            settings.timer.shortBreakMinutes = number(.shortBreakMinutes, in: minutes, else: defaults.timer.shortBreakMinutes)
            settings.timer.longBreakMinutes = number(.longBreakMinutes, in: minutes, else: defaults.timer.longBreakMinutes)
            settings.timer.pomodorosPerCycle = number(
                .pomodorosPerCycle, in: TimerSettings.pomodorosPerCycleRange, else: defaults.timer.pomodorosPerCycle
            )
            settings.timer.autoStartBreaks = flag(.autoStartBreaks, else: defaults.timer.autoStartBreaks)
            settings.timer.autoStartFocus = flag(.autoStartFocus, else: defaults.timer.autoStartFocus)
            settings.showNotifications = flag(.showNotifications, else: defaults.showNotifications)
            settings.focusEndSound = sound(.focusEndSound, else: defaults.focusEndSound)
            settings.breakEndSound = sound(.breakEndSound, else: defaults.breakEndSound)
            settings.appearance = (try? container.decode(String.self, forKey: .appearance))
                .flatMap(Appearance.init(rawValue:)) ?? defaults.appearance
        }
    }
}
