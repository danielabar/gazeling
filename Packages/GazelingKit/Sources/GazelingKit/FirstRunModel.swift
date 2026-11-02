import Observation

/// What the first-run window shows and does: explain notifications, ask for permission, offer launch
/// at login. Closing the window counts as done (`complete()`), so it never nags.
@MainActor
@Observable
public final class FirstRunModel {
    public private(set) var notificationPermission: NotificationPermission = .notAsked
    public let launchAtLogin: LaunchAtLoginModel
    @ObservationIgnored private let notifier: Notifier
    @ObservationIgnored private var store: FirstRunStore

    public init(notifier: Notifier, store: FirstRunStore, launchAtLogin: LaunchAtLoginModel) {
        self.notifier = notifier
        self.store = store
        self.launchAtLogin = launchAtLogin
    }

    public var isNeeded: Bool { !store.isDone }

    public func refresh() async {
        notificationPermission = await notifier.authorizationStatus()
        launchAtLogin.refresh()
    }

    /// Shows the macOS prompt if it has not been shown yet. If macOS already recorded an answer, this
    /// changes nothing, so the view offers `openNotificationSettings()` for the denied case.
    public func allowNotifications() async {
        await notifier.requestAuthorization()
        await refresh()
    }

    public func openNotificationSettings() {
        notifier.openNotificationSettings()
    }

    public func complete() {
        store.isDone = true
    }

    /// For the debug menu, so the window can be tested again.
    public func reset() {
        store.isDone = false
    }
}
