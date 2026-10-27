import GazelingKit
import SwiftUI

struct BreaksSettingsView: View {
    let appState: AppState

    var body: some View {
        Form {
            Section("Short break") {
                row("Every", \.shortBreakInterval, GazelingKit.Settings.shortIntervalRange, step: 60)
                row("Lasts", \.shortBreakDuration, GazelingKit.Settings.shortDurationRange, step: 5)
            }
            Section("Long break") {
                Toggle("Take long breaks", isOn: appState.binding(\.longBreaksEnabled))
                    .disabled(appState.settings.longBreaksEnabled && !appState.canTurnOffLongBreaks)
                row("Every", \.longBreakInterval, GazelingKit.Settings.longIntervalRange, step: 300)
                    .disabled(!appState.settings.longBreaksEnabled)
                row("Lasts", \.longBreakDuration, GazelingKit.Settings.longDurationRange, step: 60)
                    .disabled(!appState.settings.longBreaksEnabled)
            }
            Section("Heads-up") {
                row("Notify me before a break", \.headsUpLead, GazelingKit.Settings.headsUpRange, step: 5)
                row("Postpone by", \.postponeDuration, GazelingKit.Settings.postponeRange, step: 60)
            }
            Section {
                Button("Restore default timings") { appState.restoreDefaultTimings() }
                    .disabled(appState.settings.hasDefaultTimings)
            }
        }
        .formStyle(.grouped)
    }

    private func row(
        _ title: LocalizedStringKey, _ keyPath: WritableKeyPath<GazelingKit.Settings, TimeInterval>,
        _ range: ClosedRange<TimeInterval>, step: TimeInterval
    ) -> some View {
        LabeledContent(title) {
            HStack {
                Text(DurationText.format(appState.settings[keyPath: keyPath]))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Stepper(title, value: appState.binding(keyPath), in: range, step: step)
                    .labelsHidden()
            }
        }
    }

}
