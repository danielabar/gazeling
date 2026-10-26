# Worklog

Living status document. **Future agents: read this first, after `CLAUDE.md`.** Update it at the end of every work session: current phase, what is done, what is next, problems hit, and any deviation from `docs/planning/plan.md`.

## Current status

- **Phase:** 3 (working breaks with placeholder character), not started. Phases 0 to 2 complete.
- **Last updated:** 2026-10-26.

## Phase checklist (from plan.md section 6)

- [x] Phase 0: scaffold
- [x] Phase 1: platform spikes (overlay, notification, idle/sleep-wake, all with App Sandbox on). Findings in `docs/architecture.md`.
- [x] Phase 2: domain core (rules in `docs/architecture.md`, 47 tests)
- [ ] Phase 3: working breaks with placeholder character
- [ ] Phase 4: the owl
- [ ] Phase 5: settings and polish
- [ ] Phase 6: sound and voice
- [ ] Phase 7: docs and release

## Done

- Phase 2: `Exercise`, `ExerciseCatalog`, `exercises.json`, `Settings` + stores, `ExercisePicker`, `BreakPlan`, `BreakScheduler`, all test-first with no real clock. App still builds under Swift 6.
- Phase 1: all spikes verified (see Phase 1 notes and `docs/architecture.md`).
- Phase 0: `project.yml` (XcodeGen), `GazelingKit` package with one test, menu bar app with Quit item, `scripts/{build,test,run}.sh`, LICENSE, README, `.gitignore`. XcodeGen 2.46.0 installed via Homebrew with user approval. Verified: tests pass, build succeeds, app launches as background-only (no Dock icon).

- Phase 1 spike code written in `App/Spikes/Spikes.swift` (throwaway). Menu items "Spike: ..." in the menu bar, plus launch arguments `--spike-overlay`, `--spike-notify`, `--spike-idle`. Results go to `os.Logger`; read them as described in `docs/development.md`.

## Next

- Phase 3: replace `App/Spikes` with real adapters (overlay, notifier, idle monitor, sound) behind protocols. Add `AppState` and `BreakSession` view models: poll `BreakScheduler.update` about once a second, diff the state to trigger heads-up, overlay and chime. Add debug launch arguments and a menu item to start a break now. Localization keys in `exercises.json` need entries in `Localizable.xcstrings` (not created yet).
- Untested in Phase 1 (do during Phase 3): monitor plugged in/out mid-break, launch-at-login in the sandbox.
- Personal Team signing not needed so far (ad-hoc signing works for notifications and idle).

## Deviations from the plan

- Planning docs: `plan.md`, `research.md`, `names.md` are in `docs/planning/`. The brainstorm files (`stream-of-consciousness.md`, `eye-break-mac-app-conversation.md`, `prompt.md`) are in `scratch/` (globally gitignored, not part of the project). The plan said all go to `docs/planning/`; the user asked for brainstorm files to go to scratch.
- `git init` was skipped in Phase 0 at the user's request and done after Phase 1 (commit `44200ae`, branch `main`, no remote).
- `scripts/test.sh` runs only the `GazelingKit` package tests. No `AppTests` target yet.
- LICENSE copyright holder "Daniela Baron" was guessed. Ask the user to confirm.

- `exercises.json` is in the package (`Packages/GazelingKit/Sources/GazelingKit/Resources/`), not `App/Resources/` as the plan's layout says, so `swift test` can validate the shipped file.
- Product decisions made with the user in Phase 2: blink is in the short-break rotation and always in long breaks (not in every short break, since a 20 s break fits one exercise); all eye-movement exercises and palming are tagged short and long, `walk` and `eyes-closed-rest` long only; postpone is 5 minutes; skip restarts the full interval.
- Long-break plan rule: leftover seconds extend the last step, instead of an eyes-closed rest filler step.

## Challenges and findings

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
