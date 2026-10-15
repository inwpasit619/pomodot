import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let model = AppModel()
    private var floatingWindowController: FloatingWindowController?

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
}
