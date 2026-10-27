import GazelingKit
import SwiftUI

struct ExercisesSettingsView: View {
    let appState: AppState

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            explanation
            notes
            List {
                Section("Short breaks") {
                    ForEach(exercises(for: .short)) { ExerciseRow(exercise: $0, appState: appState) }
                }
                Section("Long break") {
                    ForEach(exercises(for: .long)) { ExerciseRow(exercise: $0, appState: appState) }
                }
            }
        }
        .padding()
    }

    private func exercises(for kind: BreakKind) -> [Exercise] {
        appState.exercises.filter { $0.breakKind == kind }
    }

    private var explanation: some View {
        let s = appState.settings
        let short = BreaksSettingsView.format(s.shortBreakDuration)
        let long = BreaksSettingsView.format(s.longBreakDuration)
        return VStack(alignment: .leading, spacing: 6) {
            Text("A short break shows one of the exercises below, for \(short).")
            Text("The long break is a walk, for \(long).")
            Text("Switch off any exercise you don't want to see.")
                .foregroundStyle(.secondary)
        }
    }

    /// A break kind with no enabled exercise never happens. Say so instead of leaving it a mystery.
    @ViewBuilder private var notes: some View {
        if !appState.availableBreakKinds.contains(.short) {
            note("Short breaks are off, because every short break exercise is switched off.")
        }
        if appState.settings.longBreaksEnabled, !appState.availableBreakKinds.contains(.long) {
            note("The long break is off, because the walk is switched off.")
        }
        if appState.exercises.contains(where: { appState.settings.isEnabled($0) && !appState.canSwitchOff($0) }) {
            note("At least one break has to stay on. To stop breaks for a while, use Pause in the eye menu.")
        }
    }

    private func note(_ text: LocalizedStringKey) -> some View {
        Label(text, systemImage: "info.circle")
            .foregroundStyle(.secondary)
    }
}

private struct ExerciseRow: View {
    let exercise: Exercise
    let appState: AppState

    var body: some View {
        Toggle(isOn: enabledBinding) {
            VStack(alignment: .leading, spacing: 2) {
                Text(LocalizedStringKey(exercise.titleKey))
                Text(LocalizedStringKey(exercise.instructionKey))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .disabled(appState.settings.isEnabled(exercise) && !appState.canSwitchOff(exercise))
        .padding(.vertical, 4)
    }

    private var enabledBinding: Binding<Bool> {
        Binding(
            get: { appState.settings.isEnabled(exercise) },
            set: { enabled in
                var s = appState.settings
                s.setEnabled(enabled, for: exercise)
                appState.apply(settings: s)
            })
    }
}
