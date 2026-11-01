import GazelingKit
import SwiftUI

@main
struct GazelingApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appState: AppState
    private let settingsWindow: SettingsWindowController

    init() {
        let debug = DebugOptions()
        let state = AppState(
            catalog: try! ExerciseCatalog.bundled(), store: UserDefaultsSettingsStore(), overrides: debug.overrides,
            idleMonitor: SystemIdleMonitor(), notifier: UserNotifier(), overlay: OverlayWindowPresenter(),
            sound: SystemSoundPlayer())
        state.start()
        if debug.breakNow { state.startBreakNow(.short) }
        _appState = State(initialValue: state)
        let settingsWindow = SettingsWindowController(
            appState: state, launchAtLogin: LaunchAtLoginModel(adapter: SMAppServiceLaunchAtLogin()))
        self.settingsWindow = settingsWindow
        AppDelegate.onReopen = { settingsWindow.show() }
    }

    var body: some Scene {
        MenuBarExtra("Gazeling", systemImage: "eye") {
            MenuContent(appState: appState, settingsWindow: settingsWindow)
        }
    }
}
