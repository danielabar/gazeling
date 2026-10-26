import SwiftUI

/// A window looking out on a calm view: sky, drifting clouds, a low sun, hills, trees and grass.
/// Drawn in a fixed 240 x 240 space. `time` (seconds) moves the clouds and sways the tree.
public struct WindowSceneView: View {
    public static let canvas = CGSize(width: 240, height: 240)
    let time: Double

    public init(time: Double = 0) {
        self.time = time
    }

    private let glass = CGRect(x: 14, y: 14, width: 212, height: 186)

    public var body: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / Self.canvas.width, proxy.size.height / Self.canvas.height)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16).fill(Color(hex: 0xF4EFE6))
                    .frame(width: 240, height: 214)
                view
                    .frame(width: glass.width, height: glass.height)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .offset(x: glass.minX, y: glass.minY)
                // Cross bars.
                Rectangle().fill(Color(hex: 0xF4EFE6)).frame(width: 8, height: glass.height)
                    .offset(x: glass.midX - 4, y: glass.minY)
                Rectangle().fill(Color(hex: 0xF4EFE6)).frame(width: glass.width, height: 8)
                    .offset(x: glass.minX, y: glass.midY - 4)
                // Sill.
                RoundedRectangle(cornerRadius: 6).fill(Color(hex: 0xD9CFE8))
                    .frame(width: 252, height: 20).offset(x: -6, y: 208)
            }
            .frame(width: Self.canvas.width, height: Self.canvas.height, alignment: .topLeading)
            .scaleEffect(scale, anchor: .topLeading)
            .frame(width: Self.canvas.width * scale, height: Self.canvas.height * scale, alignment: .topLeading)
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityHidden(true)
    }

    /// The view through the glass, in a 212 x 186 space.
    private var view: some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [Color(hex: 0x4D63C4), Color(hex: 0xB79BD0), Color(hex: 0xF7C6A5)],
                startPoint: .top, endPoint: .bottom)
            // Low sun with a soft glow.
            Circle().fill(Color(hex: 0xFFE2B8).opacity(0.35)).frame(width: 78, height: 78).blur(radius: 8)
                .position(x: 150, y: 112)
            Circle().fill(Color(hex: 0xFFE9C8)).frame(width: 30, height: 30).position(x: 150, y: 112)
            cloud(base: 20, y: 34, size: 1.0, speed: 3)
            cloud(base: 130, y: 62, size: 0.7, speed: 5)
            cloud(base: 80, y: 88, size: 0.55, speed: 2)
            // Far hills are lighter and bluer, so they look further away.
            Hills(phase: 0.0, base: 0.62, amplitude: 0.07).fill(Color(hex: 0x9AA0DA))
            Hills(phase: 1.7, base: 0.72, amplitude: 0.08).fill(Color(hex: 0x7A80CC))
            tree(x: 150, baseY: 132, size: 0.5, color: Color(hex: 0x8FB0B0), sway: 0.5)
            tree(x: 62, baseY: 150, size: 1.0, color: Color(hex: 0x7FB89B), sway: 1)
            Hills(phase: 3.1, base: 0.86, amplitude: 0.05).fill(Color(hex: 0x8CC8A0))
            Hills(phase: 4.4, base: 0.94, amplitude: 0.04).fill(Color(hex: 0x6FAF8A))
        }
        .frame(width: glass.width, height: glass.height)
    }

    /// A cloud drifting left to right, wrapping around the edges.
    private func cloud(base: Double, y: Double, size: Double, speed: Double) -> some View {
        let span = glass.width + 120
        let x = (base + time * speed).truncatingRemainder(dividingBy: span) - 60
        return ZStack {
            Ellipse().frame(width: 62, height: 20).offset(x: 0, y: 6)
            Circle().frame(width: 30, height: 30).offset(x: -12, y: -2)
            Circle().frame(width: 38, height: 38).offset(x: 8, y: -6)
        }
        .foregroundStyle(.white.opacity(0.88))
        .scaleEffect(size)
        .position(x: x, y: y)
    }

    private func tree(x: Double, baseY: Double, size: Double, color: Color, sway: Double) -> some View {
        // Drawn in an 80 x 80 box, offsets measured from its centre; the ground is the box's bottom edge.
        ZStack {
            RoundedRectangle(cornerRadius: 3).fill(Color(hex: 0x5A4A6E)).frame(width: 8, height: 38)
                .offset(y: 21)
            Circle().fill(color).frame(width: 46, height: 46).offset(y: -12)
            Circle().fill(color).frame(width: 34, height: 34).offset(x: -17, y: 2)
            Circle().fill(color).frame(width: 34, height: 34).offset(x: 17, y: 2)
            Circle().fill(.white.opacity(0.12)).frame(width: 24, height: 24).offset(x: -6, y: -20)
        }
        .frame(width: 80, height: 80)
        .rotationEffect(.degrees(sway * 1.5 * sin(time * 2 * .pi / 5)), anchor: .bottom)
        .scaleEffect(size, anchor: .bottom)
        .position(x: x, y: baseY - 40 * size)
    }
}

/// A gently rolling ridge filling the bottom of the shape. `base` is the ridge height as a share of the
/// shape's height, measured from the top.
struct Hills: Shape {
    let phase: Double
    let base: Double
    let amplitude: Double

    func path(in r: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: r.minX, y: r.maxY))
        let steps = 40
        for i in 0...steps {
            let u = Double(i) / Double(steps)
            let y = base + amplitude * sin(u * 2 * .pi * 1.3 + phase)
            p.addLine(to: CGPoint(x: r.minX + u * r.width, y: r.minY + y * r.height))
        }
        p.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        p.closeSubpath()
        return p
    }
}
