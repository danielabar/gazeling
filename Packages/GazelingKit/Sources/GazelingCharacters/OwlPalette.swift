import SwiftUI

/// Colours for the owl. Dusk is the only palette; the icons adjust a copy of it.
public struct OwlPalette: Sendable {
    public var name: String
    public var body: Color
    public var wing: Color
    public var belly: Color
    public var face: Color
    public var eyeWhite: Color
    public var iris: Color
    public var pupil: Color
    public var beak: Color
    public var brow: Color

    public static let dusk = OwlPalette(
        name: "Dusk",
        body: Color(hex: 0x5E64B8), wing: Color(hex: 0x4A4F9A), belly: Color(hex: 0xD8DAF4),
        face: Color(hex: 0xF4EFE6), eyeWhite: Color(hex: 0xFFFFFF), iris: Color(hex: 0xE8A33D),
        pupil: Color(hex: 0x1F1A33), beak: Color(hex: 0xF2A541), brow: Color(hex: 0x3B3F82))
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255)
    }
}
