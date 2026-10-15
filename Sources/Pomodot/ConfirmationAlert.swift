import AppKit
import Core

/// Shows Core's question, if there is one, before an action that would lose progress.
@MainActor
enum ConfirmationAlert {
    /// Runs `action` straight away when `confirmation` is nil, otherwise only after the user confirms.
    static func ask(_ confirmation: Confirmation?, then action: @escaping @MainActor () -> Void) {
        guard let confirmation else {
            action()
            return
        }
        // Wait for the menu to close before showing a modal alert.
        Task { @MainActor in
            let alert = NSAlert()
            alert.messageText = confirmation.title
            alert.informativeText = confirmation.message
            alert.addButton(withTitle: confirmation.confirmButtonTitle)
            alert.addButton(withTitle: confirmation.cancelButtonTitle)
            // Pomodot has no Dock icon, so without this the alert can open behind the active app.
            NSApp.activate()
            if alert.runModal() == .alertFirstButtonReturn {
                action()
            }
        }
    }
}
