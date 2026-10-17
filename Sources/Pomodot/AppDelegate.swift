import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = AppModel()
    private var floatingWindowController: FloatingWindowController?
    private lazy var statisticsWindowController = StatisticsWindowController(model: model)
    private lazy var settingsWindowController = SettingsWindowController(model: model)

    /// Every SF Symbol the app draws. Each must exist on the running macOS;
    /// a missing one is reported, never swapped for another.
    static let requiredSymbols = ["timer", "cup.and.saucer.fill", "pause.circle", "exclamationmark.triangle.fill"]

    /// Where every version of Pomodot is published. Pomodot never goes online itself.
    private static let releasesURL = URL(string: "https://github.com/inwpasit619/pomodot/releases")!

    /// macOS's About window, found the first time it opens and brought forward after that.
    private var aboutWindow: NSWindow?

    /// Before anything shows, so with Show in Dock off no Dock icon flashes up.
    func applicationWillFinishLaunching(_ notification: Notification) {
        model.applyDockIcon()
        model.afterDockIconChange = { [weak self] in self?.settingsWindowController.bringToFrontIfOpen() }
    }

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

        floatingWindowController = FloatingWindowController(model: model, app: self)
    }

    /// Quit Pomodot, a restart or a log out: save where the timer is, to come back Paused.
    func applicationWillTerminate(_ notification: Notification) {
        model.saveBeforeQuitting()
    }

    /// Opening Pomodot again from Finder or Spotlight while it runs (its menu bar icon may be
    /// hidden behind the notch), or clicking its Dock icon: show the Floating Window, still a
    /// capsule, instead of a second copy.
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSLog("Pomodot: opened again while running; showing the Floating Window")
        model.isFloatingWindowVisible = true
        // Already showing, perhaps behind other windows with Always on Top off: bring it forward.
        floatingWindowController?.bringToFront()
        return false
    }

    /// Right-clicking the Dock icon: the card's menu without Quit Pomodot, which macOS adds itself.
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        floatingWindowController?.dockMenu()
    }

    /// The menu's Statistics….
    func showStatistics() {
        statisticsWindowController.show()
    }

    /// The menu's Settings….
    func showSettings() {
        settingsWindowController.show()
    }

    /// The menu's About Pomodot: macOS's own About window, with the icon, the name and
    /// "Version 0.9.0 (build N)" from what scripts/build-app.sh writes into Info.plist.
    func showAbout() {
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        let windowsBefore = Set(NSApp.windows.map(ObjectIdentifier.init))
        // Pomodot is seldom active: without this the window can open behind the active app.
        NSApp.activate()
        NSApp.orderFrontStandardAboutPanel(options: [.version: "build \(build)"])
        aboutWindow = aboutWindow ?? NSApp.windows.first { !windowsBefore.contains(ObjectIdentifier($0)) }
        // macOS may still turn the activation down; the window comes to the front anyway.
        aboutWindow?.orderFrontRegardless()
    }

    /// The menu's Check for Updates…: the Releases page, in the browser.
    func checkForUpdates() {
        NSWorkspace.shared.open(Self.releasesURL)
    }
}
