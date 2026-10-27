# Architecture

Design intent lives in `docs/planning/plan.md`. This file records what was verified in practice. It grows as phases finish.

## Platform findings (Phase 1, 2026-10-26)

Tested on macOS 26.7.1 with the App Sandbox enabled (`App/Gazeling.entitlements`) and ad-hoc signing. A laptop screen plus one external monitor.

| Area | API | Finding |
|---|---|---|
| Idle time | `CGEventSource.secondsSinceLastEventType(.combinedSessionState, ...)` | Works in the sandbox, no permission prompt. Pass `CGEventType(rawValue: ~0)` for "any input". |
| Sleep/wake | `NSWorkspace.shared.notificationCenter`: `willSleep`, `didWake`, `screensDidSleep`, `screensDidWake`, session active/resign | Works in the sandbox. A real sleep delivered all four sleep/wake events. |
| Overlay | One borderless `NSWindow` per `NSScreen`, level `.screenSaver`, `collectionBehavior` `[.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]` | Dims every screen, Esc dismisses (the window subclass overrides `canBecomeKey`), and it appears over a full-screen app (a full-screen YouTube video). |
| Notifications | `UNUserNotificationCenter` | Works under ad-hoc signing once the user allows it in System Settings. |

Pitfalls found:
- **Window position.** `NSWindow(contentRect:styleMask:backing:defer:screen:)` treats `contentRect` as relative to that screen. Create the window without `screen:` and call `setFrame(screen.frame, display: true)`.
- **Banners hidden when frontmost.** Set a `UNUserNotificationCenterDelegate` whose `willPresent` returns `[.banner, .sound]`. Without it, a menu bar app posting right after a menu click shows nothing.
- **Denied status is sticky.** Once macOS records notifications as denied, the app cannot re-prompt. The user must allow it in System Settings > Notifications.
- **Logging.** `print` is invisible when launched from the menu. Use `os.Logger`; see `docs/development.md`.

Not yet tested: plugging a monitor in or out mid-break, Spaces switching during a break, launch-at-login (`SMAppService`) inside the sandbox.

## Code layout

Spike code in `App/Spikes/Spikes.swift` is throwaway. Phase 3 replaces it with the adapters described in the plan.

## Domain rules (Phase 2, `Packages/GazelingKit`)

All of this is plain Swift with no UI imports. `scripts/test.sh` runs the tests (47 at the end of Phase 2).

**Exercises.** `exercises.json` lives in the package (`Sources/GazelingKit/Resources/`) so `swift test` checks the shipped file. It holds localization keys, a nominal duration, a `breakKind` (`short` or `long`) and an animation script id. Only `walk` is `long`; the other eight are `short`. (Originally most exercises could appear in both kinds and long breaks chained several; the product owner changed this on 2026-10-26 because minutes of eye movements could cause dizziness. The chain logic and the per-exercise tag overrides were deleted.)

**Settings.** Defaults from `research.md`, plus postpone 5 min. Decoding uses `decodeIfPresent` per key, so a field added later never wipes saved settings. Exercises are excluded through `disabledExerciseIDs`; that is the only per-exercise setting.

**Exercise choice.** `ExercisePicker.availableKinds`: a break kind is available only if it has at least one enabled exercise (long also needs `longBreaksEnabled`). Unavailable kinds never fire. Each break is one exercise, round-robin in catalog order within its kind (a pool of one repeats), stretched to the break's duration. The long break is therefore always the walk, for the full long-break duration.

**Scheduler** (`BreakScheduler`) has no timers. The app calls `update(now:idleSeconds:)` about once a second.
- States: `working`, `headsUp(kind, startsAt)`, `onBreak(kind, endsAt)`, `paused(until)`.
- Timers restart when a break **ends** (or is skipped). A short break restarts the short timer; a long break restarts both.
- A long break replaces a short break that would fall within half a short interval before it (so a short break never ends just before a long one starts).
- Idle in `working`: idle >= short break length restarts the short timer; idle >= long break length restarts both.
- Idle during a break is ignored. Idle for a full break length during the heads-up counts as the break taken.
- Clock jump: if two updates are more than 60 s apart (Mac slept), the gap counts as idle. Waking never starts a break. The app must therefore poll often while awake.
- Skip restarts the timer for that break's kind. Postpone (only from the heads-up) pushes that kind's due time by `postponeDuration`. Pause and resume restart both timers.
- `apply(settings:availableKinds:now:)` restarts timers when settings change.

The scheduler returns state only. The app (Phase 3) diffs the state to trigger the notification, overlay and sound.

## The owl (Phase 4, `Packages/GazelingKit/Sources/GazelingCharacters`)

Review images are in `docs/images/`: `owl-pose-sheet.png` (poses and palettes), `owl-animation-strips.png` (frames of every exercise animation) and `owl-window-scene.png`. Regenerate them with `make pose-sheet`, `make animation-strips` or `swift run --package-path Packages/GazelingKit PoseSheet sheet|strips|scene <out.png>`.

- **Drawing.** `OwlView` draws the owl from separate parts in a fixed 200 x 240 space, scaled to fit. Back to front: feet, body, head (ear tufts, face, eyes, lids, brows, beak), wings. The look is the Dusk palette (indigo owl, amber eyes), chosen by the product owner. `OwlPalette` also has Honey and Mist, unused.
- **Pose.** `OwlPose` is a struct of plain `Double`s (gaze x and y, eyelid, smile, brow, head tilt, each wing, wing cover, bounce, feet, breathe), so poses can be blended with `blended(with:_:)`.
- **Animation.** `OwlAnimation.pose(script:at:duration:)` is a pure function of time, so it is unit tested and can be rendered to still frames. Each exercise names its script in `exercises.json` (`animationScript`); a test checks every exercise has one. Each step eases in from, and back out to, neutral over 0.5 s. Idle breathing, head sway and occasional blinks are added on top. In the last 2.2 s of every break the owl waves goodbye.
- **Playback.** `AnimatedOwlView` uses `TimelineView(.animation)` and the step's start time from `BreakSession.stepStartedAt`. `BreakOverlayView` sizes the owl at 30% of the screen height, clamped to 240 to 360 pt (`OwlSize`).
- **Scene.** `look-far` also shows `WindowSceneView` beside the owl (sky, drifting clouds, sun, hills, trees), chosen through `OwlAnimation.scene(for:)`. The first version, a front-facing owl staring into space, felt creepy to the product owner. The fallback if the window is disliked is a profile owl.
- **Design decisions.** Eye shine moves with the iris (not fixed to the eye as first planned). Reduce Motion is deliberately not supported. Wings cover the eyes by sweeping inward across the chest (the outward route made the wings fling wide).
- **Debug.** Debug builds have a "Debug: play exercise" menu. `make inspect` starts with no automatic breaks.
