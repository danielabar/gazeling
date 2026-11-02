import AppKit
import GazelingKit
@preconcurrency import UserNotifications
import os

/// Heads-up notification. The delegate makes the banner show even while the app counts as frontmost,
/// which a menu bar app often does (see docs/architecture.md).
@MainActor
final class UserNotifier: NSObject, Notifier, UNUserNotificationCenterDelegate {
    private let center = UNUserNotificationCenter.current()
    private let logger = Logger(subsystem: "com.danielabar.gazeling", category: "notifier")
    private let headsUpID = "heads-up"

    override init() {
        super.init()
        center.delegate = self
    }

    func requestAuthorization() async {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound])
            logger.notice("notification permission granted=\(granted, privacy: .public)")
        } catch {
            logger.error("notification permission error: \(error.localizedDescription, privacy: .public)")
        }
    }

    func authorizationStatus() async -> NotificationPermission {
        switch await center.notificationSettings().authorizationStatus {
        case .notDetermined: .notAsked
        case .denied: .denied
        default: .allowed
        }
    }

    func openNotificationSettings() {
        for address in [
            "x-apple.systempreferences:com.apple.Notifications-Settings.extension",
            "x-apple.systempreferences:com.apple.preference.notifications",
        ] {
            if let url = URL(string: address), NSWorkspace.shared.open(url) { return }
        }
        logger.error("could not open the Notifications settings")
    }

    func postHeadsUp(kind: BreakKind, seconds: TimeInterval) async {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "Eye break soon")
        let n = Int(seconds.rounded())
        content.body =
            kind == .short
            ? String(localized: "A short eye break starts in \(n) seconds.")
            : String(localized: "A long eye break starts in \(n) seconds.")
        do {
            try await center.add(UNNotificationRequest(identifier: headsUpID, content: content, trigger: nil))
        } catch {
            logger.error("heads-up failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    func removeHeadsUp() {
        center.removeDeliveredNotifications(withIdentifiers: [headsUpID])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter, willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
