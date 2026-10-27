import GazelingKit
import SwiftUI

struct GeneralSettingsView: View {
    let appState: AppState

    var body: some View {
        Form {
            Section("During a break") {
                Picker("Show the owl on", selection: appState.binding(\.overlayScreen)) {
                    Text("The screen with my pointer").tag(OverlayScreen.pointer)
                    Text("The main screen").tag(OverlayScreen.main)
                    Text("Every screen").tag(OverlayScreen.all)
                }
                Text("Every screen always dims during a break. This chooses where the owl and the exercise appear.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Toggle("Play a sound when a break starts and ends", isOn: appState.binding(\.soundsEnabled))
            }
        }
        .formStyle(.grouped)
    }
}
