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
    func show(session: BreakSession, onSkip: @escaping @MainActor () -> Void) {
        events.append("show")
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
    await h.advance(19)
    #expect(h.fakes.events.isEmpty)
    await h.advance(1)
    #expect(h.fakes.events == ["hide", "endSound"])
    #expect(h.app.state == .working && h.app.session == nil)
}

@Test @MainActor func sessionCountsDown() async {
    let h = Harness()
    await h.advance(20 * 60)
    await h.advance(5)
    #expect(h.app.session?.remaining == 15)
    #expect(h.app.session?.stepIndex == 0)
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

@Test @MainActor func sessionStepAdvancesThroughALongBreak() async {
    let h = Harness()
    h.app.startBreakNow(.long)
    let session = h.app.session!
    #expect(session.plan.steps.count > 1)
    let first = session.plan.steps[0].seconds
    await h.advance(Int(first) + 1)
    #expect(session.stepIndex == 1)
}

@Test @MainActor func sessionExposesWhenTheCurrentStepStarted() async {
    let h = Harness()
    h.app.startBreakNow(.long)
    let session = h.app.session!
    #expect(session.stepStartedAt == session.startedAt)
    let first = session.plan.steps[0].seconds
    await h.advance(Int(first) + 1)
    #expect(session.stepStartedAt == session.startedAt.addingTimeInterval(first))
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
