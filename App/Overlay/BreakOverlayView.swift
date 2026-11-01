import GazelingCharacters
import GazelingKit
import SwiftUI

/// Content of the break overlay. Shown on one screen only; the other screens just dim.
struct BreakOverlayView: View {
    let session: BreakSession
    let onSkip: () -> Void

    /// Owl size on the break screen: a share of the screen height, kept between two limits.
    /// Change these if it looks wrong on a very small or very large display.
    private enum OwlSize {
        static let screenHeightFraction = 0.30
        static let minHeight = 240.0
        static let maxHeight = 360.0
    }

    var body: some View {
        GeometryReader { proxy in
            let owlHeight = min(
                OwlSize.maxHeight, max(OwlSize.minHeight, proxy.size.height * OwlSize.screenHeightFraction))
            VStack(spacing: 24) {
                AnimatedOwlView(
                    script: session.step.exercise.animationScript, stepStart: session.stepStartedAt,
                    stepDuration: session.step.seconds, breakEnd: session.endsAt, height: owlHeight
                )
                Text(LocalizedStringKey(session.step.exercise.titleKey))
                    .font(.system(size: 40, weight: .semibold))
                Text(LocalizedStringKey(session.step.exercise.instructionKey))
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 720)
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
}
