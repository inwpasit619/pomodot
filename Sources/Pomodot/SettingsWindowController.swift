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
        model.checkSystemSettings()
        window.showInFront()
    }

    /// Switching the Dock icon while Settings is the active window can drop it behind other apps.
    func bringToFrontIfOpen() {
        guard let window, window.isVisible else { return }
        window.orderFrontRegardless()
    }

    private func makeWindow() -> NSWindow {
        let hosting = NSHostingController(rootView: SettingsView(model: model, corrections: corrections))
        // The window grows and shrinks with its content, e.g. when the notifications warning shows.
        hosting.sizingOptions = .preferredContentSize
        let window = NSWindow(contentViewController: hosting)
        window.title = "Settings"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }
}

extension NSWindow {
    /// Pomodot is seldom the active app, Dock icon or not: without activating, a window can open behind the active app.
    /// macOS may still turn the activation down, so it comes to the front regardless.
    func showInFront() {
        NSApp.activate()
        makeKeyAndOrderFront(nil)
        orderFrontRegardless()
    }
}
