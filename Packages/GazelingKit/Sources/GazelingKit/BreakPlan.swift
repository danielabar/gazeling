import Foundation

/// The exercise for one break, stretched to the break's duration.
public struct BreakPlan: Equatable, Sendable {
    public struct Step: Equatable, Sendable {
        public let exercise: Exercise
        public let seconds: TimeInterval
    }

    public let kind: BreakKind
    public let steps: [Step]

    static func single(_ exercise: Exercise, kind: BreakKind, seconds: TimeInterval) -> BreakPlan {
        BreakPlan(kind: kind, steps: [Step(exercise: exercise, seconds: seconds)])
    }
}
