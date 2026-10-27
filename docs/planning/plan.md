# Plan: Mac Eye-Break App

App name: **Gazeling** (decided 2026-10-26; see `names.md`). The name works for any character, not just the owl. "EyeBreak" was the earlier placeholder and was dropped because it is widely used.

This plan covers architecture, project layout, tooling, build and test commands, and the order of work. It does not contain working code yet. Product decisions live in `stream-of-consciousness.md` (requirements), `research.md` (exercises, schedule defaults) and `eye-break-mac-app-conversation.md` (earlier planning chat).

## 1. Summary of choices

| Area | Choice | Why |
|---|---|---|
| Language | Swift 6 | Apple's language; strict concurrency checking catches timer/UI threading bugs. |
| UI | SwiftUI, with AppKit for the full-screen overlay | SwiftUI for menu bar, settings, owl animation. AppKit only where SwiftUI cannot do it (borderless windows over every screen and Space). |
| Minimum macOS | **15 (Sequoia)**, built and tested on **26 (Tahoe)** | Supports the current release and the one before it. See [Keeping up with new macOS versions](#keeping-up-with-new-macos-versions). |
| Architecture | **MVVM-style, with a plain-Swift domain core** (details in section 2) | Idiomatic for SwiftUI. Business logic is testable without any UI. |
| Project definition | **XcodeGen** (`project.yml`) generating the `.xcodeproj` | Xcode's native project file is hard to read and edit. A short YAML file is easy for the agent and for git diffs. |
| Domain code | Local **Swift package** (`GazelingKit`) | `swift test` runs in seconds from the terminal with no Xcode. |
| Persistence | `UserDefaults` for settings, bundled JSON for the exercise catalog | Small data. No database needed. |
| Localization | **String Catalogs** (`Localizable.xcstrings`) from day one | Apple's current standard. English only at first. |
| Tests | **Swift Testing** (`import Testing`) for unit tests; manual and screenshot checks for the overlay | Current Apple framework, less boilerplate than XCTest. |
| Format / lint | `swift format` (ships with the Swift toolchain) | No extra install. SwiftLint can be added later if wanted. |
| License | MIT | As requested. |

## 2. Architecture

### Direct answers to the questions in the brainstorm

- **Is it MVC/MVP?** Not exactly. Apple's older desktop apps used MVC (Cocoa). SwiftUI replaced the controller with data binding, so modern Mac apps are usually described as **MVVM** or simply **"Model-View"** with observable state objects. Presenters (MVP) are not a common pattern in SwiftUI.
- **Business logic in plain old objects, or services?** Both, in a light way. The rules (when is a break due, which exercise is next, what counts as idle) live in **plain Swift types with no UI imports**. Anything that touches the system (clock, idle detection, notifications, screens, sound) sits behind a small **protocol**, so tests can substitute fakes. This is ordinary dependency injection, not a heavy "service layer".
- **What do respected Apple developers do?** From what I know, the mainstream advice is: keep views small and declarative, put state in `@Observable` classes, inject dependencies through initializers or the SwiftUI environment, and keep logic out of views. There are heavier frameworks (for example the Composable Architecture). I am not recommending one: it adds a learning curve and a dependency this app does not need. I did not research individual developers' posts in this session; if you want that, it is a separate task.
- **Principle to follow:** "pure object-oriented rather than services" is a false choice here. The rule of thumb is *pure logic in value types and small classes; side effects at the edges behind protocols.*

### Layers

```
┌───────────────────────────────────────────────┐
│ Views (SwiftUI)                               │  menu bar, settings, About, owl, overlay content
├───────────────────────────────────────────────┤
│ View models / app state (@Observable, @MainActor) │  AppState, SettingsModel, BreakSession
├───────────────────────────────────────────────┤
│ Domain core (plain Swift, no UI imports)      │  BreakScheduler, ExerciseCatalog, ExercisePicker, BreakPlan
├───────────────────────────────────────────────┤
│ Platform adapters (behind protocols)          │  Clock, IdleMonitor, Notifier, ScreenProvider,
│                                               │  OverlayPresenter, SoundPlayer, LaunchAtLogin
└───────────────────────────────────────────────┘
```

Rules:
1. Dependencies point downward only. The domain core imports `Foundation` and nothing else.
2. Every platform adapter has a protocol in the domain layer and a real implementation in the app target. Tests use fakes.
3. Views never contain scheduling or selection logic.

### Main components

| Component | Layer | Responsibility |
|---|---|---|
| `Exercise` | Domain | Value type loaded from JSON: id, localization key, duration, break kind (short, or long for the walk only), animation script id, audio file. |
| `ExerciseCatalog` | Domain | Loads `exercises.json`. Adding an exercise means adding a JSON entry, a localized string and (if new) an animation script. |
| `Settings` | Domain | `Codable` struct: intervals, durations, long-break on/off, enabled exercise ids, chosen display mode, sounds. Defaults match `research.md`. |
| `ExercisePicker` | Domain | Chooses the next exercise from the enabled pool for a break type. Rotates, no immediate repeats. Returns nothing if the pool is empty. |
| `BreakPlan` | Domain | The exercise for one break, stretched to the break duration. A short break is one eye exercise; the long break is the walk. |
| `BreakScheduler` | Domain | State machine: working, heads-up, on break, paused, snoozed. Driven by an injected `Clock` and `IdleMonitor`. Decides when the next break is due, applies the idle reset, handles postpone, skip and pause. |
| `AppState` | View model | Owns the scheduler and settings, exposes state to the menu bar and settings views. |
| `BreakSession` | View model | While a break runs: current exercise, countdown, progress. Feeds the overlay and the owl. |
| `OverlayPresenter` | Adapter (AppKit) | Creates a borderless window per screen at a high window level, on all Spaces, hosting the SwiftUI break view. Reacts to monitors being added or removed mid-break. |
| `Notifier` | Adapter | `UNUserNotificationCenter` heads-up notification and permission request. |
| `IdleMonitor` | Adapter | Seconds since last keyboard or mouse input, plus sleep/wake and screen-lock events. |
| `SoundPlayer` | Adapter | Chime at break start and end, and optional voice clips. |
| `Character` | View | A protocol for a character that renders a pose from parameters (gaze direction, eyelid closure, body position). The owl is the first implementation. |

### Characters and animation

- The owl is drawn from SwiftUI vector shapes (`Shape`, `Canvas`), so eyes, pupils and eyelids animate independently.
- Each exercise names an **animation script**: a short sequence of poses (for example "pupils to far left, hold, far right, hold"). The character renders whatever pose it is given. This keeps exercises and characters independent: a new character implements `Character`, a new exercise adds a script.
- **Reduce Motion is not honoured.** Decided 2026-10-26 by the product owner: the owl always plays the full animation. Revisit if a user asks (the hook would be `\.accessibilityReduceMotion` in `AnimatedOwlView`).
- v1 characters are compiled in. A runtime plugin system is not built; the `Character` protocol keeps the door open.

### Owl artwork

**Existing art (reviewed).** `owl.png` from the eye-hoot repo is a generic teal clipart owl. The SVG in `index.template.ejs` is already split into named parts (body, stomach, sclera, nose, iris, pupil, eye shine, wings, feet), which is useful as a model for how to structure the new owl. But you recall it came from free clipart, and I could not confirm its license. **Do not ship it.** Treat it only as a structural reference.

**New owl: drawn from scratch as original vector art, as layered parts that animate independently.** Original artwork also avoids any licensing question and lets the app be MIT-licensed cleanly.

| Part | Movement |
|---|---|
| Pupils / irises | Look in any direction (side to side, up and down, circles, far away). The core requirement. |
| Eye shine highlights | Stay fixed relative to the eye, giving the "alive" look. |
| Eyelids | Blink: full close, squeeze, slow blink. Needed for the blink exercise. Also idle blinks. |
| Eyebrows / brow feathers | Raise, lower, furrow: encourages, concentrates, looks pleased. |
| Head | Small tilt and bob. |
| Wings | Flap lightly, raise, tuck, one wing up to wave goodbye. |
| Feet | Shift weight, tap, hop in place (stand-up-and-walk exercise). |
| Body | Gentle breathing (slow scale), fluff at the end of a break. |
| Face-cupping wings | The palming exercise. Wings cover the eyes. |
| Idle behaviours | Small random blinks, a head tilt, a feather ruffle, so the owl is never frozen. |

**Approach:**
1. Draw the owl as SwiftUI shapes in code (parametric: each part takes position, rotation and scale). This keeps it crisp at any size, tiny in file size and scriptable from the animation scripts. The agent can generate and refine the shapes, and you review screenshots and short screen recordings.
2. If hand-coded shapes look too stiff, alternative: have the owl designed as an SVG with named groups (in an editor such as Figma or Inkscape), then convert the paths into SwiftUI shapes. The part list above becomes the naming contract. I would try the code route first.
3. Look: friendly, round, big expressive eyes, soft colours that work on a dimmed background, a restrained palette. Distinct from other owl mascots (for example avoid a green owl).
4. Pose sheet for review before animating: neutral, happy, concentrating, eyes closed, wing-cover, wave. You approve the look before we build the animations.

Quality bar: this is the most important place to show polish. Plan a review round with you after the first static owl, and another after the animations.

### Settings and "exclude exercises"

- Settings are a single `Codable` struct stored in `UserDefaults` as JSON, behind a `SettingsStore` protocol.
- Exclusions are stored as a set of disabled exercise ids, so exercises added in a later version default to enabled.
- No per-exercise break-type choice (decided 2026-10-26): "Stand up and walk" is the only long-break exercise. Users can only switch exercises off.

### Multi-display behaviour

- Dim **all** screens. Show the character on the screen chosen by setting: screen with the pointer (default), main display, a specific display, or all.
- If the chosen display disappears, fall back to the default.
- Observe `NSApplication.didChangeScreenParametersNotification` to rebuild overlay windows during a break.

### Other platform notes

- **Menu bar only:** `LSUIElement = YES` hides the Dock icon. Reopening the app from Applications shows the settings window (a fallback if the menu bar icon is hidden by the notch).
- **Launch at login:** `SMAppService.mainApp`, off by default, offered during first-run setup.
- **Idle detection:** `CGEventSource.secondsSinceLastEventType`. I believe this needs no special permission, to be confirmed in the Phase 1 spike.
- **Global pause shortcut:** later phase. Likely a small third-party package; evaluate then.
- **Notifications:** only used for the heads-up. Requires the user to allow them, per the brainstorm.

## 3. Repository layout

```
eye-break/
├── README.md
├── LICENSE                      MIT
├── project.yml                  XcodeGen project definition
├── Package.swift                workspace-level helper (optional)
├── App/                         app target (thin)
│   ├── GazelingApp.swift        @main, MenuBarExtra, Settings scene
│   ├── Views/                   menu, settings, About, onboarding
│   ├── Overlay/                 OverlayPresenter, break window
│   ├── Characters/              Owl.swift and future characters
│   ├── Adapters/                real Clock, IdleMonitor, Notifier, SoundPlayer, ...
│   └── Resources/
│       ├── Assets.xcassets      app icon, menu bar template icon
│       ├── Localizable.xcstrings
│       ├── exercises.json
│       └── Audio/               chime, voice clips
├── Packages/
│   └── GazelingKit/             domain core, no UI imports
│       ├── Package.swift
│       ├── Sources/GazelingKit/
│       └── Tests/GazelingKitTests/
├── AppTests/                    tests that need the app target
├── docs/
│   ├── architecture.md          engineering docs
│   ├── user-guide.md            end-user docs
│   ├── research.md              copied or linked from the research doc
│   └── development.md          setup, build, test, release commands
├── scripts/                     small shell scripts (build, test, run)
└── scratch/                     globally gitignored, outside App/ on purpose
```

Notes:
- `scratch/` stays at the repo root, outside `App/`, so Xcode does not include it in the build.
- `.gitignore` must cover `xcuserdata/`, `DerivedData/`, `.build/`, and the generated `*.xcodeproj` (it is regenerated from `project.yml`).
- The planning documents in this folder move into `docs/planning/` when the repo is created.
- This folder is not currently a git repository; the first step creates one.

## 4. Tooling and commands

Installed and confirmed on this Mac: Xcode 27.1, Swift 6.4, macOS 26.7.1. Not installed: XcodeGen.

### One-time setup

```bash
brew install xcodegen                       # project generator
code --install-extension swiftlang.swift-vscode
brew install xcode-build-server             # optional: VS Code completion for the Xcode project
```

### Everyday commands

```bash
# Generate the Xcode project from project.yml (run after changing project.yml or adding files)
xcodegen generate

# Build the app
xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -destination 'platform=macOS' build

# Run the unit tests
swift test --package-path Packages/GazelingKit                      # fast, domain only
xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -destination 'platform=macOS' test   # everything

# Launch the built app
open "$(xcodebuild -project Gazeling.xcodeproj -scheme Gazeling -showBuildSettings | awk '/ BUILT_PRODUCTS_DIR/{print $3}')/Gazeling.app"

# Format
swift format --in-place --recursive App Packages
```

`scripts/build.sh`, `scripts/test.sh` and `scripts/run.sh` wrap these so the agent and you use one command each. Terminology: "build" compiles, "run" or "launch" starts the app, "test" runs the test suite, "lint" checks style.

### Debug aids built into the app

Because waiting 20 minutes to see a break is impractical:
- Launch arguments such as `--break-now`, `--short-interval 10s`, `--long-interval 60s`, `--fake-screens 2` (debug builds only).
- A hidden "Start break now" item in the menu bar in debug builds.

## 5. Signing and distribution (plain-language)

**What signing is.** Signing attaches a cryptographic identity to the app so macOS knows who built it and that it was not altered. macOS Gatekeeper checks it when someone opens an app downloaded from the internet.

**Three levels, from easiest to most official:**

| Level | Cost | What works |
|---|---|---|
| **Local build, ad-hoc or "Personal Team" signing** (your Apple ID in Xcode) | Free | Runs on your own Mac. Enough for development. |
| **Free distribution, unsigned or personal-signed** | Free | Others can run it but macOS shows a warning; they must right-click → Open (or allow it in System Settings → Privacy & Security). Fine for a few technical users. |
| **Developer ID signed and notarized** | Apple Developer Program, about US$99 per year | No warnings for downloaders. Required for a smooth public release. |

**Recommendation:** develop with local signing. Release v1 on GitHub Releases as a zipped app with a clear note about the Gatekeeper warning. Decide on the paid program only if people actually want it. Alternatively, users comfortable with Terminal can build from source (documented in `docs/development.md`).

### Keeping the paid options open (Developer ID and the Mac App Store)

Decision: free GitHub release now, but do not design anything that blocks the paid routes later. Both paid routes need the **Apple Developer Program** (about US$99 per year, enrolled with your Apple ID). As far as I know, there are two separate things you could do with it:

| Route | What it is | What it needs |
|---|---|---|
| **Developer ID + notarization** | You still distribute the app yourself (GitHub, your site), but it is signed with an Apple-issued certificate and checked by Apple's notarization service. Downloaders get no warning. | A Developer ID certificate. `xcodebuild` plus `notarytool` can do it from the command line, so the agent can script it. |
| **Mac App Store** | Apple hosts and distributes the app. Users find it in the App Store. | A paid account, an App Store Connect listing (screenshots, description, privacy answers), App Review, and the **App Sandbox** turned on. |

**What we do now so either route stays easy:**
1. **Enable the App Sandbox from the start** (an entitlements file in the project). It is mandatory for the Mac App Store and harmless for GitHub builds. Turning it on late can break things, so the Phase 1 spikes run with it already on. Idle detection, notifications, audio and launch-at-login are all expected to work inside the sandbox, but this is verified in Phase 1, not assumed.
2. **Use only public, supported Apple APIs.** No private APIs, no accessibility-permission tricks, no screen recording.
3. **Keep the bundle id, version and build numbers clean** (`CFBundleShortVersionString`, `CFBundleVersion`).
4. **Provide a privacy statement** (the app collects nothing, makes no network calls). This helps both routes and is required for App Store review.
5. **Keep the signing identity and team id out of the code.** They live in `project.yml` and an untracked local override, so switching from Personal Team to a paid team is a settings change, not a code change.
6. **Document the steps** to go paid in `docs/development.md` once we have verified them, including archiving and notarizing.

Unknowns to confirm when you decide: the exact current price and enrollment steps, App Review rules that might affect a menu bar app that dims all screens (full-screen overlays above other apps could draw scrutiny, so this is worth a Phase 1 note), and trademark clearance of the final name (see `names.md`).

**Needs checking in Phase 1:** whether notifications and launch-at-login work reliably under ad-hoc or Personal Team signing. If notifications fail, Personal Team signing is the fix, and Xcode needs your Apple ID (already added per the earlier chat).

**Hand-holding step in Xcode (only if needed):** Xcode → Settings → Accounts → select your Apple ID → note the **Team ID** shown. It goes into `project.yml` as `DEVELOPMENT_TEAM`. The agent will give exact click-by-click instructions at that point.

## 6. Phases

Each phase ends with a verifiable check.

**Phase 0: Repository and scaffold**
1. Create the repo folder, `git init`, `.gitignore`, MIT `LICENSE`, README stub; move planning docs into `docs/planning/`.
2. Install XcodeGen. Write `project.yml` for a menu-bar app (`LSUIElement`, bundle id, macOS 15 deployment target, Swift 6, App Sandbox entitlements, localization settings).
3. Create the `GazelingKit` package with one placeholder type and one passing test.
4. Add `scripts/build.sh`, `scripts/test.sh`, `scripts/run.sh`.
- *Verify:* `scripts/build.sh` succeeds; `scripts/test.sh` passes; `scripts/run.sh` shows a menu bar icon with a Quit item and no Dock icon.

**Phase 1: Platform spikes (answer the risky questions first)**
1. Overlay: dim every screen with a centered placeholder, dismiss with Esc, over a full-screen app and on a second monitor.
2. Heads-up notification: request permission and post one.
3. Idle detection and sleep/wake events.
4. Run all three with the App Sandbox enabled.
- *Verify:* each spike works under the signing mode we plan to use; findings recorded in `docs/architecture.md`.

**Phase 2: Domain core (all test-driven)**
1. `Exercise`, `ExerciseCatalog`, `exercises.json` with the agreed set.
2. `Settings` with the defaults from `research.md`.
3. `ExercisePicker` (rotation, exclusions, empty pool).
4. `BreakScheduler` state machine with a fake clock: short and long break timing, long break replacing a short one, idle reset, pause, postpone, skip.
- *Verify:* `swift test` passes, covering each rule above, including "all exercises excluded for a break type turns that type off".

**Phase 3: Working breaks with a placeholder character**
1. Wire scheduler to overlay, notifier and sound. Menu bar: pause options, skip next, start now (debug), quit.
2. Text instructions and countdown on the overlay; chime at the end.
- *Verify:* with short debug intervals, a full cycle of heads-up → dim → exercise text → end chime → resume works on a single and a dual-display setup.

**Phase 4: The owl**
1. Draw the owl in SwiftUI as independently animatable parts (see Owl artwork). First produce a static pose sheet for your approval, then implement poses, idle behaviours and the animation scripts for every exercise in the set.
2. ~~Reduce Motion fallback~~ Skipped by decision (see section 2). Iterate with `make pose-sheet`, `make animation-strips` and `make inspect`.
- *Verify:* each exercise's animation reviewed on screen by you; screenshots saved in `docs/`.

**Phase 5: Settings and polish**
1. Settings window: intervals, durations, per-exercise on/off and break tags, display choice, sounds, launch at login.
2. First-run onboarding: notification permission, launch-at-login choice.
3. Native look (system fonts, materials, standard controls). The menu bar icon and app icon moved to Phase 9 (branding); until then the menu uses the system `eye` symbol.
4. Reopen-from-Applications shows the settings window.
- *Verify:* every setting changes behaviour and survives relaunch; a keyboard-only and VoiceOver pass.

**Phase 6: Sound and voice**
1. Generate voice clips with Kokoro for each exercise (English); bundle them; setting to turn voice off.
- *Verify:* clips play at the right moment and respect the sound settings.

**Phase 7: Docs and release**
1. About / "Why this works" screen: general summary and key references, per `research.md`'s final decision.
2. `docs/architecture.md`, `docs/user-guide.md`, `docs/development.md`.
3. GitHub Actions workflow: build and test on a macOS runner.
4. Release build, zip, GitHub Release with the Gatekeeper note.
- *Verify:* a fresh clone builds and tests following only `docs/development.md`.

**Phase 8 (optional, nice to have): choose your own sound**
Added 2026-10-26 at the product owner's request. Not needed for v1; do after Phases 5 and 6.
1. Settings: separate sound choice for break start and break end (`Settings` gets two new fields with defaults, so saved settings keep loading). Choices: our bundled chime (the default), any of the macOS system sounds (the names in `/System/Library/Sounds`, played with `NSSound(named:)`), or none.
2. Settings window: a picker for each, with a button to preview the sound.
3. Open question: letting users pick their own audio file needs the `com.apple.security.files.user-selected.read-only` sandbox entitlement and a file picker. Decide then whether it is worth it; the system-sound list may be enough.
- *Verify:* each choice plays at the right moment, "none" is silent, the preview works, and the choice survives relaunch. Confirm that system sounds play inside the App Sandbox (the placeholder Tink and Glass already do).

**Phase 9: branding (do any time after Phase 4; before the public release)**
Added 2026-10-26 at the product owner's request. They are not a designer or marketer, so this phase starts with proposals from the agent and the product owner picks. Nothing is decided yet.
1. **App icon**, based on the purple Dusk owl. Needs the full set of sizes (16 to 1024 px) in `Assets.xcassets`. It also appears in notifications (macOS uses the app icon there) and in Finder and the About screen.
2. **Menu bar icon:** a monochrome template image (simple owl or eye silhouette) that works in light and dark menu bars, replacing the system `eye` symbol.
3. **README and GitHub presence:** a header image, a short description and tagline, screenshots or a short screen recording of a break, and a social preview image for the repository.
4. **Release assets:** screenshots for the GitHub Release page. Optionally a simple landing page.
5. Decide the look (flat owl face only versus full body, background colour for the app icon) and the tagline. The name Gazeling is already decided; trademark check is still open (section "Open decisions").
- *Verify:* the icon looks right at 16 px and 1024 px, in light and dark mode, and in a notification; the README renders well on GitHub.

**Later:** global pause shortcut, additional characters, other languages, voice clips per language, meeting/screen-share detection.

## 7. Internationalization

- All user-visible text uses String Catalog keys (`String(localized:)` and SwiftUI `Text("key")`). No hardcoded strings in views.
- Exercise names and instructions are catalog keys referenced from `exercises.json`.
- Dates, numbers and durations use system formatters.
- Voice clips are named `<exercise-id>.<language>.m4a` so other languages can be added alongside.
- English is the only shipped language in v1.

## 8. Quality and accessibility

- Unit tests for all domain logic. No timers or real clocks in tests.
- Manual checklist (in `docs/development.md`) for what automation cannot see: dimming across screens, Spaces, full-screen apps, plugging a monitor in and out mid-break.
- VoiceOver labels on controls, and sufficient contrast on the overlay. (Reduce Motion is deliberately not supported; see section 2.)
- Calm defaults: no sound surprises, always a way to skip.

## Keeping up with new macOS versions

Goal: updating for each new macOS release should be routine, not a project.

- **Support window:** the current macOS and the one before (now Tahoe 26 and Sequoia 15). When a new release ships, move the minimum up by one. Dropping the oldest version is a one-line change plus removal of any compatibility checks.
- **Build against the newest SDK, deploy to the older one.** Set `MACOSX_DEPLOYMENT_TARGET = 15.0` in `project.yml`, build with the latest Xcode.
- **Fence off newer-OS features.** Use `if #available(macOS 26, *)` only inside the platform adapters and visual-style helpers, never in the domain core. Each use gets a comment stating the minimum version and what the fallback is.
- **Prefer system styling** (standard controls, materials, system fonts) so the app picks up new OS looks automatically.
- **Keep dependencies few.** Fewer third-party packages means fewer things break on a new release.
- **Test early:** a GitHub Actions job builds and tests on the newest macOS runner available. Try each new Xcode beta when it appears. The unit tests in `GazelingKit` do not depend on the OS, so most regressions would show up only in overlay, notification and idle adapters, which the manual checklist covers.
- **Read Apple's release notes** for each major release for changes to window levels, notification behaviour and menu bar apps.

## Open decisions

1. **Trademark check.** The name is decided. Before the first public release, run **Gazeling** through the USPTO trademark search (classes 9 and 42) yourself; my checks were web searches only. Bundle id: `com.danielabar.gazeling`.
2. **Meeting and screen-share handling.** Deferred. Flagged in the earlier chat as a chance to beat EyeLeo.
3. **Going paid.** Not now. The plan keeps both the Developer ID and Mac App Store routes open (section 5).

Settled: app name **Gazeling**; minimum macOS 15 with Tahoe 26 as the build target; new vector owl drawn from scratch and animated per part; free GitHub release for v1.
