import Foundation

/// The exercises for one break, in order. Step durations always add up to the break duration.
public struct BreakPlan: Equatable, Sendable {
  public struct Step: Equatable, Sendable {
    public let exercise: Exercise
    public let seconds: TimeInterval
  }

  public let kind: BreakKind
  public let steps: [Step]

  /// A short break is one exercise stretched to the break duration.
  static func short(_ exercise: Exercise, seconds: TimeInterval) -> BreakPlan {
    BreakPlan(kind: .short, steps: [Step(exercise: exercise, seconds: seconds)])
  }

  /// Cycles through `pool` (must be non-empty) until the time is used up. Exercises that do not
  /// fit are dropped, and the leftover seconds are added to the last step so the total is exact.
  static func long(pool: [Exercise], seconds total: TimeInterval) -> BreakPlan {
    // Required exercises first, so a short long-break still includes them.
    let ordered =
      pool.filter(\.includedInEveryLongBreak) + pool.filter { !$0.includedInEveryLongBreak }
    var steps: [Step] = []
    var remaining = total
    var index = 0
    while ordered.count > 1 {
      let exercise = ordered[index % ordered.count]
      guard exercise.durationSeconds > 0, exercise.durationSeconds <= remaining else { break }
      steps.append(Step(exercise: exercise, seconds: exercise.durationSeconds))
      remaining -= exercise.durationSeconds
      index += 1
    }
    guard let last = steps.last else {
      return BreakPlan(kind: .long, steps: [Step(exercise: ordered[0], seconds: total)])
    }
    steps[steps.count - 1] = Step(exercise: last.exercise, seconds: last.seconds + remaining)
    return BreakPlan(kind: .long, steps: steps)
  }
}
