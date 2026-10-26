import Foundation
import Testing

@testable import GazelingKit

@Test func defaultsMatchResearchDoc() {
    let s = Settings()
    #expect(s.shortBreakInterval == 20 * 60 && s.shortBreakDuration == 20)
    #expect(s.longBreakInterval == 60 * 60 && s.longBreakDuration == 5 * 60)
    #expect(s.longBreaksEnabled)
    #expect(s.headsUpLead == 30)
    #expect(s.postponeDuration == 5 * 60)
}

@Test func emptyJSONDecodesToDefaults() throws {
    #expect(try JSONDecoder().decode(Settings.self, from: Data("{}".utf8)) == Settings())
}

@Test func partialJSONKeepsSavedValuesAndDefaultsTheRest() throws {
    let s = try JSONDecoder().decode(Settings.self, from: Data(#"{"shortBreakInterval":600}"#.utf8))
    #expect(s.shortBreakInterval == 600)
    #expect(s.longBreakInterval == Settings().longBreakInterval)
}

@Test func settingsRoundTrip() throws {
    var s = Settings()
    s.disabledExerciseIDs = ["walk"]
    s.breakKindOverrides = ["palming": [.long]]
    let decoded = try JSONDecoder().decode(Settings.self, from: JSONEncoder().encode(s))
    #expect(decoded == s)
}

@Test func userDefaultsStoreSavesAndLoads() {
    let defaults = UserDefaults(suiteName: UUID().uuidString)!
    let store = UserDefaultsSettingsStore(defaults: defaults)
    #expect(store.load() == Settings())
    var s = Settings()
    s.shortBreakInterval = 123
    store.save(s)
    #expect(store.load() == s)
}

@Test func userDefaultsStoreFallsBackOnGarbage() {
    let defaults = UserDefaults(suiteName: UUID().uuidString)!
    defaults.set(Data("not json".utf8), forKey: "settings")
    #expect(UserDefaultsSettingsStore(defaults: defaults).load() == Settings())
}

@Test func inMemoryStoreSavesAndLoads() {
    let store = InMemorySettingsStore()
    var s = Settings()
    s.longBreaksEnabled = false
    store.save(s)
    #expect(store.load() == s)
}
