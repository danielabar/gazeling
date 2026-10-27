# Gazeling

A native macOS menu bar app that reminds heavy computer users to take eye breaks. During a break it dims all screens and shows an animated character (an owl first, more characters later) guiding eye exercises. Free, open source, MIT.

## Status

Phases 0 to 4 are done and Phase 5 (settings and polish) is part way. **`docs/worklog.md` says exactly where we stopped, what to do next and the pitfalls to avoid.**

## Read these first

**`docs/worklog.md` holds current status, what is done and next, problems and deviations from the plan. Read it first and update it at the end of every session.**

| File | What it holds |
|---|---|
| `docs/planning/plan.md` | Architecture, repo layout, tooling and commands, signing, phases 0 to 9. **The main document.** |
| `docs/architecture.md` | What was verified in practice: platform findings, domain rules, the owl, settings rules. |
| `docs/development.md` | Build, test, run, logs and debug options. `make help` lists the commands. |
| `docs/planning/research.md` | Evidence review, the final exercise list, break schedule defaults and configuration rules. |
| `docs/planning/names.md` | Name decision (Gazeling) and the trademark checks. |
| `scratch/stream-of-consciousness.md` | The product owner's original requirements. |
| `scratch/eye-break-mac-app-conversation.md` | Earlier planning chat (tech choice, menu bar behaviour, multi-monitor, Xcode setup). |

`scratch/` is globally gitignored: brainstorm history only, not part of the project.

## Decisions already made (do not re-open without asking)

- Swift 6, SwiftUI, AppKit only for the overlay. Minimum macOS 15, built and tested on macOS 26 (Tahoe).
- MVVM-style with a plain-Swift domain core in a local package (`GazelingKit`). Platform services sit behind protocols.
- XcodeGen (`project.yml`) generates the Xcode project. Swift Testing for tests. `swift format` for formatting.
- App Sandbox on from the start, to keep the Mac App Store route open. Free GitHub release for v1.
- All exercises in `research.md` ship. Users can turn any exercise off (but not the last remaining break). Only "Stand up and walk" is a long break; the other eight are short breaks, and users cannot change that. Defaults: short break every 20 min for 20 s, long break every 60 min for 5 min.
- Reduce Motion is deliberately not supported.
- The owl is original vector art drawn in code, as separately animated parts (the "Dusk" purple owl, approved). The owl from the old eye-hoot repo is of unknown license and must not be used.
- All user-visible text goes through the localization APIs (`Text("…")`, `String(localized:)`). English only for now. See the worklog for the open question about filling `Localizable.xcstrings`.
- Bundle id `com.danielabar.gazeling`.

## Working with the product owner

- They are the product manager, a web developer (Rails, HTML/CSS/JS) with no native Mac experience. Explain Apple-specific terms briefly. Do the coding and tooling yourself.
- Drive everything from the terminal with `xcodebuild`, `swift` and the scripts in `scripts/`. Only ask them to use Xcode when unavoidable, and then give click-by-click instructions.
- Ask before installing software (for example `brew install xcodegen`) or doing anything outside this folder.
- Prefer maintainable, idiomatic code over clever code. Document as you go (engineering docs and end-user docs).
- Keep claims about eye health modest. No "clinically proven".
- They sometimes ask a question only ("just a question", "don't change anything"): then answer and change nothing. Commit only when asked.
- You cannot see the screen or press keys. Give them copy-paste test steps with expected results (guides live in `scratch/manual-verification/`, which is gitignored).

## Toolchain on this Mac (checked 2026-10-26)

Xcode 27.1, Swift 6.4, macOS 26.7.1. XcodeGen 2.46.0 is installed (Homebrew).

## Not yet verified

Launch-at-login inside the App Sandbox (Phase 5 slice 4). Idle detection, sleep/wake events, notifications and the overlay were verified in the sandbox in Phase 1. Anything involving a second monitor has not been tested (the product owner has a laptop only for now).

## Check logs

```bash
/usr/bin/log show --last 5m --predicate 'subsystem == "com.danielabar.gazeling"' --style compact
```
