import AppKit
import SwiftUI

/// The Settings window: an ordinary window (not floating, with a close button), opened
/// from the menu's Settings… and kept for the next time once closed.
@MainActor
final class SettingsWindowController {
    private let model: AppModel
    private var window: NSWindow?
    private let corrections = TypedNumberCorrections()

    init(model: AppModel) {
        self.model = model
    }

    func show() {
        let window = window ?? makeWindow()
        self.window = window
        window.showInFront()
    }

    private func makeWindow() -> NSWindow {
        let window = NSWindow(contentViewController: NSHostingController(rootView: SettingsView(model: model, corrections: corrections)))
        window.title = "Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
}

extension NSWindow {
    /// Pomodot has no Dock icon: without activating, a window can open behind the active app.
    /// macOS may still turn the activation down, so it comes to the front regardless.
    func showInFront() {
        NSApp.activate()
        makeKeyAndOrderFront(nil)
        orderFrontRegardless()
    }
}
