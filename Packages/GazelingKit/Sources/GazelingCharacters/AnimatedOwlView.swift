import SwiftUI

/// The owl playing the animation for one exercise step, redrawn every frame. Some exercises also
/// show a scene beside the owl.
public struct AnimatedOwlView: View {
    let script: String
    let stepStart: Date
    let stepDuration: TimeInterval
    let breakEnd: Date
    let height: CGFloat
    let palette: OwlPalette

    public init(
        script: String, stepStart: Date, stepDuration: TimeInterval, breakEnd: Date, height: CGFloat,
        palette: OwlPalette = .dusk
    ) {
        self.script = script
        self.stepStart = stepStart
        self.stepDuration = stepDuration
        self.breakEnd = breakEnd
        self.height = height
        self.palette = palette
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let scene = OwlAnimation.scene(for: script)
            HStack(spacing: height * 0.12) {
                OwlView(pose: pose(at: context.date), palette: palette)
                    .frame(width: height * OwlView.canvas.width / OwlView.canvas.height, height: height)
                if scene == .window {
                    WindowSceneView(time: context.date.timeIntervalSince(stepStart))
                        .frame(width: height, height: height)
                }
            }
        }
    }

    func pose(at date: Date) -> OwlPose {
        let base = OwlAnimation.pose(
            script: script, at: date.timeIntervalSince(stepStart), duration: stepDuration)
        // In the last seconds of the break the owl waves goodbye, whatever the exercise.
        let untilEnd = breakEnd.timeIntervalSince(date)
        let into = OwlAnimation.goodbyeLength - untilEnd
        guard into > 0 else { return base }
        let weight = OwlAnimation.smooth(into / 0.4)
        return base.blended(with: OwlAnimation.goodbyePose(at: into), weight)
    }
}
