import Foundation

/// A short break only fits one exercise; a long break chains several.
public enum BreakKind: String, Codable, Sendable, CaseIterable {
    case short
    case long
}

/// One eye exercise, loaded from `exercises.json`. Holds localization keys, not display text.
public struct Exercise: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let titleKey: String
    public let instructionKey: String
    /// Nominal length. A break stretches or repeats exercises to fit its own duration.
    public let durationSeconds: TimeInterval
    public let defaultBreakKinds: Set<BreakKind>
    /// Long breaks always start with these (when enabled), so they are never dropped by a short rotation.
    public let includedInEveryLongBreak: Bool
    public let animationScript: String
}
