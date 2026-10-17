import Core
import Foundation
import ServiceManagement

/// Open at login, kept by macOS rather than in a file: Pomodot itself as a login item.
/// Pomodot never registers it again by itself, not even after an update.
@MainActor
enum LoginItem {
    /// What macOS says now. The user can change it in System Settings at any time.
    static var status: LoginItemStatus {
        switch SMAppService.mainApp.status {
        case .enabled: .enabled
        case .notRegistered: .notRegistered
        case .requiresApproval: .requiresApproval
        case .notFound: .notFound
        // A status from a later macOS: shown as off, which the user can turn on again.
        @unknown default: .notFound
        }
    }

    /// Turns it on or off. A failure is only logged: the switch then shows what macOS says.
    static func turn(on: Bool) {
        do {
            if on {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Pomodot: couldn't turn Open at login %@: %@", on ? "on" : "off", error.localizedDescription)
        }
    }

    /// System Settings › General › Login Items & Extensions.
    static func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
