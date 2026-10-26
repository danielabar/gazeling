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

  /// `settings` overrides the stored settings without saving them (debug launch arguments).
  public init(
    catalog: ExerciseCatalog, store: SettingsStore, settings: Settings? = nil,
    idleMonitor: IdleMonitor, notifier: Notifier, overlay: OverlayPresenter, sound: SoundPlayer,
    clock: @escaping () -> Date = Date.init
  ) {
    let settings = settings ?? store.load()
    let picker = ExercisePicker(catalog: catalog)
    self.settings = settings
    self.picker = picker
    self.store = store
    self.idleMonitor = idleMonitor
    self.notifier = notifier
    self.overlay = overlay
    self.sound = sound
    self.clock = clock
    self.scheduler = BreakScheduler(
      settings: settings, availableKinds: picker.availableKinds(settings: settings), now: clock())
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

  public func apply(settings: Settings) {
    self.settings = settings
    store.save(settings)
    perform {
      $0.apply(
        settings: settings, availableKinds: picker.availableKinds(settings: settings), now: clock())
    }
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
    guard let plan = picker.plan(for: kind, settings: settings) else {
      perform { $0.skip(now: now) }
      return
    }
    let session = BreakSession(plan: plan, startedAt: now)
    self.session = session
    overlay.show(session: session, onSkip: { [weak self] in self?.skipCurrentBreak() })
    sound.playBreakStart()
  }

  private func endSession(finished: Bool) {
    overlay.hide()
    session = nil
    if finished { sound.playBreakEnd() }
  }
}
