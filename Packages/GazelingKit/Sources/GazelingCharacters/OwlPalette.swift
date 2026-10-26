import SwiftUI

/// Colours for the owl. Several are offered so the look can be chosen; only one ships.
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

    public static let honey = OwlPalette(
        name: "Honey",
        body: Color(hex: 0xE2A64F), wing: Color(hex: 0xC4822F), belly: Color(hex: 0xFFE8BF),
        face: Color(hex: 0xFFF6E4), eyeWhite: Color(hex: 0xFFFFFF), iris: Color(hex: 0x4A5D8F),
        pupil: Color(hex: 0x1D2238), beak: Color(hex: 0xE2693C), brow: Color(hex: 0x9C6420))

    public static let mist = OwlPalette(
        name: "Mist",
        body: Color(hex: 0x8DA2B9), wing: Color(hex: 0x6E869E), belly: Color(hex: 0xE5EDF4),
        face: Color(hex: 0xF7F9FB), eyeWhite: Color(hex: 0xFFFFFF), iris: Color(hex: 0x8A63B5),
        pupil: Color(hex: 0x231B33), beak: Color(hex: 0xF0A64B), brow: Color(hex: 0x56697E))

    public static let all = [dusk, honey, mist]
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255, green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255)
    }
}
