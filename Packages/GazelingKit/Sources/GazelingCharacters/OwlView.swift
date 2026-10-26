import SwiftUI

/// The owl, drawn from separate parts in a fixed 200 x 240 space and scaled to fit.
/// Draw order, back to front: body, feet, belly, head (tufts, face, eyes, lids, brows, beak), wings.
public struct OwlView: View {
    public static let canvas = CGSize(width: 200, height: 240)

    let pose: OwlPose
    let palette: OwlPalette

    public init(pose: OwlPose = .neutral, palette: OwlPalette = .dusk) {
        self.pose = pose
        self.palette = palette
    }

    public var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / Self.canvas.width, proxy.size.height / Self.canvas.height)
            ZStack(alignment: .topLeading) {
                feet
                bodyShape.scaleEffect(1 + 0.03 * pose.breathe, anchor: UnitPoint(x: 0.5, y: 0.95))
                head
                wing(left: true)
                wing(left: false)
            }
            .offset(y: -pose.bounce)
            .frame(width: Self.canvas.width, height: Self.canvas.height, alignment: .topLeading)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: Self.canvas.width * scale, height: Self.canvas.height * scale, alignment: .topLeading)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(Self.canvas, contentMode: .fit)
        .accessibilityHidden(true)
    }

    // MARK: Body

    private var feet: some View {
        ZStack {
            Ellipse().fill(palette.beak).frame(width: 30, height: 14).position(x: 78, y: 230 - pose.leftFoot)
            Ellipse().fill(palette.beak).frame(width: 30, height: 14).position(x: 122, y: 230 - pose.rightFoot)
        }
    }

    private var bodyShape: some View {
        ZStack {
            Ellipse().fill(palette.body).frame(width: 150, height: 150).position(x: 100, y: 152)
            Ellipse().fill(palette.belly).frame(width: 96, height: 104).position(x: 100, y: 170)
            // Chest feathers.
            ForEach(0..<3, id: \.self) { row in
                ForEach(0..<(row == 1 ? 2 : 3), id: \.self) { col in
                    let count = row == 1 ? 2 : 3
                    let x = 100 + (Double(col) - Double(count - 1) / 2) * 26
                    Chevron().stroke(palette.body.opacity(0.35), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 16, height: 8)
                        .position(x: x, y: 152 + Double(row) * 20)
                }
            }
        }
    }

    // MARK: Head

    private var head: some View {
        ZStack {
            tuft(left: true)
            tuft(left: false)
            Ellipse().fill(palette.body).frame(width: 156, height: 124).position(x: 100, y: 88)
            Ellipse().fill(palette.face).frame(width: 128, height: 84).position(x: 100, y: 96)
            ForEach([66.0, 134.0], id: \.self) { x in
                Circle().fill(palette.face).frame(width: 68, height: 68).position(x: x, y: 92)
            }
            OwlEye(pose: pose, palette: palette).position(x: 66, y: 92)
            OwlEye(pose: pose, palette: palette).position(x: 134, y: 92)
            brow(left: true)
            brow(left: false)
            beak
        }
        .rotationEffect(.degrees(pose.headTilt), anchor: UnitPoint(x: 0.5, y: 0.56))
    }

    private func tuft(left: Bool) -> some View {
        Capsule().fill(palette.body)
            .frame(width: 26, height: 44)
            .rotationEffect(.degrees(left ? -28 : 28))
            .position(x: left ? 46 : 154, y: 38)
    }

    private func brow(left: Bool) -> some View {
        // Furrowing lowers the inner ends; raising lifts the whole brow.
        let tilt = (left ? -1.0 : 1.0) * pose.brow * 14
        return Capsule().fill(palette.brow)
            .frame(width: 30, height: 7)
            .rotationEffect(.degrees(tilt))
            .position(x: left ? 66 : 134, y: 52 - pose.brow * 5)
            .opacity(pose.wingCover > 0.5 ? 0 : 1)
    }

    private var beak: some View {
        Diamond().fill(palette.beak)
            .overlay(Diamond().stroke(palette.beak, style: StrokeStyle(lineWidth: 5, lineJoin: .round)))
            .frame(width: 16, height: 22)
            .position(x: 100, y: 114)
    }

    // MARK: Wings

    /// A wing hangs from its shoulder and swings about it. `raise` swings it outward. `wingCover`
    /// moves the shoulder in and swings the wing up so it cups over the eye, and widens it.
    private func wing(left: Bool) -> some View {
        let raise = left ? pose.leftWing : pose.rightWing
        let outward = 7.0 + raise
        let cover = pose.wingCover
        // Cover by swinging inward across the chest (-166 degrees), not outward past the side (194).
        let angle = outward + (-166.0 - outward) * cover
        let sign = left ? 1.0 : -1.0
        let shoulderX = (left ? 52.0 : 148.0) + (left ? 3.0 : -3.0) * cover
        let shoulderY = 128.0 + 11.0 * cover
        let length = 92.0
        return ZStack {
            WingShape().fill(palette.wing)
            WingShape().stroke(palette.body.opacity(0.4), lineWidth: 2).padding(5)
        }
        .frame(width: 38 * (1 + 0.5 * cover), height: length)
        .rotationEffect(.degrees(sign * angle), anchor: .top)
        .position(x: shoulderX, y: shoulderY + length / 2)
        .background {
            // Joins the wing to the body when it swings away.
            Circle().fill(palette.wing).frame(width: 26, height: 26).position(x: shoulderX, y: shoulderY + 6)
                .opacity(min(1, raise / 40) * (1 - cover))
        }
    }
}

// MARK: Eye

/// One eye: white, iris, pupil and shine, clipped to the eye, with lids that close over it.
struct OwlEye: View {
    let pose: OwlPose
    let palette: OwlPalette
    private let radius = 26.0

    var body: some View {
        let reach = radius - 14.0
        // Keep the iris inside the eye at diagonals too.
        let length = max(1, (pose.gazeX * pose.gazeX + pose.gazeY * pose.gazeY).squareRoot())
        let gaze = CGSize(width: pose.gazeX / length * reach, height: pose.gazeY / length * reach)
        ZStack {
            Circle().fill(palette.eyeWhite)
            Circle().fill(palette.iris).frame(width: 28, height: 28)
                .offset(x: gaze.width, y: gaze.height)
            Circle().fill(palette.pupil).frame(width: 14, height: 14)
                .offset(x: gaze.width, y: gaze.height)
            // The shine moves with the iris. (A highlight fixed to the eye while the pupil slides away
            // from it looks wrong in a cartoon.)
            Circle().fill(.white).frame(width: 7, height: 7)
                .offset(x: gaze.width - 5, y: gaze.height - 6)
            Circle().fill(.white.opacity(0.9)).frame(width: 3.5, height: 3.5)
                .offset(x: gaze.width + 4, y: gaze.height + 4)
            upperLid
            lowerLid
        }
        .frame(width: radius * 2, height: radius * 2)
        .clipShape(Circle())
        .overlay { if pose.eyelid > 0.9 { closedLash } }
        .overlay { happyArc.opacity(max(0, (pose.smile - 0.5) * 2) * (1 - pose.eyelid)) }
    }

    /// A big circle in the face colour whose lower edge sweeps down over the eye.
    private var upperLid: some View {
        let d = radius * 2
        return Circle().fill(palette.body)
            .frame(width: d * 1.5, height: d * 1.5)
            .offset(y: -d * 0.75 - radius + pose.eyelid * (d + 2) - 2 + radius * 0.0)
            .opacity(pose.eyelid > 0.001 ? 1 : 0)
    }

    /// Pushes the bottom of the eye up into a happy crescent.
    private var lowerLid: some View {
        let d = radius * 2
        return Circle().fill(palette.face)
            .frame(width: d * 1.3, height: d * 1.3)
            .offset(y: d * 0.65 + radius * 1.15 - pose.smile * radius * 2.15)
            .opacity(pose.smile > 0.001 ? 1 : 0)
    }

    /// Happy eyes: a curved line, like ^ ^.
    private var happyArc: some View {
        Arc().stroke(palette.pupil, style: StrokeStyle(lineWidth: 4.5, lineCap: .round))
            .frame(width: radius * 1.5, height: 11)
            .scaleEffect(y: -1)
            .offset(y: 2)
    }

    private var closedLash: some View {
        Arc().stroke(palette.brow, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
            .frame(width: radius * 1.6, height: 10)
            .offset(y: 2)
    }
}

// MARK: Small shapes

struct Diamond: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.midY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX, y: r.midY))
        p.closeSubpath()
        return p
    }
}

struct Chevron: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addLine(to: CGPoint(x: r.midX, y: r.maxY))
        p.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        return p
    }
}

/// A curve bulging downward, used for closed eyes.
struct Arc: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.minY))
        p.addQuadCurve(to: CGPoint(x: r.maxX, y: r.minY), control: CGPoint(x: r.midX, y: r.maxY * 2))
        return p
    }
}

/// A rounded teardrop: narrow at the shoulder, widest below the middle, rounded tip.
struct WingShape: Shape {
    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.midX, y: r.minY))
        p.addCurve(
            to: CGPoint(x: r.maxX, y: r.minY + r.height * 0.62),
            control1: CGPoint(x: r.maxX * 0.85, y: r.minY),
            control2: CGPoint(x: r.maxX, y: r.minY + r.height * 0.3))
        p.addCurve(
            to: CGPoint(x: r.midX, y: r.maxY),
            control1: CGPoint(x: r.maxX, y: r.minY + r.height * 0.88),
            control2: CGPoint(x: r.maxX * 0.72, y: r.maxY))
        p.addCurve(
            to: CGPoint(x: r.minX, y: r.minY + r.height * 0.62),
            control1: CGPoint(x: r.maxX * 0.28, y: r.maxY),
            control2: CGPoint(x: r.minX, y: r.minY + r.height * 0.88))
        p.addCurve(
            to: CGPoint(x: r.midX, y: r.minY),
            control1: CGPoint(x: r.minX, y: r.minY + r.height * 0.3),
            control2: CGPoint(x: r.maxX * 0.15, y: r.minY))
        p.closeSubpath()
        return p
    }
}
