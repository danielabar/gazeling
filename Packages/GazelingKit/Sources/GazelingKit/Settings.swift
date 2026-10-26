import Foundation

/// User settings. Decoding tolerates missing keys (falls back to the default), so adding a
/// setting in a later version does not wipe what users already saved.
public struct Settings: Codable, Sendable, Equatable {
  public var shortBreakInterval: TimeInterval = 20 * 60
  public var shortBreakDuration: TimeInterval = 20
  public var longBreaksEnabled = true
  public var longBreakInterval: TimeInterval = 60 * 60
  public var longBreakDuration: TimeInterval = 5 * 60
  /// How long before a break the heads-up notification appears.
  public var headsUpLead: TimeInterval = 30
  public var postponeDuration: TimeInterval = 5 * 60
  /// Stored as the disabled set, so exercises added in a later version default to enabled.
  public var disabledExerciseIDs: Set<String> = []
  /// Per-exercise override of the exercise's default break kinds.
  public var breakKindOverrides: [String: Set<BreakKind>] = [:]

  public init() {}

  public func breakKinds(for exercise: Exercise) -> Set<BreakKind> {
    breakKindOverrides[exercise.id] ?? exercise.defaultBreakKinds
  }

  public func breakInterval(for kind: BreakKind) -> TimeInterval {
    kind == .short ? shortBreakInterval : longBreakInterval
  }

  public func breakDuration(for kind: BreakKind) -> TimeInterval {
    kind == .short ? shortBreakDuration : longBreakDuration
  }

  public init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    let d = Settings()
    shortBreakInterval =
      try c.decodeIfPresent(TimeInterval.self, forKey: .shortBreakInterval) ?? d.shortBreakInterval
    shortBreakDuration =
      try c.decodeIfPresent(TimeInterval.self, forKey: .shortBreakDuration) ?? d.shortBreakDuration
    longBreaksEnabled =
      try c.decodeIfPresent(Bool.self, forKey: .longBreaksEnabled) ?? d.longBreaksEnabled
    longBreakInterval =
      try c.decodeIfPresent(TimeInterval.self, forKey: .longBreakInterval) ?? d.longBreakInterval
    longBreakDuration =
      try c.decodeIfPresent(TimeInterval.self, forKey: .longBreakDuration) ?? d.longBreakDuration
    headsUpLead = try c.decodeIfPresent(TimeInterval.self, forKey: .headsUpLead) ?? d.headsUpLead
    postponeDuration =
      try c.decodeIfPresent(TimeInterval.self, forKey: .postponeDuration) ?? d.postponeDuration
    disabledExerciseIDs =
      try c.decodeIfPresent(Set<String>.self, forKey: .disabledExerciseIDs) ?? d.disabledExerciseIDs
    breakKindOverrides =
      try c.decodeIfPresent([String: Set<BreakKind>].self, forKey: .breakKindOverrides)
      ?? d.breakKindOverrides
  }
}
