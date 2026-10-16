import Core
import Foundation
import UserNotifications

/// Posts the macOS banner for a Phase that ran out by itself, with Pomodot's name and icon.
/// The banner never carries a sound: the app plays that itself.
@MainActor
final class BannerNotifier: NSObject, UNUserNotificationCenterDelegate {
    /// One identifier for every banner, so a new one replaces the last and
    /// Notification Center keeps only the latest.
    private static let requestIdentifier = "com.teppasit.pomodot.phase-ran-out"

    /// Nil outside Pomodot.app: UNUserNotificationCenter crashes in a bare executable.
    private let center: UNUserNotificationCenter? =
        Bundle.main.bundleURL.pathExtension == "app" ? .current() : nil
    private var hasAsked = false
    /// Clicking a banner. Set before launch finishes, so a click that launches the app counts.
    var onClick: () -> Void = {}

    override init() {
        super.init()
        center?.delegate = self
    }

    /// On Start, never at launch. The usual Allow / Don't Allow box, not provisional (which
    /// never shows banners). macOS asks only once, so after Don't Allow nothing pops up
    /// again. The timer is already running: nothing waits for the answer.
    func askPermission() {
        guard !hasAsked, let center else { return }
        hasAsked = true
        center.requestAuthorization(options: [.alert]) { _, error in
            if let error {
                NSLog("Pomodot: notification permission failed: %@", String(describing: error))
            }
        }
    }

    /// Whether macOS has turned Pomodot's notifications off (Don't Allow, or switched off in
    /// System Settings). Not asked yet is not off: the question comes on the first Start.
    /// Outside Pomodot.app nothing can be posted anyway, so it never says off.
    func checkTurnedOffInSystemSettings(_ answer: @escaping @MainActor (Bool) -> Void) {
        guard let center else { return answer(false) }
        center.getNotificationSettings { settings in
            let turnedOff = settings.authorizationStatus == .denied
            Task { @MainActor in answer(turnedOff) }
        }
    }

    func post(_ banner: Banner) {
        guard let center else { return }
        let content = UNMutableNotificationContent()
        content.title = banner.title
        content.body = banner.body
        let request = UNNotificationRequest(identifier: Self.requestIdentifier, content: content, trigger: nil)
        center.add(request) { error in
            if let error {
                NSLog("Pomodot: can't post banner: %@", String(describing: error))
            }
        }
    }

    /// macOS hides banners from the active app by default; show them anyway.
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse
    ) async {
        await MainActor.run { onClick() }
    }
}
