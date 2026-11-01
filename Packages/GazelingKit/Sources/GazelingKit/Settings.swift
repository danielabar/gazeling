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
    /// Which screen shows the owl and the exercise text. Every screen is dimmed either way.
    public var overlayScreen: OverlayScreen = .pointer
    public var soundsEnabled = true

    public init() {}

    // MARK: Limits

    public static let shortIntervalRange: ClosedRange<TimeInterval> = 60...7200
    public static let shortDurationRange: ClosedRange<TimeInterval> = 10...120
    public static let longIntervalRange: ClosedRange<TimeInterval> = 300...14400
    public static let longDurationRange: ClosedRange<TimeInterval> = 60...1800
    public static let headsUpRange: ClosedRange<TimeInterval> = 0...120
    public static let postponeRange: ClosedRange<TimeInterval> = 60...1800

    /// A copy with every value inside its range, long breaks longer and rarer than short ones, and the
    /// heads-up shorter than the interval. Used before saving, so the UI and the model share the limits.
    public func validated() -> Settings {
        var s = self
        s.shortBreakInterval = shortBreakInterval.clamped(to: Self.shortIntervalRange)
        s.shortBreakDuration = shortBreakDuration.clamped(to: Self.shortDurationRange)
        s.longBreakInterval = max(
            longBreakInterval.clamped(to: Self.longIntervalRange), s.shortBreakInterval + 60)
        s.longBreakDuration = max(
            longBreakDuration.clamped(to: Self.longDurationRange), s.shortBreakDuration)
        s.headsUpLead = min(headsUpLead.clamped(to: Self.headsUpRange), s.shortBreakInterval / 2)
        s.postponeDuration = postponeDuration.clamped(to: Self.postponeRange)
        return s
    }

    // MARK: Exercises

    public func isEnabled(_ exercise: Exercise) -> Bool {
        !disabledExerciseIDs.contains(exercise.id)
    }

    public mutating func setEnabled(_ enabled: Bool, for exercise: Exercise) {
        if enabled { disabledExerciseIDs.remove(exercise.id) } else { disabledExerciseIDs.insert(exercise.id) }
    }

    /// Puts the break timings and the long-breaks switch back to the defaults. Exercise choices and every
    /// other setting stay as they are.
    public mutating func restoreDefaultTimings() {
        let d = Settings()
        shortBreakInterval = d.shortBreakInterval
        shortBreakDuration = d.shortBreakDuration
        longBreaksEnabled = d.longBreaksEnabled
        longBreakInterval = d.longBreakInterval
        longBreakDuration = d.longBreakDuration
        headsUpLead = d.headsUpLead
        postponeDuration = d.postponeDuration
    }

    public var hasDefaultTimings: Bool {
        var restored = self
        restored.restoreDefaultTimings()
        return restored == self
    }

    /// The values that decide when breaks happen. Changing any of them restarts the timers.
    struct Timings: Equatable {
        var shortInterval, shortDuration, longInterval, longDuration, headsUp: TimeInterval
    }

    var timings: Timings {
        Timings(
            shortInterval: shortBreakInterval, shortDuration: shortBreakDuration, longInterval: longBreakInterval,
            longDuration: longBreakDuration, headsUp: headsUpLead)
    }

    public func breakInterval(for kind: BreakKind) -> TimeInterval {
        kind == .short ? shortBreakInterval : longBreakInterval
    }

    /// Time at the start of a break to read the instruction before the countdown begins. Short breaks only:
    /// the long break is a walk and needs no explanation.
    public func breakLeadIn(for kind: BreakKind) -> TimeInterval {
        kind == .short ? 5 : 0
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
        overlayScreen = try c.decodeIfPresent(OverlayScreen.self, forKey: .overlayScreen) ?? d.overlayScreen
        soundsEnabled = try c.decodeIfPresent(Bool.self, forKey: .soundsEnabled) ?? d.soundsEnabled
    }
}

/// Where the owl and exercise text appear. All screens are dimmed in every case.
public enum OverlayScreen: String, Codable, Sendable, CaseIterable {
    /// The screen the mouse pointer is on.
    case pointer
    case main
    case all
}

extension TimeInterval {
    fileprivate func clamped(to range: ClosedRange<TimeInterval>) -> TimeInterval {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

/// Debug-only timing changes (launch arguments). They are laid over the user's settings and never saved.
public struct TimingOverrides: Equatable, Sendable {
    public var shortInterval, shortDuration, longInterval, longDuration, headsUpLead: TimeInterval?

    public init() {}

    public func applied(to settings: Settings) -> Settings {
        var s = settings
        if let shortInterval { s.shortBreakInterval = shortInterval }
        if let shortDuration { s.shortBreakDuration = shortDuration }
        if let longInterval { s.longBreakInterval = longInterval }
        if let longDuration { s.longBreakDuration = longDuration }
        if let headsUpLead { s.headsUpLead = headsUpLead }
        return s
    }
}
