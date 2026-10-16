import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = AppModel()
    private var floatingWindowController: FloatingWindowController?
    private lazy var statisticsWindowController = StatisticsWindowController(model: model)

    /// Every SF Symbol the app draws. Each must exist on the running macOS;
    /// a missing one is reported, never swapped for another.
    static let requiredSymbols = ["timer", "cup.and.saucer.fill", "pause.circle"]

    func applicationDidFinishLaunching(_ notification: Notification) {
        let missing = Self.requiredSymbols.filter {
            NSImage(systemSymbolName: $0, accessibilityDescription: nil) == nil
        }
        guard missing.isEmpty else {
            let names = missing.joined(separator: ", ")
            NSLog("Pomodot: missing SF Symbols: %@", names)
            let alert = NSAlert()
            alert.messageText = "Pomodot can't start"
            alert.informativeText = "These SF Symbols are missing on this Mac: \(names)"
            NSApp.activate()
            alert.runModal()
            NSApp.terminate(nil)
            return
        }
        NSLog("Pomodot: SF Symbols OK: %@", Self.requiredSymbols.joined(separator: ", "))

        floatingWindowController = FloatingWindowController(model: model)
    }

    /// Quit Pomodot, a restart or a log out: save where the timer is, to come back Paused.
    func applicationWillTerminate(_ notification: Notification) {
        model.saveBeforeQuitting()
    }

    /// Opening Pomodot again from Finder or Spotlight while it runs (its menu bar icon may be
    /// hidden behind the notch): show the Floating Window instead of a second copy.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSLog("Pomodot: opened again while running; showing the Floating Window")
        model.isFloatingWindowVisible = true
        // Already showing, perhaps behind other windows with Always on Top off: bring it forward.
        floatingWindowController?.bringToFront()
        return false
    }

    /// The menu's Statistics….
    func showStatistics() {
        statisticsWindowController.show()
    }
}
