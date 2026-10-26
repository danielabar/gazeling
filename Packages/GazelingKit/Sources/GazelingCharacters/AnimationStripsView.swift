import SwiftUI

/// Frames of every exercise animation side by side, for checking motion without watching it live.
public struct AnimationStripsView: View {
    public init() {}

    private let frames = 8
    private let rows: [(script: String, duration: Double, span: Double)] = [
        ("blink", 20, 2 * 2), ("look-far", 20, 12), ("side-to-side", 20, 5), ("up-down", 20, 5),
        ("circle-left", 20, 4), ("circle-right", 20, 4), ("palming", 20, 20), ("walk", 20, 2),
        ("eyes-closed-rest", 20, 20),
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(rows, id: \.script) { row in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(row.script)  (frames evenly across \(String(format: "%g", row.span)) s)")
                        .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
                    HStack(spacing: 6) {
                        ForEach(0..<frames, id: \.self) { i in
                            // Start slightly in so the first frame is not the neutral blend-in.
                            let t = 0.5 + row.span * Double(i) / Double(frames)
                            OwlView(pose: OwlAnimation.pose(script: row.script, at: t, duration: row.duration))
                                .frame(width: 100, height: 120)
                        }
                    }
                }
            }
            Text("look-far with the window scene (owl and scene at 0, 3, 6, 9, 12 s)")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
            HStack(spacing: 14) {
                ForEach([0.0, 3, 6, 9, 12], id: \.self) { t in
                    HStack(spacing: 4) {
                        OwlView(pose: OwlAnimation.pose(script: "look-far", at: t + 0.5, duration: 20))
                            .frame(width: 75, height: 90)
                        WindowSceneView(time: t * 4).frame(width: 90, height: 90)
                    }
                }
            }
            Text("goodbye wave (frames across \(String(format: "%g", OwlAnimation.goodbyeLength)) s)")
                .font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
            HStack(spacing: 6) {
                ForEach(0..<frames, id: \.self) { i in
                    OwlView(pose: OwlAnimation.goodbyePose(at: OwlAnimation.goodbyeLength * Double(i) / Double(frames)))
                        .frame(width: 100, height: 120)
                }
            }
        }
        .padding(24)
        .background(Color(red: 0.08, green: 0.08, blue: 0.10))
    }
}

/// The owl and window scene at about the size they have on the break screen.
public struct ScenePreviewView: View {
    public init() {}

    public var body: some View {
        HStack(spacing: 36) {
            OwlView(pose: OwlAnimation.pose(script: "look-far", at: 5, duration: 20))
                .frame(width: 250, height: 300)
            WindowSceneView(time: 20).frame(width: 300, height: 300)
        }
        .padding(40)
        .background(Color(red: 0.08, green: 0.08, blue: 0.10))
    }
}
