import Foundation
import Testing

@testable import GazelingKit

private let t0 = Date(timeIntervalSinceReferenceDate: 0)
private func at(_ seconds: TimeInterval) -> Date { t0.addingTimeInterval(seconds) }

@MainActor
private func session(leadIn: TimeInterval, seconds: TimeInterval = 20) -> BreakSession {
    let exercise = try! ExerciseCatalog.bundled().exercises[0]
    let plan = BreakPlan.single(exercise, kind: .short, seconds: seconds)
    return BreakSession(plan: plan, startedAt: t0, leadIn: leadIn)
}

@Test @MainActor func duringTheLeadInTheCountdownIsFrozenAtTheFullLength() {
    let s = session(leadIn: 5)
    s.update(now: at(3))
    #expect(s.isLeadIn)
    #expect(s.remaining == 20)
    #expect(s.progress == 0)
    #expect(s.stepIndex == 0)
}

@Test @MainActor func theExerciseStartsAfterTheLeadIn() {
    let s = session(leadIn: 5)
    #expect(s.exerciseStartedAt == at(5))
    #expect(s.stepStartedAt == at(5))
    s.update(now: at(5))
    #expect(!s.isLeadIn)
    #expect(s.remaining == 20)
    s.update(now: at(15))
    #expect(s.remaining == 10)
    #expect(s.progress == 0.5)
}

@Test @MainActor func theBreakEndsAfterLeadInPlusLength() {
    let s = session(leadIn: 5)
    #expect(s.endsAt == at(25))
    s.update(now: at(25))
    #expect(s.remaining == 0)
}

@Test @MainActor func noLeadInBehavesAsBefore() {
    let s = session(leadIn: 0)
    s.update(now: at(0))
    #expect(!s.isLeadIn)
    #expect(s.endsAt == at(20))
    s.update(now: at(5))
    #expect(s.remaining == 15)
}

@Test @MainActor func leadInDefaultsToNone() {
    let exercise = try! ExerciseCatalog.bundled().exercises[0]
    let s = BreakSession(plan: .single(exercise, kind: .short, seconds: 20), startedAt: t0)
    #expect(s.leadIn == 0)
}
