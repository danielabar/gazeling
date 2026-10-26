import Foundation

public struct ExerciseCatalog: Sendable {
  public let exercises: [Exercise]

  public init(exercises: [Exercise]) {
    self.exercises = exercises
  }

  public init(data: Data) throws {
    self.exercises = try JSONDecoder().decode([Exercise].self, from: data)
  }

  /// The `exercises.json` that ships with the package.
  public static func bundled() throws -> ExerciseCatalog {
    let url = Bundle.module.url(forResource: "exercises", withExtension: "json")!
    return try ExerciseCatalog(data: Data(contentsOf: url))
  }
}
