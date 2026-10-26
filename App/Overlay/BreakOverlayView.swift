import GazelingKit
import SwiftUI

/// Content of the break overlay. Shown on one screen only; the other screens just dim.
struct BreakOverlayView: View {
    let session: BreakSession
    let onSkip: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            PlaceholderCharacter()
            Text(LocalizedStringKey(session.step.exercise.titleKey))
                .font(.system(size: 40, weight: .semibold))
            Text(LocalizedStringKey(session.step.exercise.instructionKey))
                .font(.title2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 560)
            Text(Duration.seconds(Int(session.remaining.rounded(.up))), format: .time(pattern: .minuteSecond))
                .font(.system(size: 28, weight: .medium).monospacedDigit())
                .accessibilityLabel(Text("Time left"))
            Button("Skip", action: onSkip)
                .buttonStyle(.bordered)
                .controlSize(.large)
            Text("Press Esc to skip")
                .font(.callout)
                .foregroundStyle(.secondary)
        }
        .foregroundStyle(.white)
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
