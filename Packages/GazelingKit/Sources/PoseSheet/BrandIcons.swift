import GazelingCharacters
import SwiftUI

// The app icon and the menu bar icon, drawn from the owl code so they stay original art and can be
// regenerated. `scripts/generate-icons.sh` renders them into `App/Assets.xcassets`.

/// The app icon: the happy owl (eyes closed) on a dark night gradient, head and chest only.
/// Follows the macOS icon grid: on a canvas of `size`, a rounded square inset to 824/1024 with a
/// 185/1024 corner radius and a soft shadow.
struct AppIconView: View {
    var size: CGFloat = 1024

    var body: some View {
        let s = size / 1024
        // The white of the eye in the face colour, so the face is one cream shape.
        var palette = OwlPalette.dusk
        palette.eyeWhite = palette.face
        return ZStack {
            LinearGradient(colors: [rgb(0x23264F), rgb(0x5B4E99)], startPoint: .top, endPoint: .bottom)
            // A big owl, shifted down so only the head and chest show, clipped by the rounded square.
            OwlView(pose: .happy, palette: palette).frame(width: 760 * s, height: 912 * s).offset(y: 190 * s)
        }
        .frame(width: 824 * s, height: 824 * s)
        .clipShape(RoundedRectangle(cornerRadius: 185 * s, style: .continuous))
        // Without this, every part of the owl casts its own shadow (rings around the eyes).
        .compositingGroup()
        .shadow(color: .black.opacity(0.3), radius: 10 * s, y: 6 * s)
        .frame(width: size, height: size)
    }
}

/// The menu bar icon: two ringed owl eyes with ear tufts, in black only. The asset catalog marks it
/// as a template image, so macOS tints it for light and dark menu bars. Drawn on an 18 x 18 grid.
struct MenuBarIconView: View {
    var size: CGFloat = 18

    var body: some View {
        let u = size / 18
        return ZStack {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Circle().stroke(lineWidth: 1.6 * u).frame(width: 7.4 * u, height: 7.4 * u)
                    .offset(x: side * 4 * u, y: 2.5 * u)
                Circle().frame(width: 3 * u, height: 3 * u).offset(x: side * 4 * u, y: 2.5 * u)
                Capsule().frame(width: 1.6 * u, height: 4.5 * u)
                    .rotationEffect(.degrees(side * 28))
                    .offset(x: side * 6.4 * u, y: -4.2 * u)
            }
        }
        .foregroundStyle(.black)
        .frame(width: size, height: size)
    }
}

private func rgb(_ hex: UInt32) -> Color {
    Color(
        red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255,
        blue: Double(hex & 0xFF) / 255)
}

/// Writes every PNG the asset catalog needs into the two image set folders.
@MainActor
func renderIcons(appIconSet: String, menuBarIconSet: String) {
    // macOS app icon sizes: 16, 32, 128, 256 and 512 points, each at 1x and 2x.
    for points in [16, 32, 128, 256, 512] {
        for scale in [1, 2] {
            let name = scale == 1 ? "icon_\(points)x\(points).png" : "icon_\(points)x\(points)@2x.png"
            render(AppIconView(size: CGFloat(points * scale)), scale: 1, to: "\(appIconSet)/\(name)")
        }
    }
    render(MenuBarIconView(), scale: 1, to: "\(menuBarIconSet)/menubar.png")
    render(MenuBarIconView(), scale: 2, to: "\(menuBarIconSet)/menubar@2x.png")
}
