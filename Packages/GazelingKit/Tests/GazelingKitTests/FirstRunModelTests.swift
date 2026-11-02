import Foundation
import Testing

@testable import GazelingKit

@MainActor
private final class StubNotifier: Notifier {
    var permission: NotificationPermission = .notAsked
    /// What the user answers when macOS asks. Ignored once the permission is decided.
    var answer: NotificationPermission = .allowed
    var requestCalls = 0
    var openSettingsCalls = 0

    func requestAuthorization() async {
        requestCalls += 1
        if permission == .notAsked { permission = answer }
    }
    func authorizationStatus() async -> NotificationPermission { permission }
    func openNotificationSettings() { openSettingsCalls += 1 }
    func postHeadsUp(kind: BreakKind, seconds: TimeInterval) async {}
    func removeHeadsUp() {}
}

@MainActor
private final class StubLaunchAtLogin: LaunchAtLogin {
    var status: LaunchAtLoginStatus = .off
    func register() throws { status = .on }
    func unregister() throws { status = .off }
    func openSystemSettings() {}
}

@MainActor
private func makeModel(
    notifier: StubNotifier = StubNotifier(), store: FirstRunStore = InMemoryFirstRunStore()
) -> FirstRunModel {
    FirstRunModel(
        notifier: notifier, store: store, launchAtLogin: LaunchAtLoginModel(adapter: StubLaunchAtLogin()))
}

@Test @MainActor func isNeededOnAFreshStoreUntilCompleted() {
    let model = makeModel()
    #expect(model.isNeeded)
    model.complete()
    #expect(!model.isNeeded)
}

@Test @MainActor func resetMakesItNeededAgain() {
    let model = makeModel()
    model.complete()
    model.reset()
    #expect(model.isNeeded)
}

@Test @MainActor func completionIsKeptInTheStore() {
    let store = InMemoryFirstRunStore()
    makeModel(store: store).complete()
    #expect(makeModel(store: store).isNeeded == false)
}

@Test @MainActor func refreshReadsThePermissionFromTheNotifier() async {
    let notifier = StubNotifier()
    notifier.permission = .denied
    let model = makeModel(notifier: notifier)
    await model.refresh()
    #expect(model.notificationPermission == .denied)
}

@Test @MainActor func allowNotificationsAsksMacOSThenShowsTheAnswer() async {
    let notifier = StubNotifier()
    let model = makeModel(notifier: notifier)
    await model.refresh()
    #expect(model.notificationPermission == .notAsked)
    await model.allowNotifications()
    #expect(notifier.requestCalls == 1)
    #expect(model.notificationPermission == .allowed)
}

@Test @MainActor func aRefusalShowsAsDenied() async {
    let notifier = StubNotifier()
    notifier.answer = .denied
    let model = makeModel(notifier: notifier)
    await model.allowNotifications()
    #expect(model.notificationPermission == .denied)
}

@Test @MainActor func refreshPicksUpAChangeMadeInSystemSettings() async {
    let notifier = StubNotifier()
    notifier.permission = .denied
    let model = makeModel(notifier: notifier)
    await model.refresh()
    notifier.permission = .allowed
    await model.refresh()
    #expect(model.notificationPermission == .allowed)
}

@Test @MainActor func openNotificationSettingsReachesTheNotifier() {
    let notifier = StubNotifier()
    makeModel(notifier: notifier).openNotificationSettings()
    #expect(notifier.openSettingsCalls == 1)
}

@Test func theSetupFlagDoesNotLiveInTheSettings() throws {
    let suite = "gazeling-test-\(UUID().uuidString)"
    let defaults = UserDefaults(suiteName: suite)!
    defer { defaults.removePersistentDomain(forName: suite) }
    let first = UserDefaultsFirstRunStore(defaults: defaults)
    #expect(!first.isDone)
    var store = first
    store.isDone = true
    #expect(UserDefaultsFirstRunStore(defaults: defaults).isDone)
    // Saving or replacing the settings leaves the flag alone.
    UserDefaultsSettingsStore(defaults: defaults).save(Settings())
    #expect(UserDefaultsFirstRunStore(defaults: defaults).isDone)
}
