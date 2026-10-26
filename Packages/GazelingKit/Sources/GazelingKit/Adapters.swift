import Foundation

/// Platform services. The app target has the real implementations; tests use fakes.
/// All are main-actor because they touch UI or system frameworks.

@MainActor
public protocol IdleMonitor {
  /// Seconds since the last keyboard or mouse input.
  func idleSeconds() -> TimeInterval
}

@MainActor
public protocol Notifier {
  func requestAuthorization() async
  /// `seconds` is the time until the break starts.
  func postHeadsUp(kind: BreakKind, seconds: TimeInterval) async
  func removeHeadsUp()
}

@MainActor
public protocol OverlayPresenter {
  /// Dims every screen and shows the break. `onSkip` is called when the user presses Skip or Esc.
  func show(session: BreakSession, onSkip: @escaping @MainActor () -> Void)
  func hide()
}

@MainActor
public protocol SoundPlayer {
  func playBreakStart()
  func playBreakEnd()
}
