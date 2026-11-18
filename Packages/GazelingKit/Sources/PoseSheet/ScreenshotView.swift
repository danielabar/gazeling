import GazelingCharacters
import SwiftUI

/// A break as it looks on a 1280 x 800 screen, for the README (`PoseSheet screenshot <out.png>`).
/// The layout copies `App/Overlay/BreakOverlayView.swift` (sizes, fonts, the 75% dim). The app
/// target cannot be imported here, so if that view changes, update this one too. The Skip button is
/// drawn, because `ImageRenderer` cannot draw AppKit-backed controls.
struct ScreenshotView: View {
    private let size = CGSize(width: 1280, height: 800)

    var body: some View {
        ZStack {
            desktop
            Color.black.opacity(0.75)
            breakContent.foregroundStyle(.white)
        }
        .frame(width: size.width, height: size.height)
    }

    /// A made-up desktop (wallpaper and menu bar), so the dim has something to dim.
    private var desktop: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color(red: 0.36, green: 0.55, blue: 0.80), Color(red: 0.85, green: 0.62, blue: 0.55)],
                startPoint: .topLeading, endPoint: .bottomTrailing)
            Color.white.opacity(0.8).frame(height: 24)
        }
    }

    private var breakContent: some View {
        VStack(spacing: 24) {
            HStack(spacing: 240 * 0.12) {
                OwlView(pose: OwlAnimation.pose(script: "look-far", at: 5, duration: 20))
                    .frame(height: 240)
                WindowSceneView(time: 20).frame(width: 240, height: 240)
            }
            Text(verbatim: "Look far away")
                .font(.system(size: 40, weight: .semibold))
            Text(verbatim: "Look at something at least 6 metres (20 feet) away, such as out of a window.")
                .font(.system(size: 30))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 720)
            Text(verbatim: "0:14")
                .font(.system(size: 28, weight: .medium).monospacedDigit())
            Text(verbatim: "Skip")
                .font(.system(size: 15))
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(RoundedRectangle(cornerRadius: 8).fill(.white.opacity(0.2)))
            Text(verbatim: "Press Esc to skip")
                .font(.callout)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(48)
    }
}
