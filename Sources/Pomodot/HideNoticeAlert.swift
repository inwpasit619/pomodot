import AppKit
import Core

/// Core's one-time notice on the first Hide, with a single OK button.
@MainActor
enum HideNoticeAlert {
    static func tell(_ notice: HideNotice) {
        // Wait for the menu the Hide came from to close before showing a modal alert.
        Task { @MainActor in
            let alert = NSAlert()
            alert.messageText = notice.title
            alert.informativeText = notice.message
            alert.addButton(withTitle: notice.buttonTitle)
            // Like the confirmation alerts: without this it can open behind the active app.
            NSApp.activate()
            alert.runModal()
        }
    }
}
