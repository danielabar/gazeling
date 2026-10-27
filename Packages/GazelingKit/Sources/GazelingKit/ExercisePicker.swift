import Foundation

/// Chooses the exercise for each break. Exercises rotate through the enabled ones in catalog order, so
/// the same one never comes twice in a row unless it is the only one enabled.
public struct ExercisePicker: Sendable {
    private let catalog: ExerciseCatalog
    private var lastID: [BreakKind: String] = [:]

    public init(catalog: ExerciseCatalog) {
        self.catalog = catalog
    }

    public func pool(for kind: BreakKind, settings: Settings) -> [Exercise] {
        catalog.exercises.filter { $0.breakKind == kind && settings.isEnabled($0) }
    }

    /// A break kind is available only if it is turned on and has at least one enabled exercise.
    public func availableKinds(settings: Settings) -> Set<BreakKind> {
        var kinds: Set<BreakKind> = []
        if !pool(for: .short, settings: settings).isEmpty { kinds.insert(.short) }
        if settings.longBreaksEnabled, !pool(for: .long, settings: settings).isEmpty { kinds.insert(.long) }
        return kinds
    }

    /// Returns nil if the kind is not available.
    public mutating func plan(for kind: BreakKind, settings: Settings) -> BreakPlan? {
        guard availableKinds(settings: settings).contains(kind) else { return nil }
        let pool = pool(for: kind, settings: settings)
        let next =
            lastID[kind].flatMap { last in pool.firstIndex { $0.id == last } }
            .map { pool[($0 + 1) % pool.count] } ?? pool[0]
        lastID[kind] = next.id
        return .single(next, kind: kind, seconds: settings.breakDuration(for: kind))
    }
}
