import GazelingKit
import SwiftUI

struct GeneralSettingsView: View {
    let appState: AppState
    let launchAtLogin: LaunchAtLoginModel

    var body: some View {
        Form {
            Section("When I log in") {
                Toggle(
                    "Start Gazeling when I log in",
                    isOn: Binding(get: { launchAtLogin.isOn }, set: { launchAtLogin.setEnabled($0) }))
                if launchAtLogin.needsApproval {
                    Text(
                        "macOS needs your approval. Turn Gazeling on in System Settings → General → Login Items & Extensions."
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    Button("Open Login Items") { launchAtLogin.openSystemSettings() }
                }
                if let message = launchAtLogin.errorMessage {
                    Text(message)
                        .font(.callout)
                        .foregroundStyle(.red)
                }
            }
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
        .onAppear { launchAtLogin.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            launchAtLogin.refresh()
        }
    }
}
