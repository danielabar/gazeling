import Foundation

/// Platform services. The app target has the real implementations; tests use fakes.
/// All are main-actor because they touch UI or system frameworks.

@MainActor
public protocol IdleMonitor {
    /// Seconds since the last keyboard or mouse input.
    func idleSeconds() -> TimeInterval
}

/// What macOS has recorded about notifications for this app.
public enum NotificationPermission: Equatable, Sendable {
    /// macOS has not asked the user yet. Asking shows the system prompt (once).
    case notAsked
    case allowed
    /// macOS never prompts again after a refusal. Only System Settings can change it.
    case denied
}

@MainActor
public protocol Notifier {
    func requestAuthorization() async
    func authorizationStatus() async -> NotificationPermission
    func openNotificationSettings()
    /// `seconds` is the time until the break starts.
    func postHeadsUp(kind: BreakKind, seconds: TimeInterval) async
    func removeHeadsUp()
}

@MainActor
public protocol OverlayPresenter {
    /// Dims every screen and shows the break on the screens `contentScreens` selects. `onSkip` is
    /// called when the user presses Skip or Esc.
    func show(session: BreakSession, contentScreens: OverlayScreen, onSkip: @escaping @MainActor () -> Void)
    func hide()
}

@MainActor
public protocol SoundPlayer {
    func playBreakStart()
    func playBreakEnd()
}

/// Whether macOS will start the app at login. Never stored by the app: macOS owns it and the user
/// can change it in System Settings at any time.
public enum LaunchAtLoginStatus: Equatable, Sendable {
    case off
    case on
    /// Registered, but the user must allow it in System Settings → General → Login Items & Extensions.
    case requiresApproval
}

@MainActor
public protocol LaunchAtLogin {
    /// Read fresh from macOS on every call.
    var status: LaunchAtLoginStatus { get }
    func register() throws
    func unregister() throws
    func openSystemSettings()
}
