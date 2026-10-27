import GazelingKit
import SwiftUI

struct SettingsView: View {
    let appState: AppState

    var body: some View {
        TabView {
            GeneralSettingsView(appState: appState)
                .tabItem { Label("General", systemImage: "gearshape") }
            BreaksSettingsView(appState: appState)
                .tabItem { Label("Breaks", systemImage: "timer") }
            ExercisesSettingsView(appState: appState)
                .tabItem { Label("Exercises", systemImage: "figure.mind.and.body") }
        }
        .frame(width: 560, height: 740)
    }
}

extension AppState {
    /// A binding to one setting that validates, saves and applies each change.
    func binding<Value>(_ keyPath: WritableKeyPath<GazelingKit.Settings, Value>) -> Binding<Value> {
        Binding(
            get: { self.settings[keyPath: keyPath] },
            set: { newValue in
                var updated = self.settings
                updated[keyPath: keyPath] = newValue
                self.apply(settings: updated)
            })
    }
}
