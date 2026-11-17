import Foundation
import Testing

@testable import GazelingKit

@Test func everyExerciseHasAnEnglishVoiceClip() throws {
    for exercise in try ExerciseCatalog.bundled().exercises {
        let url = try #require(BundledAudio.voiceClip(for: exercise.id), "no clip for \(exercise.id)")
        let size = try FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int ?? 0
        #expect(size > 1000, "clip for \(exercise.id) looks empty")
    }
}

@Test func theChimesAreBundled() {
    #expect(BundledAudio.breakStart != nil)
    #expect(BundledAudio.breakEnd != nil)
}

@Test func anUnknownExerciseHasNoClip() {
    #expect(BundledAudio.voiceClip(for: "no-such-exercise") == nil)
}

@Test func aMissingLanguageFallsBackToEnglish() throws {
    let english = try #require(BundledAudio.voiceClip(for: "blink", language: "en"))
    #expect(BundledAudio.voiceClip(for: "blink", language: "xx") == english)
}
