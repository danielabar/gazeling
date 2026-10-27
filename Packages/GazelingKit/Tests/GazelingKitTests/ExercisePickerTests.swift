import Testing

@testable import GazelingKit

private func exercise(_ id: String, kind: BreakKind = .short) -> Exercise {
    Exercise(
        id: id, titleKey: "t.\(id)", instructionKey: "i.\(id)", durationSeconds: 20, breakKind: kind,
        animationScript: id)
}

private func picker(_ exercises: [Exercise]) -> ExercisePicker {
    ExercisePicker(catalog: ExerciseCatalog(exercises: exercises))
}

private func firstID(_ plan: BreakPlan?) -> String? { plan?.steps.first?.exercise.id }

@Test func shortBreaksRotateWithoutImmediateRepeats() {
    var p = picker([exercise("a"), exercise("b"), exercise("c")])
    let ids = (0..<7).map { _ in firstID(p.plan(for: .short, settings: Settings())) }
    #expect(ids == ["a", "b", "c", "a", "b", "c", "a"])
}

@Test func aBreakIsOneStepOfTheBreakDuration() {
    var p = picker([exercise("a"), exercise("walk", kind: .long)])
    #expect(p.plan(for: .short, settings: Settings())!.steps.map(\.seconds) == [20])
    #expect(p.plan(for: .long, settings: Settings())!.steps.map(\.seconds) == [300])
}

@Test func eachKindOnlyUsesItsOwnExercises() {
    var p = picker([exercise("a"), exercise("walk", kind: .long), exercise("b")])
    #expect(p.pool(for: .short, settings: Settings()).map(\.id) == ["a", "b"])
    #expect(firstID(p.plan(for: .long, settings: Settings())) == "walk")
    #expect(firstID(p.plan(for: .short, settings: Settings())) == "a")
}

@Test func singleEnabledExerciseMayRepeat() {
    var p = picker([exercise("a")])
    #expect(firstID(p.plan(for: .short, settings: Settings())) == "a")
    #expect(firstID(p.plan(for: .short, settings: Settings())) == "a")
}

@Test func disabledExercisesAreSkippedAndRotationContinues() {
    var p = picker([exercise("a"), exercise("b"), exercise("c")])
    var s = Settings()
    #expect(firstID(p.plan(for: .short, settings: s)) == "a")
    s.disabledExerciseIDs = ["b"]
    #expect(firstID(p.plan(for: .short, settings: s)) == "c")
}

@Test func emptyPoolTurnsThatBreakKindOff() {
    var p = picker([exercise("a"), exercise("walk", kind: .long)])
    var s = Settings()
    s.disabledExerciseIDs = ["walk"]
    #expect(p.availableKinds(settings: s) == [.short])
    #expect(p.plan(for: .long, settings: s) == nil)
    s.disabledExerciseIDs = ["a", "walk"]
    #expect(p.availableKinds(settings: s).isEmpty)
    #expect(p.plan(for: .short, settings: s) == nil)
}

@Test func longBreaksCanBeSwitchedOff() {
    let p = picker([exercise("a"), exercise("walk", kind: .long)])
    var s = Settings()
    s.longBreaksEnabled = false
    #expect(p.availableKinds(settings: s) == [.short])
}

@Test func shippedCatalogLongBreakIsJustWalking() throws {
    var p = ExercisePicker(catalog: try ExerciseCatalog.bundled())
    let plan = p.plan(for: .long, settings: Settings())!
    #expect(plan.steps.map(\.exercise.id) == ["walk"])
    #expect(plan.steps[0].seconds == 300)
}

@Test func shippedCatalogShortBreaksRotateThroughAllEightEyeExercises() throws {
    var p = ExercisePicker(catalog: try ExerciseCatalog.bundled())
    let ids = (0..<8).compactMap { _ in firstID(p.plan(for: .short, settings: Settings())) }
    #expect(Set(ids).count == 8 && !ids.contains("walk"))
}
