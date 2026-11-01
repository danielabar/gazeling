import Foundation
import Testing

@testable import GazelingKit

@MainActor
private final class Fakes: IdleMonitor, Notifier, OverlayPresenter, SoundPlayer {
    var idle: TimeInterval = 0
    var events: [String] = []
    var shownSession: BreakSession?
    var onSkip: (@MainActor () -> Void)?

    func idleSeconds() -> TimeInterval { idle }
    func requestAuthorization() async { events.append("authorize") }
    func postHeadsUp(kind: BreakKind, seconds: TimeInterval) async {
        events.append("headsUp:\(kind):\(Int(seconds))")
    }
    func removeHeadsUp() { events.append("removeHeadsUp") }
    var shownOn: OverlayScreen?
    func show(session: BreakSession, contentScreens: OverlayScreen, onSkip: @escaping @MainActor () -> Void) {
        events.append("show")
        shownOn = contentScreens
        shownSession = session
        self.onSkip = onSkip
    }
    func hide() { events.append("hide") }
    func playBreakStart() { events.append("startSound") }
    func playBreakEnd() { events.append("endSound") }
}

@MainActor
private final class Harness {
    let fakes = Fakes()
    var now = Date(timeIntervalSinceReferenceDate: 0)
    var app: AppState!

    init(settings: Settings = Settings()) {
        let catalog = try! ExerciseCatalog.bundled()
        app = AppState(
            catalog: catalog, store: InMemorySettingsStore(settings), idleMonitor: fakes, notifier: fakes,
            overlay: fakes, sound: fakes, clock: { [unowned self] in self.now })
    }

    /// Advances time in 1 s ticks like the app does. Lets notifier tasks run.
    func advance(_ seconds: Int) async {
        for _ in 0..<seconds {
            now = now.addingTimeInterval(1)
            app.tick()
        }
        await Task.yield()
    }
}

@Test @MainActor func headsUpPostsOneNotificationThenBreakShowsOverlayAndSound() async {
    let h = Harness()
    await h.advance(20 * 60 - 31)
    #expect(h.fakes.events.isEmpty)
    await h.advance(1)
    #expect(h.fakes.events == ["headsUp:short:30"])
    await h.advance(29)
    #expect(h.fakes.events == ["headsUp:short:30"])
    await h.advance(1)
    #expect(h.fakes.events == ["headsUp:short:30", "removeHeadsUp", "show", "startSound"])
    #expect(h.app.session?.plan.kind == .short)
}

@Test @MainActor func finishedBreakHidesOverlayAndPlaysEndSound() async {
    let h = Harness()
    await h.advance(20 * 60)
    h.fakes.events = []
    await h.advance(24)
    #expect(h.fakes.events.isEmpty)
    await h.advance(1)
    #expect(h.fakes.events == ["hide", "endSound"])
    #expect(h.app.state == .working && h.app.session == nil)
}

@Test @MainActor func sessionCountsDown() async {
    let h = Harness()
    await h.advance(20 * 60)
    await h.advance(5 + 5)
    #expect(h.app.session?.remaining == 15)
    #expect(h.app.session?.stepIndex == 0)
}

@Test @MainActor func shortBreakSessionHasALeadInAndLongDoesNot() async {
    let h = Harness()
    await h.advance(20 * 60)
    #expect(h.app.session?.leadIn == 5)
    #expect(h.app.session?.remaining == 20)
    h.app.skipCurrentBreak()
    h.app.startBreakNow(.long)
    #expect(h.app.session?.leadIn == 0)
}

@Test @MainActor func playingAnExerciseForAGivenLengthHasNoLeadIn() async {
    let h = Harness()
    let exercise = try! ExerciseCatalog.bundled().exercises[0]
    h.app.playNow(exercise: exercise, seconds: 4)
    #expect(h.app.session?.leadIn == 0)
    #expect(h.app.session?.endsAt == h.now.addingTimeInterval(4))
}

@Test @MainActor func skippingTheBreakHidesOverlayWithoutEndSound() async {
    let h = Harness()
    await h.advance(20 * 60)
    h.fakes.events = []
    h.fakes.onSkip?()
    #expect(h.fakes.events == ["hide"])
    #expect(h.app.state == .working)
}

@Test @MainActor func skipCurrentBreakDoesNothingWhenNotOnBreak() async {
    let h = Harness()
    let due = h.app.nextBreakDate
    h.app.skipCurrentBreak()
    #expect(h.app.nextBreakDate == due)
}

@Test @MainActor func postponeRemovesTheHeadsUpAndDelaysTheBreak() async {
    let h = Harness()
    await h.advance(20 * 60 - 30)
    h.fakes.events = []
    h.app.postpone()
    #expect(h.fakes.events == ["removeHeadsUp"])
    #expect(h.app.state == .working)
    #expect(h.app.nextBreakDate == h.now.addingTimeInterval(5 * 60))
}

@Test @MainActor func pauseStopsBreaksAndResumeRestartsTimers() async {
    let h = Harness()
    h.app.pause(for: nil)
    await h.advance(3 * 3600)
    #expect(h.fakes.events.isEmpty)
    #expect(h.app.nextBreakDate == nil)
    h.app.resume()
    #expect(h.app.state == .working)
    #expect(h.app.nextBreakDate == h.now.addingTimeInterval(20 * 60))
}

@Test @MainActor func startBreakNowShowsTheOverlay() async {
    let h = Harness()
    h.app.startBreakNow(.long)
    #expect(h.fakes.events == ["show", "startSound"])
    #expect(h.app.session?.plan.kind == .long)
}

@Test @MainActor func disablingAllExercisesStopsBreaks() async {
    let h = Harness()
    var s = Settings()
    s.disabledExerciseIDs = Set(try! ExerciseCatalog.bundled().exercises.map(\.id))
    h.app.apply(settings: s)
    await h.advance(3 * 3600)
    #expect(h.fakes.events.isEmpty)
    #expect(h.app.nextBreakDate == nil)
}

@Test @MainActor func appliedSettingsAreSaved() {
    let store = InMemorySettingsStore()
    let fakes = Fakes()
    let app = AppState(
        catalog: try! ExerciseCatalog.bundled(), store: store, idleMonitor: fakes, notifier: fakes,
        overlay: fakes, sound: fakes)
    var s = Settings()
    s.shortBreakInterval = 99
    app.apply(settings: s)
    #expect(store.load() == s)
}

@Test @MainActor func aLongBreakIsOneWalkForTheFullBreak() {
    let h = Harness()
    h.app.startBreakNow(.long)
    let session = h.app.session!
    #expect(session.plan.steps.map(\.exercise.id) == ["walk"])
    #expect(session.totalSeconds == 300)
    #expect(session.stepStartedAt == session.startedAt)
}

@Test @MainActor func playNowShowsThatExerciseForItsOwnLength() async throws {
    let h = Harness()
    let palming = try #require(h.app.exercises.first { $0.id == "palming" })
    h.app.playNow(exercise: palming)
    #expect(h.fakes.events == ["show", "startSound"])
    #expect(h.app.session?.plan.steps.map(\.exercise.id) == ["palming"])
    #expect(h.app.session?.totalSeconds == 30)
    await h.advance(29)
    #expect(h.app.state != .working)
    await h.advance(1)
    #expect(h.app.state == .working)
}

@Test @MainActor func playNowCanBeShortened() async throws {
    let h = Harness()
    h.app.playNow(exercise: h.app.exercises[0], seconds: 4)
    #expect(h.app.session?.totalSeconds == 4)
}

@Test @MainActor func debugTimingOverridesAreNeverSaved() {
    let store = InMemorySettingsStore()
    let fakes = Fakes()
    var overrides = TimingOverrides()
    overrides.shortInterval = 10
    overrides.longInterval = 30
    let app = AppState(
        catalog: try! ExerciseCatalog.bundled(), store: store, overrides: overrides, idleMonitor: fakes,
        notifier: fakes, overlay: fakes, sound: fakes)
    #expect(app.settings.shortBreakInterval == Settings().shortBreakInterval)
    var edited = app.settings
    edited.soundsEnabled = false
    app.apply(settings: edited)
    #expect(store.load().shortBreakInterval == Settings().shortBreakInterval)
    #expect(store.load().longBreakInterval == Settings().longBreakInterval)
    #expect(!store.load().soundsEnabled)
}

@Test @MainActor func debugOverridesStillDriveTheScheduler() async {
    let fakes = Fakes()
    var overrides = TimingOverrides()
    overrides.shortInterval = 10
    overrides.headsUpLead = 3
    var now = Date(timeIntervalSinceReferenceDate: 0)
    let app = AppState(
        catalog: try! ExerciseCatalog.bundled(), store: InMemorySettingsStore(), overrides: overrides,
        idleMonitor: fakes, notifier: fakes, overlay: fakes, sound: fakes, clock: { now })
    for _ in 0..<7 {
        now = now.addingTimeInterval(1)
        app.tick()
    }
    await Task.yield()
    #expect(fakes.events == ["headsUp:short:3"])
}

@Test @MainActor func soundsOffMeansNoChimes() async {
    let h = Harness()
    var s = h.app.settings
    s.soundsEnabled = false
    h.app.apply(settings: s)
    await h.advance(20 * 60)
    await h.advance(20)
    #expect(!h.fakes.events.contains("startSound") && !h.fakes.events.contains("endSound"))
    #expect(h.fakes.events.contains("show"))
}

@Test @MainActor func settingsAreValidatedBeforeTheyAreSaved() {
    let store = InMemorySettingsStore()
    let fakes = Fakes()
    let app = AppState(
        catalog: try! ExerciseCatalog.bundled(), store: store, idleMonitor: fakes, notifier: fakes,
        overlay: fakes, sound: fakes)
    var s = Settings()
    s.shortBreakInterval = 1
    app.apply(settings: s)
    #expect(store.load().shortBreakInterval == Settings.shortIntervalRange.lowerBound)
    #expect(app.settings.shortBreakInterval == Settings.shortIntervalRange.lowerBound)
}

@Test @MainActor func anyExerciseCanBeSwitchedOffWhileOthersRemain() throws {
    let h = Harness()
    for exercise in h.app.exercises { #expect(h.app.canSwitchOff(exercise)) }
    #expect(h.app.canTurnOffLongBreaks)
}

@Test @MainActor func theLastBreakCannotBeSwitchedOff() throws {
    let h = Harness()
    var s = h.app.settings
    for exercise in h.app.exercises where exercise.breakKind == .short { s.setEnabled(false, for: exercise) }
    h.app.apply(settings: s)
    let walk = try #require(h.app.exercises.first { $0.id == "walk" })
    #expect(!h.app.canSwitchOff(walk))
    #expect(!h.app.canTurnOffLongBreaks)
}

@Test @MainActor func theLastShortExerciseCannotBeSwitchedOffWhenLongBreaksAreOff() throws {
    let h = Harness()
    var s = h.app.settings
    s.longBreaksEnabled = false
    for exercise in h.app.exercises where exercise.breakKind == .short && exercise.id != "blink" {
        s.setEnabled(false, for: exercise)
    }
    h.app.apply(settings: s)
    let blink = try #require(h.app.exercises.first { $0.id == "blink" })
    #expect(!h.app.canSwitchOff(blink))
}

@Test @MainActor func postponeUsesTheConfiguredLength() async {
    let h = Harness()
    var s = h.app.settings
    s.postponeDuration = 10 * 60
    h.app.apply(settings: s)
    await h.advance(20 * 60 - 30)
    h.app.postpone()
    #expect(h.app.nextBreakDate == h.now.addingTimeInterval(10 * 60))
}

@Test @MainActor func restoringDefaultTimingsSavesThemAndRestartsTheCountdown() async {
    let h = Harness()
    var s = h.app.settings
    s.shortBreakInterval = 5 * 60
    s.disabledExerciseIDs = ["palming"]
    h.app.apply(settings: s)
    await h.advance(60)
    h.app.restoreDefaultTimings()
    #expect(h.app.settings.shortBreakInterval == Settings().shortBreakInterval)
    #expect(h.app.settings.disabledExerciseIDs == ["palming"])
    #expect(h.app.nextBreakDate == h.now.addingTimeInterval(20 * 60))
}

@Test @MainActor func theOverlayIsShownOnTheChosenScreens() {
    let h = Harness()
    h.app.startBreakNow(.short)
    #expect(h.fakes.shownOn == .pointer)
    h.app.skipCurrentBreak()
    var s = h.app.settings
    s.overlayScreen = .all
    h.app.apply(settings: s)
    h.app.startBreakNow(.short)
    #expect(h.fakes.shownOn == .all)
}
