import Foundation

/// Chooses exercises for breaks. Short breaks rotate through the enabled pool in catalog order, so
/// the same exercise never comes twice in a row unless it is the only one enabled.
public struct ExercisePicker: Sendable {
    private let catalog: ExerciseCatalog
    private var lastShortID: String?

    public init(catalog: ExerciseCatalog) {
        self.catalog = catalog
    }

    public func pool(for kind: BreakKind, settings: Settings) -> [Exercise] {
        catalog.exercises.filter {
            !settings.disabledExerciseIDs.contains($0.id) && settings.breakKinds(for: $0).contains(kind)
        }
    }

    /// A break kind is available only if it is turned on and has at least one enabled exercise.
    public func availableKinds(settings: Settings) -> Set<BreakKind> {
        var kinds: Set<BreakKind> = []
        if !pool(for: .short, settings: settings).isEmpty { kinds.insert(.short) }
        if settings.longBreaksEnabled, !pool(for: .long, settings: settings).isEmpty {
            kinds.insert(.long)
        }
        return kinds
    }

    /// Returns nil if the kind is not available.
    public mutating func plan(for kind: BreakKind, settings: Settings) -> BreakPlan? {
        guard availableKinds(settings: settings).contains(kind) else { return nil }
        let pool = pool(for: kind, settings: settings)
        switch kind {
        case .short:
            let next =
                lastShortID.flatMap { last in pool.firstIndex { $0.id == last } }
                .map { pool[($0 + 1) % pool.count] } ?? pool[0]
            lastShortID = next.id
            return .short(next, seconds: settings.shortBreakDuration)
        case .long:
            return .long(pool: pool, seconds: settings.longBreakDuration)
        }
    }
}
