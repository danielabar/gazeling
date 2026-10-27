import Foundation
import Observation

/// Connects the scheduler to the platform: ticks it, and turns state changes into the heads-up
/// notification, the overlay and the sounds. Views read `state` and `session`.
@MainActor
@Observable
public final class AppState {
    public private(set) var state: BreakState = .working
    public private(set) var session: BreakSession?
    public private(set) var settings: Settings

    @ObservationIgnored private var scheduler: BreakScheduler
    @ObservationIgnored private var picker: ExercisePicker
    @ObservationIgnored private let store: SettingsStore
    @ObservationIgnored private let idleMonitor: IdleMonitor
    @ObservationIgnored private let notifier: Notifier
    @ObservationIgnored private let overlay: OverlayPresenter
    @ObservationIgnored private let sound: SoundPlayer
    @ObservationIgnored private let clock: () -> Date
    @ObservationIgnored private var tickTask: Task<Void, Never>?
    @ObservationIgnored private var forcedPlan: BreakPlan?
    @ObservationIgnored private let overrides: TimingOverrides

    /// The stored settings with any debug timing overrides on top. This is what the scheduler uses.
    /// `settings` is what the settings window shows and saves, so overrides never reach the store.
    private var effectiveSettings: Settings { overrides.applied(to: settings) }
    /// Every exercise in the catalog, for the debug menu.
    public let exercises: [Exercise]

    /// `overrides` change the timings without being saved (debug launch arguments).
    public init(
        catalog: ExerciseCatalog, store: SettingsStore, overrides: TimingOverrides = TimingOverrides(),
        idleMonitor: IdleMonitor, notifier: Notifier, overlay: OverlayPresenter, sound: SoundPlayer,
        clock: @escaping () -> Date = Date.init
    ) {
        let settings = store.load().validated()
        let effective = overrides.applied(to: settings)
        let picker = ExercisePicker(catalog: catalog)
        self.settings = settings
        self.overrides = overrides
        self.picker = picker
        self.store = store
        self.idleMonitor = idleMonitor
        self.notifier = notifier
        self.overlay = overlay
        self.sound = sound
        self.clock = clock
        self.exercises = catalog.exercises
        self.scheduler = BreakScheduler(
            settings: effective, availableKinds: picker.availableKinds(settings: effective), now: clock())
    }

    /// Asks for notification permission and starts polling once a second.
    public func start() {
        guard tickTask == nil else { return }
        Task { await notifier.requestAuthorization() }
        tickTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                self?.tick()
            }
        }
    }

    public func tick() {
        perform { $0.update(now: clock(), idleSeconds: idleMonitor.idleSeconds()) }
    }

    // MARK: Actions

    /// Skips the break in progress. Used by the overlay's Skip button and Esc.
    public func skipCurrentBreak() {
        guard case .onBreak = state else { return }
        skip()
    }

    /// Skips the break in progress, the heads-up break, or otherwise the next one.
    public func skip() {
        perform { $0.skip(now: clock()) }
    }

    public func postpone() {
        perform { $0.postpone(now: clock()) }
    }

    public func pause(for duration: TimeInterval?) {
        perform { $0.pause(until: duration.map { clock().addingTimeInterval($0) }) }
    }

    public func resume() {
        perform { $0.resume(now: clock()) }
    }

    /// Debug: start a break now.
    public func startBreakNow(_ kind: BreakKind) {
        perform { $0.startBreak(kind, now: clock()) }
    }

    /// Debug: play one exercise now, ignoring the schedule. Lasts `seconds`, or the exercise's own length.
    public func playNow(exercise: Exercise, seconds: TimeInterval? = nil) {
        let length = seconds ?? exercise.durationSeconds
        forcedPlan = .single(exercise, kind: exercise.breakKind, seconds: length)
        perform { $0.startBreak(exercise.breakKind, now: clock(), duration: length) }
        forcedPlan = nil
    }

    public func restoreDefaultTimings() {
        var s = settings
        s.restoreDefaultTimings()
        apply(settings: s)
    }

    /// Validates, saves and applies new settings.
    public func apply(settings newSettings: Settings) {
        settings = newSettings.validated()
        store.save(settings)
        let effective = effectiveSettings
        perform {
            $0.apply(
                settings: effective, availableKinds: picker.availableKinds(settings: effective), now: clock())
        }
    }

    /// Break kinds that will actually happen: turned on, with at least one enabled exercise.
    public var availableBreakKinds: Set<BreakKind> {
        picker.availableKinds(settings: settings)
    }

    /// False if switching this exercise off would leave no break that could happen. The settings window
    /// uses this to keep the last break switched on (to stop breaks for a while, the user pauses).
    public func canSwitchOff(_ exercise: Exercise) -> Bool {
        var s = settings
        s.setEnabled(false, for: exercise)
        return !picker.availableKinds(settings: s).isEmpty
    }

    /// False if the long break is the only break left, so it cannot be switched off.
    public var canTurnOffLongBreaks: Bool {
        var s = settings
        s.longBreaksEnabled = false
        return !picker.availableKinds(settings: s).isEmpty
    }

    /// When the next break is due, or nil if none is (all exercises off, or paused).
    public var nextBreakDate: Date? {
        if case .paused = state { return nil }
        return scheduler.nextBreak()?.due
    }

    // MARK: State changes

    private func perform(_ change: (inout BreakScheduler) -> Void) {
        let previous = scheduler.state
        change(&scheduler)
        transition(from: previous, to: scheduler.state)
    }

    private func transition(from previous: BreakState, to current: BreakState) {
        state = current
        let now = clock()

        if case .headsUp(let kind, let startsAt) = current {
            if case .headsUp = previous {
            } else {
                let seconds = startsAt.timeIntervalSince(now)
                Task { await notifier.postHeadsUp(kind: kind, seconds: seconds) }
            }
        } else if case .headsUp = previous {
            notifier.removeHeadsUp()
        }

        if case .onBreak(let kind, _) = current {
            if case .onBreak = previous {
                session?.update(now: now)
            } else {
                startSession(kind: kind, now: now)
            }
        } else if case .onBreak(_, let endsAt) = previous {
            endSession(finished: now >= endsAt)
        }
    }

    private func startSession(kind: BreakKind, now: Date) {
        guard let plan = forcedPlan ?? picker.plan(for: kind, settings: effectiveSettings) else {
            perform { $0.skip(now: now) }
            return
        }
        let session = BreakSession(plan: plan, startedAt: now)
        self.session = session
        overlay.show(
            session: session, contentScreens: settings.overlayScreen,
            onSkip: { [weak self] in self?.skipCurrentBreak() })
        if settings.soundsEnabled { sound.playBreakStart() }
    }

    private func endSession(finished: Bool) {
        overlay.hide()
        session = nil
        if finished && settings.soundsEnabled { sound.playBreakEnd() }
    }
}
