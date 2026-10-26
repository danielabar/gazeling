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

/// Every field set to something other than its default.
private func fullyCustomised() -> Settings {
    var s = Settings()
    s.shortBreakInterval = 15 * 60
    s.shortBreakDuration = 30
    s.longBreaksEnabled = false
    s.longBreakInterval = 90 * 60
    s.longBreakDuration = 10 * 60
    s.headsUpLead = 45
    s.postponeDuration = 10 * 60
    s.disabledExerciseIDs = ["walk"]
    s.breakKindOverrides = ["palming": [.long]]
    s.overlayScreen = .all
    s.soundsEnabled = false
    return s
}

@Test func customisedSettingsCoverEveryField() {
    // Fails when a field is added to Settings but not to `fullyCustomised`, which would let
    // a forgotten line in `init(from:)` go unnoticed.
    let defaults = Mirror(reflecting: Settings()).children
    let custom = Mirror(reflecting: fullyCustomised()).children
    for (d, c) in zip(defaults, custom) {
        #expect("\(d.value)" != "\(c.value)", "\(d.label ?? "?") is still at its default")
    }
}

@Test func everyFieldSurvivesSavingAndLoading() throws {
    let s = fullyCustomised()
    let decoded = try JSONDecoder().decode(Settings.self, from: JSONEncoder().encode(s))
    #expect(decoded == s)
}

@Test func everyFieldSurvivesTheUserDefaultsStore() {
    let store = UserDefaultsSettingsStore(defaults: UserDefaults(suiteName: UUID().uuidString)!)
    store.save(fullyCustomised())
    #expect(store.load() == fullyCustomised())
}

@Test func newFieldsDefaultSensibly() {
    #expect(Settings().overlayScreen == .pointer)
    #expect(Settings().soundsEnabled)
}

// MARK: Limits

@Test func validatedKeepsDefaultsUnchanged() {
    #expect(Settings().validated() == Settings())
}

@Test func validatedClampsToTheRanges() {
    var s = Settings()
    s.shortBreakInterval = 5
    s.shortBreakDuration = 1
    s.postponeDuration = 99999
    let v = s.validated()
    #expect(v.shortBreakInterval == Settings.shortIntervalRange.lowerBound)
    #expect(v.shortBreakDuration == Settings.shortDurationRange.lowerBound)
    #expect(v.postponeDuration == Settings.postponeRange.upperBound)
}

@Test func validatedKeepsLongBreaksLongerThanShortOnes() {
    var s = Settings()
    s.shortBreakInterval = 30 * 60
    s.longBreakInterval = 10 * 60
    s.shortBreakDuration = 90
    s.longBreakDuration = 60
    let v = s.validated()
    #expect(v.longBreakInterval > v.shortBreakInterval)
    #expect(v.longBreakDuration >= v.shortBreakDuration)
}

@Test func validatedKeepsTheHeadsUpShorterThanTheInterval() {
    var s = Settings()
    s.shortBreakInterval = 60
    s.headsUpLead = 120
    #expect(s.validated().headsUpLead <= 30)
}

// MARK: Exercise settings

private func exercise(_ id: String, kinds: Set<BreakKind> = [.short, .long]) -> Exercise {
    Exercise(
        id: id, titleKey: "t", instructionKey: "i", durationSeconds: 20, defaultBreakKinds: kinds,
        includedInEveryLongBreak: false, animationScript: id)
}

@Test func settingTagsBackToTheDefaultRemovesTheOverride() {
    var s = Settings()
    let e = exercise("a", kinds: [.short, .long])
    s.setBreakKinds([.long], for: e)
    #expect(s.breakKindOverrides == ["a": [.long]])
    s.setBreakKinds([.short, .long], for: e)
    #expect(s.breakKindOverrides.isEmpty)
}

@Test func enablingAndDisablingAnExercise() {
    var s = Settings()
    let e = exercise("a")
    s.setEnabled(false, for: e)
    #expect(s.disabledExerciseIDs == ["a"] && !s.isEnabled(e))
    s.setEnabled(true, for: e)
    #expect(s.disabledExerciseIDs.isEmpty && s.isEnabled(e))
}

// MARK: Debug timing overrides

@Test func timingOverridesLayerOverSettingsWithoutValidation() {
    var overrides = TimingOverrides()
    overrides.shortInterval = 10
    overrides.headsUpLead = 4
    let applied = overrides.applied(to: Settings())
    #expect(applied.shortBreakInterval == 10 && applied.headsUpLead == 4)
    #expect(applied.longBreakInterval == Settings().longBreakInterval)
}

@Test func emptyOverridesChangeNothing() {
    #expect(TimingOverrides().applied(to: fullyCustomised()) == fullyCustomised())
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
