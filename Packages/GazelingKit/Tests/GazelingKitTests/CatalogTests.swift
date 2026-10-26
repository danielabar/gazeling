import Foundation
import Testing

@testable import GazelingKit

@Test func bundledCatalogHasTheAgreedExercises() throws {
  let catalog = try ExerciseCatalog.bundled()
  #expect(
    catalog.exercises.map(\.id) == [
      "blink", "look-far", "side-to-side", "up-down", "circle-left", "circle-right", "palming",
      "walk",
      "eyes-closed-rest",
    ])
}

@Test func bundledCatalogIdsAreUniqueAndFieldsFilled() throws {
  let exercises = try ExerciseCatalog.bundled().exercises
  #expect(Set(exercises.map(\.id)).count == exercises.count)
  for e in exercises {
    #expect(!e.titleKey.isEmpty && !e.instructionKey.isEmpty && !e.animationScript.isEmpty)
    #expect(e.durationSeconds > 0)
    #expect(!e.defaultBreakKinds.isEmpty)
  }
}

@Test func catalogDecodesFromData() throws {
  let json = """
    [{"id":"x","titleKey":"t","instructionKey":"i","durationSeconds":5,
      "defaultBreakKinds":["short"],"includedInEveryLongBreak":false,"animationScript":"x"}]
    """
  let catalog = try ExerciseCatalog(data: Data(json.utf8))
  #expect(catalog.exercises.first?.defaultBreakKinds == [.short])
}
