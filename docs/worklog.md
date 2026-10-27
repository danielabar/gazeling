# Worklog

Living status document. **Future agents: read `CLAUDE.md`, then this file, before doing anything.** Update it at the end of every work session: where things stand, what is next, problems hit, deviations from `docs/planning/plan.md`.

## Where we are (last updated 2026-10-26)

- **Phase 5 (settings and polish), slices 1 to 3 of 6 done and committed.** Latest commit: `6dd3e97`. Branch `main`, no remote, working tree clean.
- 100 unit tests, all passing (`make test`). The app builds (`make build`).
- Phases 0 to 4 are complete. Phase 4 (the owl) was reviewed and approved by the product owner.
- The product owner works on a **laptop only** for now (no external monitor), and stopped for the day after slice 3. They will pick it up the next day with a new agent.

## START HERE: next steps, in order

Phase 5 remaining slices. The product owner checks each one by hand (they are not a Mac developer; the agent cannot see the screen). After each slice: commit only when they say so, and update this file.

### Slice 4: launch at login (needs the user at the keyboard)

1. **Spike first, then build UI.** Launch at login in the App Sandbox is still **unverified**. In a throwaway debug menu item, call `SMAppService.mainApp.register()` under ad-hoc signing and log the result and `SMAppService.mainApp.status` with `os.Logger`. Expect `.requiresApproval`: the user must approve it in System Settings → General → Login Items & Extensions. Record the findings in `docs/architecture.md` (platform findings table).
2. **Warn the user before they test, and have them undo it.** Registering makes macOS launch the *development build* (it lives in DerivedData) at every login on their real Mac. Tell them first, and tell them to switch it off afterwards (toggle in the app, or System Settings → Login Items).
3. **Do not store the toggle in `Settings`.** Read `SMAppService.mainApp.status` every time the General tab is shown, because the user can change it in System Settings behind the app's back.
4. Put it behind a protocol (`LaunchAtLogin`, listed in plan.md section 2) with a fake for tests, like the other adapters (`Packages/GazelingKit/Sources/GazelingKit/Adapters.swift`).
5. UI: a toggle on the General tab (`App/Settings/GeneralSettingsView.swift`). When the status is `.requiresApproval`, show a short explanation and a button using `SMAppService.openSystemSettingsLoginItems()`.

### Slice 5: first-run setup

- `AppState.start()` currently asks for notification permission **on every launch**, so a brand-new user gets the macOS prompt with no explanation. Move that request behind a first-run window (an AppKit controller like `SettingsWindowController`) that explains why, asks for notification permission, and offers launch at login.
- Record "setup done" under **its own UserDefaults key**, not in `Settings` (and not wiped by "restore defaults"). Test it.
- Handle the **denied** case: once macOS records notifications as denied it never prompts again (found in Phase 1). Show a button to open System Settings → Notifications.
- Add a debug menu item to reset first-run state, so the user can re-test it.

### Slice 6: accessibility and native look

- VoiceOver labels on the menu items, settings controls and the overlay (Skip button, countdown, the exercise title and instruction). The owl itself is decorative (`accessibilityHidden` already).
- Keyboard-only pass: Tab through settings, ⌘, opens settings, Esc skips a break.
- Contrast of the overlay text on the 75% black dim (the grey secondary text especially).
- Then extend `scratch/manual-verification/phase5.md` with VoiceOver and keyboard steps, and tick Phase 5 below.

### Then

- **Phase 6** (sound and voice): our own chime and Kokoro voice clips. Today `SystemSoundPlayer` plays macOS's Tink (start) and Glass (end).
- **Phase 7** (docs and release): About screen, `docs/user-guide.md`, GitHub Actions, release. Also decide the `Localizable.xcstrings` question (see Deviations).
- **Phase 9** (branding) can happen any time: app icon, menu bar icon, README images. The user is not a designer: propose, let them choose.
- **Phase 8** (optional): user-chosen break sounds. Scope in plan.md.

### Waiting for the external monitor

- The **owl-screen picker** on two screens (pointer / main / every screen). Only checked on one screen so far. A "specific display" option is deliberately not built until this can be tested.
- Phase 3 leftovers: unplugging or plugging in a monitor mid-break, dimming on the second screen with the panel window.
- The owl size on a larger display (`OwlSize` in `App/Overlay/BreakOverlayView.swift`, currently 30% of screen height clamped to 240 to 360 pt).

### Small known gaps

- The heads-up notification has no Skip or Postpone buttons (they are in the menu bar menu).
- The owl is the "Dusk" palette only. `OwlPalette` also has Honey and Mist, unused.
- If the user dislikes the look-far window scene: option B is a second owl drawn in profile (large job, needs a new pose sheet and approval).
- The product owner's saved settings may be non-default from testing. The Breaks tab has "Restore default timings".

## How to work here (hard-won lessons)

**The product owner.** Product manager and web developer (Rails), no native Mac experience. Explain Apple-specific terms briefly. They often ask a question first: when they say "just a question" or "don't change anything", answer only. Commit only when asked. They like plain-language, copy-paste instructions: manual test guides go in `scratch/manual-verification/` (gitignored; recreate if missing) with exact commands and "what you should see".

**Commands** (`make help` lists them): `make test`, `make build`, `make run` (real timings and saved settings), `make demo` (break within 30 s, debug timings, not saved), `make inspect` (no automatic breaks; start things from the Debug menu), `make stop`, `make logs`, `make pose-sheet`, `make animation-strips`. In debug builds the eye menu has Debug items: start short or long break, play any exercise, goodbye wave.

**What the agent cannot do.** It cannot see the screen or press keys, and `screencapture` fails (no screen-recording permission, and do not ask for it). So: draw things in code, render them to PNG with `ImageRenderer` (`PoseSheet` target) and look at the PNG with the Read tool; but AppKit-backed controls (toggles, pickers, steppers) do not render that way, so the user checks the settings window by eye.

**Pitfalls that cost time.**
- zsh does **not** split unquoted variables, so `$CMD args` and `set -- $m` fail silently. Write commands out in full.
- `log` is shadowed in zsh. Use `/usr/bin/log` or `make logs`.
- In SwiftUI files, `Settings` is ambiguous with SwiftUI's own type. Write `GazelingKit.Settings`.
- `swift format` (config in `.swift-format`: 4 spaces) rewrites layout, so a Python string-replace edit written from memory may not match. Re-read the file first. Run `swift format --in-place --recursive Packages App` before committing.
- Overlay bugs only show with a break that starts from the timer while another app is in front. Always test with `make demo`, not only the menu (see Challenges).
- `open` straight after `pkill` can fail with LaunchServices error -600. `scripts/demo.sh` sleeps a second.
- Tests must poll `BreakScheduler.update` about once a second, like the app. A gap over 60 s counts as the Mac having slept, and resets the timers.
- `scripts/test.sh` runs only the package tests (`Packages/GazelingKit`). The app target has no automated tests, so keep logic in the package and views thin.

**Code layout.** `Packages/GazelingKit`: `GazelingKit` (Foundation only: scheduler, settings, `AppState`, adapter protocols), `GazelingCharacters` (SwiftUI: owl, animation, window scene), `PoseSheet` (command-line renderer). `App/`: the real adapters (`Adapters/`, `Overlay/`), menu, settings window (`Settings/`), debug options. Rules and design are in `docs/architecture.md`; platform findings (sandbox, notifications, overlay) are there too.

## Phase checklist (plan.md section 6)

- [x] Phase 0: scaffold
- [x] Phase 1: platform spikes
- [x] Phase 2: domain core
- [x] Phase 3: working breaks with placeholder character
- [x] Phase 4: the owl (images in `docs/images/`)
- [ ] Phase 5: settings and polish. Done: slice 1 (settings model), 2 (settings window: Breaks, Exercises), 3 (General tab: owl screen, sounds). Left: slices 4 to 6 above.
- [ ] Phase 6: sound and voice
- [ ] Phase 7: docs and release
- [ ] Phase 8 (optional): user-chosen break sounds
- [ ] Phase 9: branding

## What exists (summary of Done)

- **Phase 0 to 2:** XcodeGen project (`project.yml`, App Sandbox on, bundle id `com.danielabar.gazeling`, macOS 15 minimum); the domain core: `Exercise`, `ExerciseCatalog` (`exercises.json` in the package), `Settings` and stores, `ExercisePicker`, `BreakPlan`, `BreakScheduler` (pure state machine, no timers).
- **Phase 3:** `AppState` and `BreakSession` connect the scheduler to the platform through adapters (idle monitor, notifier, overlay, sound): heads-up notification, dimmed overlay with the owl, exercise text, countdown, Skip and Esc, sounds, menu bar menu (next break time, skip, postpone, pause, settings, quit).
- **Phase 4:** the owl drawn in code (`OwlView`), per-exercise animation as pure functions of time (`OwlAnimation`), idle life (breathing, blinks, sway), a goodbye wave in the last 2.2 s of every break, a window scene beside the owl for "Look far away".
- **Phase 5 so far:** settings model with validation and ranges; debug timing overrides that are never saved; scheduler restarts the countdown only when a timing value changes; settings window (AppKit window hosting SwiftUI, opened from the menu or when the app is reopened) with General, Breaks and Exercises tabs; "Restore default timings"; the last remaining break cannot be switched off; the postpone label shows the configured length.

## Deviations from the plan

- **Break kinds (product owner, 2026-10-26):** only "Stand up and walk" is a long break (one exercise for the whole long break); the other eight exercises are short breaks. Users cannot change that; they can only switch exercises off, but not the last remaining break. Reason: minutes of eye exercises could cause dizziness. Documented in research.md, plan.md and architecture.md.
- **Reduce Motion is not supported** (product owner's decision). Revisit if a user asks.
- Menu bar icon and app icon moved from Phase 5 to Phase 9 (branding). The menu uses the system `eye` symbol until then.
- Eye shine highlights move with the iris (plan said fixed to the eye): a static highlight over a moving pupil looked wrong.
- The owl lives in its own package target `GazelingCharacters`, not `App/Characters/`, so it can be rendered and tested from the command line.
- `exercises.json` is in the package (`Sources/GazelingKit/Resources/`), not `App/Resources/`, so tests check the shipped file.
- `AppState`, `BreakSession` and the adapter protocols are in `GazelingKit`, not the app target, so they can be tested with fakes.
- Planning docs are in `docs/planning/`; the brainstorm files are in `scratch/` (globally gitignored).
- UI strings are natural-English keys (`Text("Every")`), which display correctly in English without a catalog entry. `Localizable.xcstrings` holds only the exercise keys (referenced from JSON). Command-line `xcodebuild` has never updated the catalog. Decide in Phase 7, before any translation: `xcodebuild -exportLocalizations`, or open the project in Xcode once and commit the result.
- LICENSE copyright holder "Daniela Baron" was guessed from the email address. Ask the user to confirm.
- Notification Skip/Postpone buttons: not built (menu and overlay only).

## Challenges and findings

- **Overlay bugs found in manual testing** (all fixed in `App/Overlay/OverlayWindowPresenter.swift`):
  1. An `NSHostingView` as a window's content view resizes the window to the SwiftUI content, so the dim covered only part of the screen. Fix: `host.sizingOptions = []`, then `setFrame(screen.frame)`.
  2. SwiftUI content swallows Esc before the window sees it. Fix: `NSEvent.addLocalMonitorForEvents` while a break shows.
  3. A break starts while another app is in front, and macOS will not let a background app take focus, so Esc needed a click. Fix: the overlay is an `NSPanel` with `.nonactivatingPanel`, which can be key without activating the app. Panels hide on deactivate by default, so `hidesOnDeactivate = false` is required.
  4. `NSWindow(contentRect:..., screen:)` treats the rect as relative to that screen. Create the window without `screen:` and call `setFrame(screen.frame)`.
- **Notifications:** need the user to allow them in System Settings. Once macOS records "denied" it never prompts again. A `UNUserNotificationCenterDelegate.willPresent` returning `.banner` is needed or a menu bar app's banner is hidden. Works under ad-hoc signing; Personal Team signing was not needed.
- **Idle time and sleep/wake notifications work in the sandbox** with no extra permission (details in `docs/architecture.md`).
- **Owl design lessons:** happy eyes need a full "^ ^" arc, not a half-closed crescent; palming wings must sweep inward across the chest, not outward; blink at about 2 s per blink felt right (the 15-reps figure in research.md came from sessions of that exercise alone, not a 20 s break).
- `print` output vanishes when the app is launched from the menu or `open`. Use `os.Logger` (subsystem `com.danielabar.gazeling`), read with `make logs`. The sandboxed app cannot write into the project folder, so there is no `logs/` directory.
