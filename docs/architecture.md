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
