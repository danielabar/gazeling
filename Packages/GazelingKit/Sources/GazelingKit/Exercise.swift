import Foundation

/// A short break is one quick eye exercise. A long break is the "stand up and walk" break.
public enum BreakKind: String, Codable, Sendable, CaseIterable {
    case short
    case long
}

/// One eye exercise, loaded from `exercises.json`. Holds localization keys, not display text.
public struct Exercise: Codable, Sendable, Equatable, Identifiable {
    public let id: String
    public let titleKey: String
    public let instructionKey: String
    /// Nominal length. A break stretches the exercise to its own duration.
    public let durationSeconds: TimeInterval
    /// Which kind of break this exercise appears in. Only "Stand up and walk" is a long break exercise.
    public let breakKind: BreakKind
    public let animationScript: String
}
