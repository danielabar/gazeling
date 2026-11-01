import Foundation
import Observation

/// A break in progress: the plan plus a countdown. Feeds the overlay.
/// The break starts with a lead-in: the instruction shows and the countdown stays at the full length, so there is
/// time to read it. The exercise and the countdown start when the lead-in ends.
@MainActor
@Observable
public final class BreakSession {
    public let plan: BreakPlan
    public let startedAt: Date
    public let leadIn: TimeInterval
    public private(set) var now: Date

    public init(plan: BreakPlan, startedAt: Date, leadIn: TimeInterval = 0) {
        self.plan = plan
        self.startedAt = startedAt
        self.leadIn = leadIn
        self.now = startedAt
    }

    /// When the exercise and the countdown begin.
    public var exerciseStartedAt: Date { startedAt.addingTimeInterval(leadIn) }
    public var isLeadIn: Bool { now < exerciseStartedAt }

    /// The length of the exercise, not counting the lead-in.
    public var totalSeconds: TimeInterval { plan.steps.map(\.seconds).reduce(0, +) }
    public var endsAt: Date { exerciseStartedAt.addingTimeInterval(totalSeconds) }
    public var remaining: TimeInterval { max(0, endsAt.timeIntervalSince(max(now, exerciseStartedAt))) }
    public var progress: Double { totalSeconds > 0 ? 1 - remaining / totalSeconds : 1 }

    /// Index of the step in progress. The last step holds until the break ends.
    public var stepIndex: Int {
        let elapsed = now.timeIntervalSince(exerciseStartedAt)
        var end: TimeInterval = 0
        for (index, step) in plan.steps.enumerated() {
            end += step.seconds
            if elapsed < end { return index }
        }
        return plan.steps.count - 1
    }

    public var step: BreakPlan.Step { plan.steps[stepIndex] }

    /// When the step in progress began.
    public var stepStartedAt: Date {
        exerciseStartedAt.addingTimeInterval(plan.steps[..<stepIndex].map(\.seconds).reduce(0, +))
    }

    public func update(now: Date) {
        self.now = now
    }
}
