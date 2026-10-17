/// The menu that opens from the card's ellipsis button and from a right-click on the
/// capsule or card. The Dock's menu is the same without Quit Pomodot, since macOS adds its own.
public struct CardMenu: Sendable {
    /// Where the menu opens.
    public enum Place: Sendable {
        case card
        case dock
    }

    /// What choosing an item does.
    public enum Command: Sendable, Equatable {
        case newCycle
        case hideOrShowFloatingWindow
        case alwaysOnTop
        case statistics
        case settings
        case about
        case checkForUpdates
        case quit
    }

    public struct Item: Sendable, Equatable {
        public let title: String
        public let isEnabled: Bool
        public let isChecked: Bool
        /// Nil for a line that only shows something.
        public let command: Command?

        public init(_ title: String, command: Command?, isEnabled: Bool = true, isChecked: Bool = false) {
            self.title = title
            self.command = command
            self.isEnabled = isEnabled
            self.isChecked = isChecked
        }
    }

    public enum Entry: Sendable, Equatable {
        case item(Item)
        case separator
    }

    public let todayPomodoros: Int
    public let timer: PomodoroTimer
    public let isFloatingWindowVisible: Bool
    public let isAlwaysOnTop: Bool

    public init(todayPomodoros: Int, timer: PomodoroTimer, isFloatingWindowVisible: Bool, isAlwaysOnTop: Bool) {
        self.todayPomodoros = todayPomodoros
        self.timer = timer
        self.isFloatingWindowVisible = isFloatingWindowVisible
        self.isAlwaysOnTop = isAlwaysOnTop
    }

    /// Only what the card has no button for: Start, Skip and Reset… are on the card already.
    public func entries(for place: Place) -> [Entry] {
        var entries: [Entry] = [
            .item(Item("Today: 🍅 \(todayPomodoros)", command: nil, isEnabled: false)),
            .separator,
            .item(Item("New Cycle…", command: .newCycle, isEnabled: timer.canStartNewCycle)),
            .separator,
            .item(Item(
                isFloatingWindowVisible ? "Hide Floating Window" : "Show Floating Window",
                command: .hideOrShowFloatingWindow
            )),
            .item(Item("Always on Top", command: .alwaysOnTop, isChecked: isAlwaysOnTop)),
            .separator,
            .item(Item("Statistics…", command: .statistics)),
            .item(Item("Settings…", command: .settings)),
            .separator,
            .item(Item("About Pomodot", command: .about)),
            .item(Item("Check for Updates…", command: .checkForUpdates)),
        ]
        if place == .card {
            entries += [.separator, .item(Item("Quit Pomodot", command: .quit))]
        }
        return entries
    }
}
