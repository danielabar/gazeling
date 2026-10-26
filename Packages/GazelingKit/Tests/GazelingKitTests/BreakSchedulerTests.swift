import Foundation
import Testing

@testable import GazelingKit

private let t0 = Date(timeIntervalSinceReferenceDate: 0)
private func at(_ seconds: TimeInterval) -> Date { t0.addingTimeInterval(seconds) }
private let min = 60.0
private let both: Set<BreakKind> = [.short, .long]

/// Polls like the app does (every 5 s, user active) from `from` to `to`. Returns the states seen.
@discardableResult
private func run(
    _ s: inout BreakScheduler, from: TimeInterval, to: TimeInterval, idle: TimeInterval = 0
) -> [BreakState] {
    stride(from: from, through: to, by: 5).map { s.update(now: at($0), idleSeconds: idle) }
}

private func scheduler(_ settings: Settings = Settings(), kinds: Set<BreakKind> = both)
    -> BreakScheduler
{
    BreakScheduler(settings: settings, availableKinds: kinds, now: t0)
}

@Test func nothingHappensBeforeTheHeadsUp() {
    var s = scheduler()
    #expect(run(&s, from: 0, to: 20 * min - 35).allSatisfy { $0 == .working })
}

@Test func shortBreakGoesHeadsUpThenBreakThenWorking() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min - 30 - 5)
    #expect(
        s.update(now: at(20 * min - 30), idleSeconds: 0)
            == .headsUp(kind: .short, startsAt: at(20 * min)))
    #expect(
        s.update(now: at(20 * min - 1), idleSeconds: 0)
            == .headsUp(kind: .short, startsAt: at(20 * min)))
    #expect(
        s.update(now: at(20 * min), idleSeconds: 0) == .onBreak(kind: .short, endsAt: at(20 * min + 20))
    )
    #expect(
        s.update(now: at(20 * min + 19), idleSeconds: 0)
            == .onBreak(kind: .short, endsAt: at(20 * min + 20)))
    #expect(s.update(now: at(20 * min + 20), idleSeconds: 0) == .working)
}

@Test func timersRestartWhenTheBreakEndsNotWhenItStarts() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min + 20)
    #expect(s.shortDue == at(20 * min + 20 + 20 * min))
}

/// Kinds of the breaks that start while polling from 0 to `until`.
private func breakKinds(_ s: inout BreakScheduler, until: TimeInterval) -> [BreakKind] {
    var kinds: [BreakKind] = []
    var wasOnBreak = false
    for now in stride(from: 0.0, through: until, by: 5) {
        if case .onBreak(let kind, _) = s.update(now: at(now), idleSeconds: 0) {
            if !wasOnBreak { kinds.append(kind) }
            wasOnBreak = true
        } else {
            wasOnBreak = false
        }
    }
    return kinds
}

@Test func hourlyScheduleShortShortLongShort() {
    var s = scheduler()
    #expect(breakKinds(&s, until: 85 * min) == [.short, .short, .long, .short])
}

@Test func longBreakResetsTheShortTimerToo() {
    var s = scheduler()
    run(&s, from: 0, to: 60 * min + 5 * min)
    #expect(s.longDue == at(65 * min + 60 * min))
    #expect(s.shortDue == at(65 * min + 20 * min))
}

@Test func shortBreakJustBeforeLongIsReplacedByTheLongOne() {
    var settings = Settings()
    settings.shortBreakInterval = 25 * min
    var s = scheduler(settings)
    // Short at 25. The next short would be due at 50:20, within 12.5 min of the long at 60, so the long replaces it.
    #expect(breakKinds(&s, until: 62 * min) == [.short, .long])
}

@Test func idleForAShortBreakResetsOnlyTheShortTimer() {
    var s = scheduler()
    run(&s, from: 0, to: 10 * min)
    s.update(now: at(10 * min + 5), idleSeconds: 20)
    #expect(s.shortDue == at(10 * min + 5 + 20 * min))
    #expect(s.longDue == at(60 * min))
}

@Test func idleForALongBreakResetsBothTimers() {
    var s = scheduler()
    run(&s, from: 0, to: 10 * min)
    s.update(now: at(10 * min + 5), idleSeconds: 5 * min)
    #expect(s.longDue == at(10 * min + 5 + 60 * min))
}

@Test func briefIdleDoesNotReset() {
    var s = scheduler()
    s.update(now: at(5), idleSeconds: 19)
    #expect(s.shortDue == at(20 * min))
}

@Test func clockJumpFromSleepDoesNotStartABreak() {
    var s = scheduler()
    run(&s, from: 0, to: 10 * min)
    // Lid closed for 2 hours; the Mac reports 1 s idle after wake.
    #expect(s.update(now: at(10 * min + 2 * 3600), idleSeconds: 1) == .working)
    #expect(s.shortDue == at(10 * min + 2 * 3600 + 20 * min))
    #expect(s.longDue == at(10 * min + 2 * 3600 + 60 * min))
}

@Test func idleDuringBreakChangesNothing() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min)
    #expect(
        s.update(now: at(20 * min + 10), idleSeconds: 3600)
            == .onBreak(kind: .short, endsAt: at(20 * min + 20)))
}

@Test func idleThroughTheHeadsUpCountsAsTheBreakTaken() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min - 30)
    #expect(s.update(now: at(20 * min - 20), idleSeconds: 20) == .working)
    #expect(s.shortDue == at(20 * min - 20 + 20 * min))
}

@Test func skipDuringHeadsUpRestartsTheFullInterval() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min - 30)
    s.skip(now: at(20 * min - 30))
    #expect(s.state == .working)
    #expect(s.shortDue == at(20 * min - 30 + 20 * min))
}

@Test func skipDuringBreakEndsIt() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min + 5)
    s.skip(now: at(20 * min + 5))
    #expect(s.state == .working)
    #expect(s.shortDue == at(20 * min + 5 + 20 * min))
}

@Test func skipWhileWorkingSkipsTheNextBreak() {
    var s = scheduler()
    s.skip(now: at(60))
    #expect(s.shortDue == at(60 + 20 * min))
}

@Test func skippingALongBreakRestartsBothTimers() {
    var s = scheduler()
    run(&s, from: 0, to: 60 * min - 30)
    s.skip(now: at(60 * min - 30))
    #expect(s.longDue == at(60 * min - 30 + 60 * min))
}

@Test func postponeDelaysTheBreakByFiveMinutes() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min - 30)
    s.postpone(now: at(20 * min - 30))
    #expect(s.state == .working)
    #expect(s.shortDue == at(25 * min - 30))
    // Polling continues, so the 5 minute gap is not mistaken for sleep.
    #expect(run(&s, from: 20 * min - 25, to: 25 * min - 65).allSatisfy { $0 == .working })
    #expect(
        s.update(now: at(25 * min - 30), idleSeconds: 0)
            == .onBreak(kind: .short, endsAt: at(25 * min - 10)))
}

@Test func postponeOutsideHeadsUpDoesNothing() {
    var s = scheduler()
    s.postpone(now: at(60))
    #expect(s.shortDue == at(20 * min))
}

@Test func pausedForeverNeverFiresUntilResume() {
    var s = scheduler()
    s.pause(until: nil)
    #expect(run(&s, from: 0, to: 3 * 3600).allSatisfy { $0 == .paused(until: nil) })
    s.resume(now: at(3 * 3600 + 5))
    #expect(s.state == .working)
    #expect(s.shortDue == at(3 * 3600 + 5 + 20 * min))
}

@Test func pauseUntilResumesWithFreshTimers() {
    var s = scheduler()
    s.pause(until: at(30 * min))
    run(&s, from: 0, to: 30 * min - 5)
    #expect(s.update(now: at(30 * min), idleSeconds: 0) == .working)
    #expect(s.shortDue == at(30 * min + 20 * min))
}

@Test func skipWhilePausedDoesNothing() {
    var s = scheduler()
    s.pause(until: nil)
    s.skip(now: at(10))
    #expect(s.state == .paused(until: nil))
}

@Test func unavailableKindNeverFiresButTheOtherStill() {
    var s = scheduler(kinds: [.long])
    var seen: [BreakState] = []
    seen += run(&s, from: 0, to: 60 * min)
    #expect(!seen.contains(.onBreak(kind: .short, endsAt: at(20 * min + 20))))
    #expect(s.state == .onBreak(kind: .long, endsAt: at(60 * min + 5 * min)))
}

@Test func noAvailableKindsMeansNoBreaks() {
    var s = scheduler(kinds: [])
    #expect(run(&s, from: 0, to: 3 * 3600).allSatisfy { $0 == .working })
}

@Test func applyingSettingsRestartsTimers() {
    var s = scheduler()
    run(&s, from: 0, to: 10 * min)
    var settings = Settings()
    settings.shortBreakInterval = 5 * min
    s.apply(settings: settings, availableKinds: both, now: at(10 * min))
    #expect(s.shortDue == at(15 * min))
}

@Test func startBreakBeginsImmediatelyAndRespectsAvailability() {
    var s = scheduler(kinds: [.short])
    s.startBreak(.long, now: at(10))
    #expect(s.state == .working)
    s.startBreak(.short, now: at(10))
    #expect(s.state == .onBreak(kind: .short, endsAt: at(30)))
}

@Test func startBreakCanOverrideTheDuration() {
    var s = scheduler()
    s.startBreak(.short, now: at(10), duration: 4)
    #expect(s.state == .onBreak(kind: .short, endsAt: at(14)))
}

@Test func changingNothingTimingRelatedKeepsTheCountdown() {
    var s = scheduler()
    run(&s, from: 0, to: 10 * min)
    var changed = Settings()
    changed.soundsEnabled = false
    changed.disabledExerciseIDs = ["walk"]
    s.apply(settings: changed, availableKinds: both, now: at(10 * min))
    #expect(s.shortDue == at(20 * min) && s.longDue == at(60 * min))
}

@Test func changingAnIntervalRestartsTheTimers() {
    var s = scheduler()
    run(&s, from: 0, to: 10 * min)
    var changed = Settings()
    changed.shortBreakDuration = 30
    s.apply(settings: changed, availableKinds: both, now: at(10 * min))
    #expect(s.shortDue == at(30 * min))
}

@Test func aKindThatBecomesAvailableRestartsOnlyItsOwnTimer() {
    var s = scheduler(kinds: [.short])
    run(&s, from: 0, to: 10 * min)
    s.apply(settings: Settings(), availableKinds: both, now: at(10 * min))
    #expect(s.longDue == at(70 * min))
    #expect(s.shortDue == at(20 * min))
}

@Test func anUnrelatedChangeKeepsTheHeadsUp() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min - 30)
    let state = s.state
    var changed = Settings()
    changed.soundsEnabled = false
    s.apply(settings: changed, availableKinds: both, now: at(20 * min - 30))
    #expect(s.state == state)
}

@Test func aHeadsUpForAKindThatBecomesUnavailableIsCancelled() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min - 30)
    s.apply(settings: Settings(), availableKinds: [.long], now: at(20 * min - 30))
    #expect(s.state == .working)
}

@Test func changingSettingsDoesNotEndABreakInProgress() {
    var s = scheduler()
    run(&s, from: 0, to: 20 * min + 5)
    var changed = Settings()
    changed.shortBreakInterval = 10 * 60
    s.apply(settings: changed, availableKinds: both, now: at(20 * min + 5))
    #expect(s.state == .onBreak(kind: .short, endsAt: at(20 * min + 20)))
}
