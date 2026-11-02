import GazelingKit
import SwiftUI

struct FirstRunView: View {
    let model: FirstRunModel
    let onDone: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Welcome to Gazeling")
                    .font(.largeTitle.bold())
                Text(
                    "Gazeling lives in your menu bar and reminds you to rest your eyes. During a break it dims your screens and an owl guides a short eye exercise."
                )
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Form {
                Section("Notifications") {
                    Text("Gazeling can show a heads-up shortly before each break, so a break never starts by surprise.")
                    notificationRow
                }
                Section("When I log in") {
                    Toggle(
                        "Start Gazeling when I log in",
                        isOn: Binding(
                            get: { model.launchAtLogin.isOn }, set: { model.launchAtLogin.setEnabled($0) }))
                    if model.launchAtLogin.needsApproval {
                        Text(
                            "macOS needs your approval. Turn Gazeling on in System Settings → General → Login Items & Extensions."
                        )
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        Button("Open Login Items") { model.launchAtLogin.openSystemSettings() }
                    }
                    if let message = model.launchAtLogin.errorMessage {
                        Text(message)
                            .font(.callout)
                            .foregroundStyle(.red)
                    }
                }
            }
            .formStyle(.grouped)

            HStack {
                Text("You can change all of this later in Settings.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Done", action: onDone)
                    .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 520, height: 560)
        .task { await model.refresh() }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            Task { await model.refresh() }
        }
    }

    @ViewBuilder
    private var notificationRow: some View {
        switch model.notificationPermission {
        case .notAsked:
            Button("Allow notifications") { Task { await model.allowNotifications() } }
        case .allowed:
            Label("Notifications are on", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        case .denied:
            Text("Notifications are turned off for Gazeling. macOS only lets you change this in System Settings.")
                .font(.callout)
                .foregroundStyle(.secondary)
            Button("Open Notification settings") { model.openNotificationSettings() }
        }
    }
}
