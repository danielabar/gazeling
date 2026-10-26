import Foundation
import Observation

/// A break in progress: the plan plus a countdown. Feeds the overlay.
@MainActor
@Observable
public final class BreakSession {
    public let plan: BreakPlan
    public let startedAt: Date
    public private(set) var now: Date

    public init(plan: BreakPlan, startedAt: Date) {
        self.plan = plan
        self.startedAt = startedAt
        self.now = startedAt
    }

    public var totalSeconds: TimeInterval { plan.steps.map(\.seconds).reduce(0, +) }
    public var endsAt: Date { startedAt.addingTimeInterval(totalSeconds) }
    public var remaining: TimeInterval { max(0, endsAt.timeIntervalSince(now)) }
    public var progress: Double { totalSeconds > 0 ? 1 - remaining / totalSeconds : 1 }

    /// Index of the step in progress. The last step holds until the break ends.
    public var stepIndex: Int {
        let elapsed = now.timeIntervalSince(startedAt)
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
        startedAt.addingTimeInterval(plan.steps[..<stepIndex].map(\.seconds).reduce(0, +))
    }

    public func update(now: Date) {
        self.now = now
    }
}
