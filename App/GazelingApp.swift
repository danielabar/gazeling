import GazelingKit
import SwiftUI

@main
struct GazelingApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var appState: AppState
    private let settingsWindow: SettingsWindowController
    private let firstRunWindow: FirstRunWindowController

    init() {
        let debug = DebugOptions()
        let notifier = UserNotifier()
        let state = AppState(
            catalog: try! ExerciseCatalog.bundled(), store: UserDefaultsSettingsStore(), overrides: debug.overrides,
            idleMonitor: SystemIdleMonitor(), notifier: notifier, overlay: OverlayWindowPresenter(),
            sound: SystemSoundPlayer())
        state.start()
        if debug.breakNow { state.startBreakNow(.short) }
        _appState = State(initialValue: state)
        let launchAtLogin = LaunchAtLoginModel(adapter: SMAppServiceLaunchAtLogin())
        let settingsWindow = SettingsWindowController(appState: state, launchAtLogin: launchAtLogin)
        self.settingsWindow = settingsWindow
        let firstRun = FirstRunModel(
            notifier: notifier, store: UserDefaultsFirstRunStore(), launchAtLogin: launchAtLogin)
        let firstRunWindow = FirstRunWindowController(model: firstRun)
        self.firstRunWindow = firstRunWindow
        AppDelegate.onLaunch = { firstRunWindow.showIfNeeded() }
        AppDelegate.onReopen = { settingsWindow.show() }
    }

    var body: some Scene {
        MenuBarExtra("Gazeling", systemImage: "eye") {
            MenuContent(appState: appState, settingsWindow: settingsWindow, firstRunWindow: firstRunWindow)
        }
    }
}
