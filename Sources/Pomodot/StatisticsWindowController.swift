import AppKit
import Core
import SwiftUI

/// The Statistics window: an ordinary window (not floating, with a close button), opened
/// from the menu's Statistics… and kept for the next time once closed.
@MainActor
final class StatisticsWindowController {
    private let model: AppModel
    private var window: NSWindow?
    private let hover = ChartHover()

    init(model: AppModel) {
        self.model = model
    }

    func show() {
        let window = window ?? makeWindow()
        self.window = window
        window.showInFront()
    }

    private func makeWindow() -> NSWindow {
        let view = StatisticsView(model: model, hover: hover) { [weak self] in self?.askToClearHistory() }
        let window = NSWindow(contentViewController: NSHostingController(rootView: view))
        window.title = "Statistics"
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.isReleasedWhenClosed = false
        window.center()
        return window
    }

    /// Core's question as a sheet. If a Focus ends while it is open, the count it gave is
    /// out of date, so it asks again with the new one rather than deleting more than it said.
    private func askToClearHistory() {
        guard let window, let confirmation = model.clearHistoryConfirmation else { return }
        ConfirmationAlert.ask(confirmation, in: window) { [weak self] in
            guard let self else { return }
            if model.clearHistoryConfirmation == confirmation {
                model.clearHistory()
            } else {
                askToClearHistory()
            }
        }
    }
}
