import Foundation

public enum BreakState: Equatable, Sendable {
    case working
    /// A break of `kind` starts at `startsAt`. The app shows the heads-up notification.
    case headsUp(kind: BreakKind, startsAt: Date)
    case onBreak(kind: BreakKind, endsAt: Date)
    /// `until` is nil for "until I resume".
    case paused(until: Date?)
}

/// Decides when breaks happen. It has no timers: the app calls `update` about once a second and
/// reacts to the returned state. Time and idle seconds are passed in, so tests need no real clock.
public struct BreakScheduler: Sendable {
    /// If two `update` calls are further apart than this, the Mac was asleep (or the app was
    /// suspended). The gap counts as idle time, so waking the Mac never starts a break at once.
    public static let clockJumpThreshold: TimeInterval = 60

    /// Input idle time that counts as being away from the Mac, which restarts both timers. It is long
    /// because no keyboard or mouse input does not mean resting: reading or watching still strains the eyes.
    public static let awayThreshold: TimeInterval = 5 * 60

    public private(set) var state: BreakState = .working
    public private(set) var shortDue: Date
    public private(set) var longDue: Date
    private var settings: Settings
    private var availableKinds: Set<BreakKind>
    private var lastUpdate: Date

    public init(settings: Settings, availableKinds: Set<BreakKind>, now: Date) {
        self.settings = settings
        self.availableKinds = availableKinds
        self.lastUpdate = now
        self.shortDue = now.addingTimeInterval(settings.shortBreakInterval)
        self.longDue = now.addingTimeInterval(settings.longBreakInterval)
    }

    /// Applies changed settings. The countdown restarts only if a timing value changed, or for a break
    /// kind that has just become available. Other changes (an exercise turned off, sounds) leave it alone.
    public mutating func apply(settings: Settings, availableKinds: Set<BreakKind>, now: Date) {
        let timingsChanged = settings.timings != self.settings.timings
        let newlyAvailable = availableKinds.subtracting(self.availableKinds)
        self.settings = settings
        self.availableKinds = availableKinds

        if timingsChanged {
            reset(.long, now: now)
        } else {
            for kind in newlyAvailable { restartTimer(for: kind, now: now) }
        }

        switch state {
        case .headsUp(let kind, _):
            // The announced break may no longer be due when or where it was.
            if timingsChanged || !availableKinds.contains(kind) { state = .working }
        case .onBreak(let kind, _):
            if !availableKinds.contains(kind) { state = .working }
        case .working, .paused:
            break
        }
    }

    /// A break lasts its lead-in (time to read the instruction) plus its configured length.
    private func breakEnd(_ kind: BreakKind, from now: Date) -> Date {
        now.addingTimeInterval(settings.breakLeadIn(for: kind) + settings.breakDuration(for: kind))
    }

    private mutating func restartTimer(for kind: BreakKind, now: Date) {
        let due = now.addingTimeInterval(settings.breakInterval(for: kind))
        if kind == .short { shortDue = due } else { longDue = due }
    }

    @discardableResult
    public mutating func update(now: Date, idleSeconds: TimeInterval) -> BreakState {
        let gap = now.timeIntervalSince(lastUpdate)
        lastUpdate = now
        let idle = gap > Self.clockJumpThreshold ? max(idleSeconds, gap) : idleSeconds

        switch state {
        case .paused(let until):
            if let until, now >= until {
                reset(.long, now: now)
                state = .working
            }
        case .onBreak(let kind, let endsAt):
            // Idle is expected during a break, so it is ignored. Timers restart when the break ends.
            if now >= endsAt {
                reset(kind, now: now)
                state = .working
            }
        case .headsUp(let kind, let startsAt):
            if idle >= Self.awayThreshold {
                // The user is away from the Mac.
                reset(.long, now: now)
                state = .working
            } else if now >= startsAt {
                state = .onBreak(kind: kind, endsAt: breakEnd(kind, from: now))
            }
        case .working:
            if idle >= Self.awayThreshold { reset(.long, now: now) }
            if let next = nextBreak() {
                if now >= next.due {
                    state = .onBreak(kind: next.kind, endsAt: breakEnd(next.kind, from: now))
                } else if now >= next.due.addingTimeInterval(-settings.headsUpLead) {
                    state = .headsUp(kind: next.kind, startsAt: next.due)
                }
            }
        }
        return state
    }

    /// Starts a break immediately (debug menu, launch arguments). Does nothing if paused or the kind is unavailable.
    public mutating func startBreak(_ kind: BreakKind, now: Date, duration: TimeInterval? = nil) {
        guard availableKinds.contains(kind) else { return }
        if case .paused = state { return }
        let endsAt = duration.map { now.addingTimeInterval($0) } ?? breakEnd(kind, from: now)
        state = .onBreak(kind: kind, endsAt: endsAt)
    }

    /// Cancels the current or upcoming break and restarts the timer for its kind.
    public mutating func skip(now: Date) {
        let kind: BreakKind
        switch state {
        case .paused: return
        case .headsUp(let k, _), .onBreak(let k, _): kind = k
        case .working:
            guard let next = nextBreak() else { return }
            kind = next.kind
        }
        reset(kind, now: now)
        state = .working
    }

    /// Delays the break announced by the heads-up. Does nothing in other states.
    public mutating func postpone(now: Date) {
        guard case .headsUp(let kind, _) = state else { return }
        let due = now.addingTimeInterval(settings.postponeDuration)
        if kind == .short { shortDue = due } else { longDue = due }
        state = .working
    }

    public mutating func pause(until: Date?) {
        state = .paused(until: until)
    }

    public mutating func resume(now: Date) {
        guard case .paused = state else { return }
        reset(.long, now: now)
        state = .working
    }

    /// Timers restart when a break ends or is skipped, not when it starts. A long break restarts both.
    private mutating func reset(_ kind: BreakKind, now: Date) {
        shortDue = now.addingTimeInterval(settings.shortBreakInterval)
        if kind == .long { longDue = now.addingTimeInterval(settings.longBreakInterval) }
    }

    /// The long break replaces a short one that would fall within half a short interval before it.
    /// Otherwise a short break could end just before the long one starts.
    public func nextBreak() -> (kind: BreakKind, due: Date)? {
        let shortOn = availableKinds.contains(.short)
        let longOn = availableKinds.contains(.long)
        let shortFirst =
            shortOn
            && (!longOn || shortDue <= longDue.addingTimeInterval(-settings.shortBreakInterval / 2))
        if shortFirst { return (.short, shortDue) }
        if longOn { return (.long, longDue) }
        return nil
    }
}
