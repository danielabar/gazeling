import SwiftUI

/// A contact sheet for reviewing the owl's look: poses, palettes and real-size rendering.
public struct PoseSheetView: View {
    public init() {}

    private let poses: [(String, OwlPose)] = [
        ("Neutral", .neutral), ("Happy", .happy), ("Concentrating", .concentrating), ("Eyes closed", .eyesClosed),
        ("Wings over eyes (palming)", .palming), ("Wave goodbye", .wave), ("Look far left", .lookLeft),
        ("Look up right", .lookUpRight),
    ]

    public var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            section("Poses (\(OwlPalette.dusk.name) palette)") {
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(210), spacing: 16), count: 4), spacing: 20) {
                    ForEach(poses, id: \.0) { name, pose in
                        cell(name) { OwlView(pose: pose).frame(width: 200, height: 240) }
                    }
                }
            }
            section("Palettes (neutral and happy)") {
                HStack(spacing: 16) {
                    ForEach(OwlPalette.all, id: \.name) { palette in
                        cell(palette.name) {
                            HStack(spacing: 4) {
                                OwlView(pose: .neutral, palette: palette).frame(width: 125, height: 150)
                                OwlView(pose: .happy, palette: palette).frame(width: 125, height: 150)
                            }
                        }
                    }
                }
            }
            section("Real size on the break screen (about 150 pt tall)") {
                HStack(spacing: 16) {
                    ForEach(poses.prefix(6), id: \.0) { _, pose in
                        OwlView(pose: pose).frame(width: 125, height: 150)
                    }
                }
            }
        }
        .padding(32)
        .frame(width: 960, alignment: .leading)
        .background(Color(red: 0.08, green: 0.08, blue: 0.10))
        .environment(\.colorScheme, .dark)
    }

    private func section<C: View>(_ title: String, @ViewBuilder content: () -> C) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.system(size: 18, weight: .semibold)).foregroundStyle(.white)
            content()
        }
    }

    private func cell<C: View>(_ label: String, @ViewBuilder content: () -> C) -> some View {
        VStack(spacing: 6) {
            content()
            Text(label).font(.system(size: 13)).foregroundStyle(.white.opacity(0.7))
        }
    }
}
