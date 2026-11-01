import AppKit
import GazelingKit
import SwiftUI

/// Owns the settings window. AppKit, not a SwiftUI scene, so the menu item and the "app reopened"
/// event can both open it directly, and it comes to the front even though Gazeling has no Dock icon.
@MainActor
final class SettingsWindowController {
    private var window: NSWindow?
    private let appState: AppState
    private let launchAtLogin: LaunchAtLoginModel

    init(appState: AppState, launchAtLogin: LaunchAtLoginModel) {
        self.appState = appState
        self.launchAtLogin = launchAtLogin
    }

    func show() {
        if window == nil {
            let window = NSWindow(
                contentRect: .zero, styleMask: [.titled, .closable, .miniaturizable], backing: .buffered,
                defer: false)
            window.title = String(localized: "Gazeling Settings")
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(rootView: SettingsView(appState: appState, launchAtLogin: launchAtLogin))
            window.center()
            self.window = window
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }
}
