import GazelingKit
import SwiftUI

struct MenuContent: View {
    let appState: AppState
    let settingsWindow: SettingsWindowController

    var body: some View {
        Text(statusText)
        Divider()

        switch appState.state {
        case .paused:
            Button("Resume") { appState.resume() }
        case .headsUp:
            Button("Postpone by \(DurationText.format(appState.settings.postponeDuration))") { appState.postpone() }
            Button("Skip this break") { appState.skip() }
        default:
            Button("Skip next break") { appState.skip() }
                .disabled(appState.nextBreakDate == nil)
            Menu("Pause") {
                Button("For 30 minutes") { appState.pause(for: 30 * 60) }
                Button("For 1 hour") { appState.pause(for: 60 * 60) }
                Button("For 2 hours") { appState.pause(for: 2 * 60 * 60) }
                Button("Until I resume") { appState.pause(for: nil) }
            }
        }

        #if DEBUG
            Divider()
            Button("Debug: start short break") { appState.startBreakNow(.short) }
            Button("Debug: start long break") { appState.startBreakNow(.long) }
            Menu("Debug: play exercise") {
                ForEach(appState.exercises) { exercise in
                    Button(LocalizedStringKey(exercise.titleKey)) { appState.playNow(exercise: exercise) }
                }
            }
            Button("Debug: goodbye wave (4 s)") {
                if let exercise = appState.exercises.first { appState.playNow(exercise: exercise, seconds: 4) }
            }
            Menu("Debug: launch at login spike") {
                Button("Log status") { LaunchAtLoginSpike.logStatus() }
                Button("Register") { LaunchAtLoginSpike.register() }
                Button("Unregister") { LaunchAtLoginSpike.unregister() }
                Button("Open Login Items settings") { LaunchAtLoginSpike.openLoginItems() }
            }
        #endif

        Divider()
        Button("Settings…") { settingsWindow.show() }
            .keyboardShortcut(",")
        Button("Quit Gazeling") { NSApplication.shared.terminate(nil) }
            .keyboardShortcut("q")
    }

    private var statusText: String {
        switch appState.state {
        case .paused(let until):
            if let until {
                return String(localized: "Paused until \(until.formatted(date: .omitted, time: .shortened))")
            }
            return String(localized: "Paused")
        case .onBreak:
            return String(localized: "On a break")
        default:
            if let due = appState.nextBreakDate {
                return String(localized: "Next break at \(due.formatted(date: .omitted, time: .shortened))")
            }
            return String(localized: "No breaks scheduled")
        }
    }
}
