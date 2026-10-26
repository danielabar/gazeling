# Worklog

Living status document. **Future agents: read this first, after `CLAUDE.md`.** Update it at the end of every work session: current phase, what is done, what is next, problems hit, and any deviation from `docs/planning/plan.md`.

## Current status

- **Phase:** 4 (the owl), static pose sheet drawn, look approved (Dusk), static owl wired into the break screen, **animation next**. Phases 0 to 3 complete (Phase 3 verified by the user on a laptop-only setup).
- **Last updated:** 2026-10-26.

## Phase checklist (from plan.md section 6)

- [x] Phase 0: scaffold
- [x] Phase 1: platform spikes (overlay, notification, idle/sleep-wake, all with App Sandbox on). Findings in `docs/architecture.md`.
- [x] Phase 2: domain core (rules in `docs/architecture.md`, 47 tests)
- [x] Phase 3: working breaks with placeholder character (verified on laptop screen only; see leftovers under Next)
- [ ] Phase 4: the owl
- [ ] Phase 5: settings and polish
- [ ] Phase 6: sound and voice
- [ ] Phase 7: docs and release

## Done

- Phase 4, user feedback round 1: blink slowed to a 2 s cycle (instruction no longer says "about 15 times"). The look-far exercise felt creepy (front-facing owl staring at nothing), so it now shows a drawn window scene (`WindowSceneView`: sky gradient, drifting clouds, low sun, hills, trees, grass) beside the owl, which looks toward it (`OwlAnimation.scene(for:)`, `AnimatedOwlView(height:)`). **Option B if the user dislikes this: draw a second owl in profile looking out of the window** (large: new pose sheet and approval). `make inspect` starts the app with no automatic breaks (`--no-auto-breaks`) so the Debug menu items are the only way to start one. `make animation-strips` and `PoseSheet scene` render stills.
- Phase 4 animation (uncommitted until the user has watched it): `OwlAnimation` in `GazelingCharacters` gives the pose as a pure function of time per script id (all 9 exercises, plus idle breathing, sway and blinks, plus a goodbye wave in the last 2.2 s of every break). `AnimatedOwlView` plays it with `TimelineView`. 71 tests. `make animation-strips` renders frames of every motion to `scratch/owl/animation-strips.png`. **Reduce Motion is deliberately not honoured yet** (user asked for full animation always, to ease testing); add it before release, per plan.md section 2.
- Phase 4: the static neutral owl is on the break screen, sized at 30% of screen height clamped to 240 to 360 pt (`OwlSize` in `App/Overlay/BreakOverlayView.swift`); user confirmed the size on the laptop screen. `PlaceholderCharacter` deleted. Next: animation.
- Phase 4 so far: the owl is drawn in `Packages/GazelingKit/Sources/GazelingCharacters` as separate parts (`OwlView`), driven by `OwlPose` (plain numbers: gaze x/y, eyelid, smile, brow, head tilt, each wing raise, wing cover). Three palettes. `OwlPoseSheet` rendering: `make pose-sheet` writes `scratch/owl/pose-sheet.png` through `ImageRenderer` in the `PoseSheet` command-line target, so the agent can view its own drawing (the Read tool shows PNGs) without screen-recording permission. Not yet used by the app.

- Phase 3 verified by the user on the laptop screen: heads-up notification, dim, exercise text and countdown, sounds, Esc and Skip, pause/postpone/skip menu. Three overlay bugs found and fixed during manual testing (see Challenges). `make` targets added (`make demo` for a break within 30 s).
- Phase 3 code: `AppState` and `BreakSession` and the adapter protocols in `GazelingKit` (59 tests, fakes for every adapter); real adapters in `App/Adapters`, `App/Overlay`; menu in `App/Views/MenuContent.swift`; debug launch arguments in `App/DebugOptions.swift`; `App/Resources/Localizable.xcstrings`. `App/Spikes` deleted. Agent verified: tests pass, app builds, app runs 30 s with short debug intervals without crashing. The agent cannot see the screen, so the overlay, sounds and notification flow are unverified.
- Phase 2: `Exercise`, `ExerciseCatalog`, `exercises.json`, `Settings` + stores, `ExercisePicker`, `BreakPlan`, `BreakScheduler`, all test-first with no real clock. App still builds under Swift 6.
- Phase 1: all spikes verified (see Phase 1 notes and `docs/architecture.md`).
- Phase 0: `project.yml` (XcodeGen), `GazelingKit` package with one test, menu bar app with Quit item, `scripts/{build,test,run}.sh`, LICENSE, README, `.gitignore`. XcodeGen 2.46.0 installed via Homebrew with user approval. Verified: tests pass, build succeeds, app launches as background-only (no Dock icon).

- Phase 1 spike code written in `App/Spikes/Spikes.swift` (throwaway). Menu items "Spike: ..." in the menu bar, plus launch arguments `--spike-overlay`, `--spike-notify`, `--spike-idle`. Results go to `os.Logger`; read them as described in `docs/development.md`.

## Next

- Phase 4: **user chose the Dusk palette** (indigo). Look and size approved. Re-check the size on a larger external monitor when available. Review sheet: `make pose-sheet`. Then: animation scripts per exercise (one per `animationScript` id in `exercises.json`), idle behaviours (blinks, head tilt), Reduce Motion fallback, screenshots into `docs/`.
- Use `make demo` to test a break by hand.

- Phase 3 leftovers (need the external monitor): monitor plugged in or out mid-break, dimming on a second screen with the new panel window, launch-at-login in the sandbox.
- Untested in Phase 1 (do during Phase 3): monitor plugged in/out mid-break, launch-at-login in the sandbox.
- Personal Team signing not needed so far (ad-hoc signing works for notifications and idle).

## Deviations from the plan

- The owl lives in a second package target, `GazelingCharacters` (SwiftUI), not in `App/Characters/`. Reason: it can be rendered and tested from the command line (`make pose-sheet`), and `GazelingKit` stays Foundation-only. The app will link it through `project.yml`.
- `.swift-format` sets 4-space indentation (the default is 2); the whole codebase was reformatted once.

- Planning docs: `plan.md`, `research.md`, `names.md` are in `docs/planning/`. The brainstorm files (`stream-of-consciousness.md`, `eye-break-mac-app-conversation.md`, `prompt.md`) are in `scratch/` (globally gitignored, not part of the project). The plan said all go to `docs/planning/`; the user asked for brainstorm files to go to scratch.
- `git init` was skipped in Phase 0 at the user's request and done after Phase 1 (commit `44200ae`, branch `main`, no remote).
- `scripts/test.sh` runs only the `GazelingKit` package tests. No `AppTests` target yet.
- LICENSE copyright holder "Daniela Baron" was guessed. Ask the user to confirm.

- `exercises.json` is in the package (`Packages/GazelingKit/Sources/GazelingKit/Resources/`), not `App/Resources/` as the plan's layout says, so `swift test` can validate the shipped file.
- Product decisions made with the user in Phase 2: blink is in the short-break rotation and always in long breaks (not in every short break, since a 20 s break fits one exercise); all eye-movement exercises and palming are tagged short and long, `walk` and `eyes-closed-rest` long only; postpone is 5 minutes; skip restarts the full interval.
- Long-break plan rule: leftover seconds extend the last step, instead of an eyes-closed rest filler step.

- `AppState`, `BreakSession` and the adapter protocols are in the `GazelingKit` package, not the app target, so they can be unit tested with fakes. They import only Foundation and Observation.
- Notification Skip/Postpone buttons are not built yet. Skip and Postpone are in the menu bar menu and Skip is on the overlay. Add the notification actions in Phase 5 if wanted.
- The overlay shows exercise text, countdown and a Skip button on the screen with the pointer; other screens only dim. The screen choice setting comes in Phase 5.

## Challenges and findings

- **Overlay bugs found in manual testing** (all fixed, see `App/Overlay/OverlayWindowPresenter.swift`):
  1. An `NSHostingView` as the window's content view resizes the window to the SwiftUI content, so the dim covered only part of the screen. Fix: `host.sizingOptions = []`, then `setFrame(screen.frame)`.
  2. SwiftUI content swallows Esc before the window sees it. Fix: `NSEvent.addLocalMonitorForEvents` for the duration of the break.
  3. A break starts while another app is frontmost, and macOS will not let a background app activate, so Esc needed a click. Fix: the overlay is an `NSPanel` with `.nonactivatingPanel`, which can be key without activating the app. Panels also hide on deactivate by default, so `hidesOnDeactivate = false` is required (without it the break ran but nothing showed).
  The Phase 1 spike missed 2 and 3 because it was started from the menu, which had already activated the app. Always test overlay behaviour with a timer-triggered break (`make demo`).
- `open` right after `pkill` can fail with LaunchServices error -600; `scripts/demo.sh` sleeps 1 s between them.
- The agent cannot see the screen or send key presses, so every visual or keyboard behaviour needs the user to confirm.
- A test that skipped polling for 5 minutes tripped the clock-jump rule (gap > 60 s counts as sleep). Tests must poll like the app. The app must poll about once a second while awake.
- `print` output vanishes when the app is launched from the menu or `open`. Spikes now use `os.Logger` (see `docs/development.md`). No `logs/` dir: the sandboxed app cannot write into the project folder.
- `NSWindow(contentRect:..., screen:)` treats contentRect as relative to that screen, so the overlay landed offset on the second monitor. Fixed by creating the window without `screen:` and calling `setFrame(screen.frame)`. Needs re-check by the user.
- Notification authorization status is already **denied (1)** before any request, so macOS will not show the prompt again. Probably recorded when the app was launched from the terminal during testing, or a prompt timed out unseen. Fix is in System Settings > Notifications (user step).
- `screencapture` from the agent's shell fails ("could not create image from display"), so the overlay cannot be checked by screenshot. The user must check it by eye.

## Phase 1 notes

Run 2026-10-26, App Sandbox ON (confirmed with `codesign -d --entitlements`), ad-hoc signing:

| Spike | Result |
|---|---|
| Idle detection (`CGEventSource.secondsSinceLastEventType`) | Works in the sandbox. Returned 0.58 s with no extra permission. |
| Overlay | User confirmed: dims both screens (laptop and large external) fully, Esc dismisses. Also shows over a full-screen app (YouTube full screen). |
| Notification | After the user allowed it in System Settings > Notifications, authorization worked and `add` returned no error, so ad-hoc signing is fine for notifications. But no banner was visible: needs a `UNUserNotificationCenterDelegate.willPresent` returning `.banner` (added). User confirmed the banner now shows. Earlier: status was already denied; `requestAuthorization` returned granted=false, `UNErrorDomain Code=1 "Notifications are not allowed for this application"`. Cause unknown: either no permission prompt appeared (ad-hoc signing, or app launched from the terminal) or it was not answered. **Open.** |
| Sleep/wake observers | **Works in the sandbox.** Log showed ScreensDidSleep, WillSleep, ScreensDidWake, DidWake during a real sleep. Registered (`NSWorkspace` will/did sleep, wake, screens sleep/wake, session active/resign). Not yet tested by actually sleeping. |
