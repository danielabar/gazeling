import GazelingKit
import SwiftUI

@main
struct GazelingApp: App {
    @State private var appState: AppState

    init() {
        let debug = DebugOptions()
        let state = AppState(
            catalog: try! ExerciseCatalog.bundled(), store: UserDefaultsSettingsStore(), overrides: debug.overrides,
            idleMonitor: SystemIdleMonitor(), notifier: UserNotifier(), overlay: OverlayWindowPresenter(),
            sound: SystemSoundPlayer())
        state.start()
        if debug.breakNow { state.startBreakNow(.short) }
        _appState = State(initialValue: state)
    }

    var body: some Scene {
        MenuBarExtra("Gazeling", systemImage: "eye") {
            MenuContent(appState: appState)
        }
    }
}
