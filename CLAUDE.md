# Gazeling

A native macOS menu bar app that reminds heavy computer users to take eye breaks. During a break it dims all screens and shows an animated character (an owl first, more characters later) guiding eye exercises. Free, open source, MIT.

## Status

See `docs/worklog.md` for current phase and status.

## Read these first

**`docs/worklog.md` holds current status, what is done and next, problems and deviations from the plan. Read it first and update it at the end of every session.**

| File | What it holds |
|---|---|
| `docs/planning/plan.md` | Architecture, repo layout, tooling and commands, signing, phases 0 to 7. **The main document.** |
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
- All exercises in `research.md` ship. Users can turn any exercise off. Defaults: short break every 20 min for 20 s, long break every 60 min for 5 min.
- The owl is original vector art drawn in code, as separately animated parts. The owl from the old eye-hoot repo is of unknown license and must not be used. The user approves a static pose sheet before any animation work.
- String Catalogs for all user-visible text from day one. English only for now.
- Bundle id `com.danielabar.gazeling`.

## Working with the product owner

- They are the product manager, a web developer (Rails, HTML/CSS/JS) with no native Mac experience. Explain Apple-specific terms briefly. Do the coding and tooling yourself.
- Drive everything from the terminal with `xcodebuild`, `swift` and the scripts in `scripts/`. Only ask them to use Xcode when unavoidable, and then give click-by-click instructions.
- Ask before installing software (for example `brew install xcodegen`) or doing anything outside this folder.
- Prefer maintainable, idiomatic code over clever code. Document as you go (engineering docs and end-user docs).
- Keep claims about eye health modest. No "clinically proven".

## Toolchain on this Mac (checked 2026-10-26)

Xcode 27.1, Swift 6.4, macOS 26.7.1. Not installed yet: XcodeGen.

## Not yet verified

Whether idle detection, notifications and launch-at-login work inside the App Sandbox. This is the point of the Phase 1 spikes.

## Check logs

```bash
/usr/bin/log show --last 5m --predicate 'subsystem == "com.danielabar.gazeling"' --style compact
```
