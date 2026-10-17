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
            let alert = makeAlert(confirmation)
            // Pomodot is seldom the active app, so without this the alert can open behind the active app.
            NSApp.activate()
            if alert.runModal() == .alertFirstButtonReturn {
                action()
            }
        }
    }

    /// The same question as a sheet that slides down from the top of `window`.
    /// Runs `action` only after the user confirms.
    static func ask(
        _ confirmation: Confirmation, in window: NSWindow, then action: @escaping @MainActor () -> Void
    ) {
        let alert = makeAlert(confirmation)
        alert.buttons[0].hasDestructiveAction = true
        alert.beginSheetModal(for: window) { response in
            if response == .alertFirstButtonReturn {
                action()
            }
        }
    }

    private static func makeAlert(_ confirmation: Confirmation) -> NSAlert {
        let alert = NSAlert()
        alert.messageText = confirmation.title
        alert.informativeText = confirmation.message
        alert.addButton(withTitle: confirmation.confirmButtonTitle)
        alert.addButton(withTitle: confirmation.cancelButtonTitle)
        return alert
    }
}
