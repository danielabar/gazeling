import Foundation

/// The owl's movement as pure functions of time, so it can be tested and rendered to still frames.
/// Each exercise names a script (`animationScript` in `exercises.json`); `pose` returns the owl's pose
/// `t` seconds into a step that lasts `duration` seconds.
public enum OwlAnimation {
    /// Script ids that have an animation. A test checks every exercise in the catalog is listed here.
    public static let scriptIDs: Set<String> = [
        "blink", "look-far", "side-to-side", "up-down", "circle-left", "circle-right", "palming", "walk",
        "eyes-closed-rest",
    ]

    /// A scene drawn beside the owl for an exercise, or nil for the owl alone.
    public static func scene(for script: String) -> OwlScene? {
        script == "look-far" ? .window : nil
    }

    /// Seconds the owl takes to settle into a step's first pose and back out of its last.
    static let edgeBlend = 0.5
    /// Seconds before the end of a whole break that the owl waves goodbye.
    public static let goodbyeLength = 2.2

    public static func pose(script: String, at t: TimeInterval, duration: TimeInterval) -> OwlPose {
        let base = scriptPose(script, t: t, duration: duration)
        // Ease in from, and back out to, a neutral pose, so steps and the cut at the end of a step never jump.
        let edge = min(smooth(t / edgeBlend), smooth((duration - t) / edgeBlend))
        var pose = OwlPose().blended(with: base, edge)
        addIdle(&pose, script: script, t: t)
        return pose
    }

    /// The wave at the very end of a break. `t` counts from the start of the goodbye.
    public static func goodbyePose(at t: TimeInterval) -> OwlPose {
        var pose = OwlPose()
        pose.smile = 1
        pose.brow = 0.6
        pose.headTilt = 5
        pose.rightWing = 110 + 18 * sin(t * 2 * .pi * 2)
        addIdle(&pose, script: "goodbye", t: t)
        return pose
    }

    // MARK: Scripts

    private static func scriptPose(_ script: String, t: Double, duration: Double) -> OwlPose {
        var p = OwlPose()
        switch script {
        case "blink":
            // A slow, deliberate blink every 2 s (10 in 20 s): close, squeeze, open, rest.
            let u = t.truncatingRemainder(dividingBy: 2)
            p.eyelid = keyed(u, [(0, 0), (0.4, 1), (1.1, 1), (1.6, 0), (2, 0)])
            p.brow = -0.35 * p.eyelid
        case "look-far":
            let u = t.truncatingRemainder(dividingBy: 12)
            // Looks out of the window, which is drawn to the owl's right, then back.
            let toWindow = keyed(u, [(0, 0), (1.5, 1), (9, 1), (10.5, 0), (12, 0)])
            p.gazeX = 0.9 * toWindow
            p.gazeY = -0.15 * toWindow
            p.headTilt = 4 * toWindow
            p.brow = 0.4 * toWindow
        case "side-to-side":
            p.gazeX = sweep(t)
        case "up-down":
            p.gazeY = sweep(t)
        case "circle-left", "circle-right":
            // Counter-clockwise for left, clockwise for right, starting at the top. One lap takes 4 s.
            let angle = t / 4 * 2 * .pi
            p.gazeX = (script == "circle-left" ? -1 : 1) * sin(angle)
            p.gazeY = -cos(angle)
        case "palming":
            p.wingCover = keyed(t, [(0, 0), (1.2, 1), (duration - 1.2, 1), (duration, 0)])
            p.eyelid = keyed(t, [(0, 0), (0.9, 1), (duration - 0.9, 1), (duration, 0)])
            p.headTilt = 2 * p.wingCover
        case "walk":
            // Marching in place: alternate feet and wings, with a small bounce.
            let cycle = t * 2 * .pi
            p.bounce = 5 * abs(sin(cycle / 2))
            p.leftFoot = 8 * max(0, sin(cycle))
            p.rightFoot = 8 * max(0, -sin(cycle))
            p.leftWing = 22 * max(0, -sin(cycle))
            p.rightWing = 22 * max(0, sin(cycle))
            p.smile = 1
        case "eyes-closed-rest":
            p.eyelid = keyed(t, [(0, 0), (1.5, 1), (duration - 1.5, 1), (duration, 0)])
            p.brow = 0.2
            p.smile = 0.2 * p.eyelid
        default:
            break
        }
        return p
    }

    /// Looks to one side, pauses, looks to the other, pauses, returns to centre. One sweep takes 5 s.
    private static func sweep(_ t: Double) -> Double {
        let u = t.truncatingRemainder(dividingBy: 5)
        return keyed(u, [(0, 0), (0.8, -1), (1.5, -1), (3.3, 1), (4.0, 1), (5, 0)])
    }

    // MARK: Idle life

    /// Breathing, a slow sway and occasional blinks, so the owl is never frozen.
    private static func addIdle(_ pose: inout OwlPose, script: String, t: Double) {
        pose.breathe = (sin(t * 2 * .pi / 4) + 1) / 2
        pose.headTilt += 1.5 * sin(t * 2 * .pi / 6)
        // The blink and rest scripts control the eyelids themselves.
        guard !["blink", "palming", "eyes-closed-rest"].contains(script) else { return }
        pose.eyelid = max(pose.eyelid, idleBlink(t))
    }

    /// One quick blink in every 3.2 s window, at a pseudo-random moment so it does not look mechanical.
    static func idleBlink(_ t: Double) -> Double {
        let window = 3.2
        let k = floor(t / window)
        let start = k * window + 0.3 + 1.6 * fract(sin(k * 12.9898) * 43758.5453)
        return keyed(t - start, [(0, 0), (0.08, 1), (0.2, 0), (1, 0)], outside: 0)
    }

    // MARK: Helpers

    private static func fract(_ x: Double) -> Double { x - floor(x) }

    /// 0 to 1 with soft ends.
    static func smooth(_ x: Double) -> Double {
        let c = min(1, max(0, x))
        return c * c * (3 - 2 * c)
    }

    /// Value at time `t` along `points` (time, value), easing between neighbours. Before the first
    /// point it is `outside` (default: the first value); after the last it holds the last value.
    static func keyed(_ t: Double, _ points: [(Double, Double)], outside: Double? = nil) -> Double {
        guard let first = points.first, let last = points.last else { return 0 }
        if t < first.0 { return outside ?? first.1 }
        if t >= last.0 { return outside != nil && t > last.0 ? outside! : last.1 }
        for (a, b) in zip(points, points.dropFirst()) where t >= a.0 && t < b.0 {
            return a.1 + (b.1 - a.1) * smooth((t - a.0) / (b.0 - a.0))
        }
        return last.1
    }
}
