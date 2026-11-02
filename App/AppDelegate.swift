import AppKit

/// Opens the settings window when the app is launched again while already running (for example from
/// the Applications folder). That is the way back in if the menu bar icon is hidden by the notch.
final class AppDelegate: NSObject, NSApplicationDelegate {
    @MainActor static var onReopen: (() -> Void)?
    /// Called once the app has finished launching. A window opened earlier than this can end up behind other apps.
    @MainActor static var onLaunch: (() -> Void)?

    @MainActor
    func applicationDidFinishLaunching(_ notification: Notification) {
        Self.onLaunch?()
    }

    @MainActor
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        Self.onReopen?()
        return true
    }
}
