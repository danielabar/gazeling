import GazelingKit
import SwiftUI

@main
struct GazelingApp: App {
    init() {
        Spikes.observeSleepWake()
        Spikes.runLaunchArguments()
    }

    var body: some Scene {
        MenuBarExtra(AppInfo.name, systemImage: "eye") {
            // Phase 1 spike items. Removed or moved behind debug flags in Phase 3.
            Button("Spike: dim screens") { Spikes.showOverlay() }
            Button("Spike: notification") { Spikes.postNotification() }
            Button("Spike: print idle time") { Spikes.printIdle() }
            Divider()
            Button("Quit \(AppInfo.name)") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
