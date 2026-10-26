import Testing

@testable import GazelingKit

private func exercise(
  _ id: String, seconds: Double = 20, kinds: Set<BreakKind> = [.short, .long],
  required: Bool = false
) -> Exercise {
  Exercise(
    id: id, titleKey: "t.\(id)", instructionKey: "i.\(id)", durationSeconds: seconds,
    defaultBreakKinds: kinds, includedInEveryLongBreak: required, animationScript: id)
}

private func picker(_ exercises: [Exercise]) -> ExercisePicker {
  ExercisePicker(catalog: ExerciseCatalog(exercises: exercises))
}

@Test func shortBreaksRotateWithoutImmediateRepeats() {
  var p = picker([exercise("a"), exercise("b"), exercise("c")])
  let ids = (0..<7).map { _ in p.plan(for: .short, settings: Settings())!.steps[0].exercise.id }
  #expect(ids == ["a", "b", "c", "a", "b", "c", "a"])
}

@Test func shortBreakIsOneStepOfTheBreakDuration() {
  var p = picker([exercise("a")])
  let plan = p.plan(for: .short, settings: Settings())!
  #expect(plan.steps.map(\.seconds) == [20])
}

@Test func singleEnabledExerciseMayRepeat() {
  var p = picker([exercise("a")])
  #expect(p.plan(for: .short, settings: Settings())!.steps[0].exercise.id == "a")
  #expect(p.plan(for: .short, settings: Settings())!.steps[0].exercise.id == "a")
}

@Test func disabledExercisesAreSkippedAndRotationContinues() {
  var p = picker([exercise("a"), exercise("b"), exercise("c")])
  var s = Settings()
  #expect(p.plan(for: .short, settings: s)!.steps[0].exercise.id == "a")
  s.disabledExerciseIDs = ["b"]
  #expect(p.plan(for: .short, settings: s)!.steps[0].exercise.id == "c")
}

@Test func kindOverridesChangeThePool() {
  let p = picker([exercise("a", kinds: [.long]), exercise("b")])
  var s = Settings()
  #expect(p.pool(for: .short, settings: s).map(\.id) == ["b"])
  s.breakKindOverrides = ["a": [.short, .long]]
  #expect(p.pool(for: .short, settings: s).map(\.id) == ["a", "b"])
}

@Test func emptyPoolTurnsThatBreakKindOff() {
  var p = picker([exercise("a", kinds: [.short]), exercise("b")])
  var s = Settings()
  s.disabledExerciseIDs = ["b"]
  #expect(p.availableKinds(settings: s) == [.short])
  #expect(p.plan(for: .long, settings: s) == nil)
  s.disabledExerciseIDs = ["a", "b"]
  #expect(p.availableKinds(settings: s).isEmpty)
  #expect(p.plan(for: .short, settings: s) == nil)
}

@Test func longBreaksCanBeSwitchedOff() {
  let p = picker([exercise("a")])
  var s = Settings()
  s.longBreaksEnabled = false
  #expect(p.availableKinds(settings: s) == [.short])
}

@Test func longPlanSumsExactlyToBreakDuration() {
  var p = picker([exercise("a"), exercise("b", seconds: 30), exercise("c", seconds: 45)])
  for total in [60.0, 95, 300, 301, 17] {
    var s = Settings()
    s.longBreakDuration = total
    let plan = p.plan(for: .long, settings: s)!
    #expect(plan.steps.map(\.seconds).reduce(0, +) == total)
  }
}

@Test func longPlanHasNoAdjacentRepeatsAndCyclesThePool() {
  var p = picker([exercise("a"), exercise("b"), exercise("c")])
  let plan = p.plan(for: .long, settings: Settings())!
  let ids = plan.steps.map(\.exercise.id)
  #expect(ids.count > 3)
  for (x, y) in zip(ids, ids.dropFirst()) { #expect(x != y) }
}

@Test func longPlanStartsWithRequiredExercisesEvenWhenShort() {
  var p = picker([exercise("a"), exercise("walk", seconds: 60, required: true), exercise("b")])
  var s = Settings()
  s.longBreakDuration = 60
  #expect(p.plan(for: .long, settings: s)!.steps.map(\.exercise.id) == ["walk"])
}

@Test func longPlanWithOneExerciseIsOneFullStep() {
  var p = picker([exercise("a")])
  let plan = p.plan(for: .long, settings: Settings())!
  #expect(plan.steps.count == 1 && plan.steps[0].seconds == 300)
}

@Test func shippedCatalogLongPlanIncludesBlinkLookFarAndWalk() throws {
  var p = ExercisePicker(catalog: try ExerciseCatalog.bundled())
  let ids = Set(p.plan(for: .long, settings: Settings())!.steps.map(\.exercise.id))
  #expect(ids.isSuperset(of: ["blink", "look-far", "walk"]))
}
