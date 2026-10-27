# Worklog

Living status document. **Future agents: read this first, after `CLAUDE.md`.** Update it at the end of every work session: current phase, what is done, what is next, problems hit, and any deviation from `docs/planning/plan.md`.

## Current status

- **Phase:** 5 (settings and polish), just starting. Phases 0 to 4 complete.
- **Last updated:** 2026-10-26.

## Phase checklist (from plan.md section 6)

- [x] Phase 0: scaffold
- [x] Phase 1: platform spikes (overlay, notification, idle/sleep-wake, all with App Sandbox on). Findings in `docs/architecture.md`.
- [x] Phase 2: domain core (rules in `docs/architecture.md`, 47 tests)
- [x] Phase 3: working breaks with placeholder character (verified on laptop screen only; see leftovers under Next)
- [x] Phase 4: the owl (drawn, animated for all 9 exercises, reviewed by the user; images in `docs/images/`; rules in `docs/architecture.md`)
- [ ] Phase 5: settings and polish
- [ ] Phase 6: sound and voice
- [ ] Phase 7: docs and release
- [ ] Phase 9: branding (app icon from the Dusk owl, menu bar icon, README and GitHub images, tagline). Added at the user's request; the user is not a designer, so the agent proposes and the user picks. Scope in `docs/planning/plan.md` section 6. Can be done any time before release.
- [ ] Phase 8 (optional, after 5 and 6): user-chosen break sounds from the system sound list. Added at the user's request; scope in `docs/planning/plan.md` section 6.

## Done

- Phase 4, user feedback round 1: blink slowed to a 2 s cycle (instruction no longer says "about 15 times"). The look-far exercise felt creepy (front-facing owl staring at nothing), so it now shows a drawn window scene (`WindowSceneView`: sky gradient, drifting clouds, low sun, hills, trees, grass) beside the owl, which looks toward it (`OwlAnimation.scene(for:)`, `AnimatedOwlView(height:)`). **Option B if the user dislikes this: draw a second owl in profile looking out of the window** (large: new pose sheet and approval). `make inspect` starts the app with no automatic breaks (`--no-auto-breaks`) so the Debug menu items are the only way to start one. `make animation-strips` and `PoseSheet scene` render stills.
- Phase 5 slice 2 (settings window): `App/Settings/` has `SettingsWindowController` (AppKit `NSWindow` + `NSHostingView`, opened by the menu item "Settings…" (⌘,) and by `AppDelegate.applicationShouldHandleReopen`), `SettingsView` (tabs), `BreaksSettingsView` (steppers using the model's ranges), `ExercisesSettingsView` (per-exercise switch and Short/Long tick boxes; the last kind cannot be unticked; orange warning when a break kind has no enabled exercise). Each change goes through `AppState.apply`, which validates and saves. In SwiftUI files `Settings` is ambiguous with SwiftUI's own, so write `GazelingKit.Settings`. User guide: `scratch/manual-verification/phase5.md`.
- Phase 5 slice 3 (General tab, **uncommitted until the user has checked it**): `App/Settings/GeneralSettingsView.swift` with the owl-screen picker (`OverlayScreen`: pointer, main, all) and the sounds switch. `OverlayPresenter.show` now takes `contentScreens`; `OverlayWindowPresenter.screensShowingContent` picks the screens ("main" is `NSScreen.screens.first`, the one with the menu bar, not `NSScreen.main`, which follows keyboard focus). Every screen always dims. 100 tests. The specific-display option is deliberately not built until an external monitor is available.
- Phase 5 follow-ups: the menu label "Postpone by …" now shows the configured length (`DurationText` in the package, with a test). "Restore default timings" button on the Breaks tab (`Settings.restoreDefaultTimings`, resets only timings and the long-breaks switch). 99 tests.
- Phase 5 slice 1 (settings model, 95 tests): `Settings` gained `overlayScreen` (pointer/main/all) and `soundsEnabled`, range limits and `validated()` (long breaks stay longer and rarer than short ones, heads-up shorter than the interval), `setEnabled`/`setBreakKinds` (setting tags back to defaults removes the override). Debug timing overrides are now `TimingOverrides`, laid over the stored settings in `AppState` and never saved (before, touching any setting under `make demo` would have saved the 30 s intervals). `BreakScheduler.apply` restarts the countdown only when a timing value changes or a break kind becomes available (before, any change restarted it, and cancelled the heads-up). A test sets every `Settings` field to a non-default value and checks it survives save and load, plus a Mirror check that fails if a new field is not added to that test.
- Phase 4 animation: `OwlAnimation` in `GazelingCharacters` gives the pose as a pure function of time per script id (all 9 exercises, plus idle breathing, sway and blinks, plus a goodbye wave in the last 2.2 s of every break). `AnimatedOwlView` plays it with `TimelineView`. 71 tests. `make animation-strips` renders frames of every motion to `scratch/owl/animation-strips.png`. Reduce Motion is deliberately not supported (see Deviations).
- Phase 4: the owl is on the break screen, sized at 30% of screen height clamped to 240 to 360 pt (`OwlSize` in `App/Overlay/BreakOverlayView.swift`); user confirmed the size on the laptop screen. `PlaceholderCharacter` deleted.
- Phase 4 so far: the owl is drawn in `Packages/GazelingKit/Sources/GazelingCharacters` as separate parts (`OwlView`), driven by `OwlPose` (plain numbers: gaze x/y, eyelid, smile, brow, head tilt, each wing raise, wing cover). Three palettes. `OwlPoseSheet` rendering: `make pose-sheet` writes `scratch/owl/pose-sheet.png` through `ImageRenderer` in the `PoseSheet` command-line target, so the agent can view its own drawing (the Read tool shows PNGs) without screen-recording permission. Used by the break screen through `AnimatedOwlView`.

- Phase 3 verified by the user on the laptop screen: heads-up notification, dim, exercise text and countdown, sounds, Esc and Skip, pause/postpone/skip menu. Three overlay bugs found and fixed during manual testing (see Challenges). `make` targets added (`make demo` for a break within 30 s).
- Phase 3 code: `AppState` and `BreakSession` and the adapter protocols in `GazelingKit` (59 tests, fakes for every adapter); real adapters in `App/Adapters`, `App/Overlay`; menu in `App/Views/MenuContent.swift`; debug launch arguments in `App/DebugOptions.swift`; `App/Resources/Localizable.xcstrings`. `App/Spikes` deleted. Agent verified: tests pass, app builds, app runs 30 s with short debug intervals without crashing. The agent cannot see the screen, so the overlay, sounds and notification flow are unverified.
- Phase 2: `Exercise`, `ExerciseCatalog`, `exercises.json`, `Settings` + stores, `ExercisePicker`, `BreakPlan`, `BreakScheduler`, all test-first with no real clock. App still builds under Swift 6.
- Phase 1: all spikes verified (see Phase 1 notes and `docs/architecture.md`).
- Phase 0: `project.yml` (XcodeGen), `GazelingKit` package with one test, menu bar app with Quit item, `scripts/{build,test,run}.sh`, LICENSE, README, `.gitignore`. XcodeGen 2.46.0 installed via Homebrew with user approval. Verified: tests pass, build succeeds, app launches as background-only (no Dock icon).

- Phase 1 spike code written in `App/Spikes/Spikes.swift` (throwaway). Menu items "Spike: ..." in the menu bar, plus launch arguments `--spike-overlay`, `--spike-notify`, `--spike-idle`. Results go to `os.Logger`; read them as described in `docs/development.md`.

## Next

1. **Phase 5: settings and polish** (plan.md section 6). Order of work: settings window (breaks, exercises, which screen shows the owl, launch at login), first-run onboarding, reopen-from-Applications shows settings, native look, VoiceOver and keyboard pass.
2. **Needs the external monitor:** the owl-screen picker (pointer, main, all) on two screens, and (Phase 3 leftovers) monitor plugged in or out mid-break, dimming on a second screen with the panel window, launch-at-login in the sandbox. Check the owl size on a larger display too (`OwlSize` in `App/Overlay/BreakOverlayView.swift`).
3. Not built: Skip and Postpone buttons on the heads-up notification itself (they are in the menu).
4. Phase 9 (branding) and Phase 8 (optional custom sounds) are captured in plan.md.
5. Personal Team signing is not needed so far (ad-hoc signing works for notifications and idle).

## Deviations from the plan

- **Break kinds simplified (product owner, 2026-10-26):** only "Stand up and walk" is a long break (one exercise for the full 5 minutes); the other eight exercises are short only; users cannot change that, only switch exercises off. Reason: chaining eye exercises for 5 minutes could cause dizziness. Removed: per-exercise tag overrides (`breakKindOverrides`, `setBreakKinds`), long-break chaining and `includedInEveryLongBreak`. `Exercise` now has a single `breakKind`. Docs updated in research.md, plan.md and architecture.md. The settings window will not let the user switch off the last remaining break (`AppState.canSwitchOff`, `canTurnOffLongBreaks`): an app with every break off does nothing, and pausing is the way to stop breaks. Switching off all eye exercises (walk only) or the walk (eye breaks only) is allowed.
- UI strings are natural-English keys (`Text("Every")`), which display correctly in English without a catalog entry. `Localizable.xcstrings` currently holds only the exercise keys (referenced from JSON). Xcode normally adds the rest when the project is opened and built in the IDE; `xcodebuild` on the command line has never updated it. Revisit in Phase 7 (before any translation): export with `xcodebuild -exportLocalizations` or open the project in Xcode once and commit the result.
- **Reduce Motion is not supported** (product owner's decision, 2026-10-26; the owl always plays the full animation). Revisit if a user asks.
- Menu bar icon and app icon moved from Phase 5 to the new Phase 9 (branding). The menu uses the system `eye` symbol until then.
- Eye shine highlights move with the iris. The plan (Owl artwork table) said they stay fixed relative to the eye, but the user found a static highlight over a moving pupil looked wrong.
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
