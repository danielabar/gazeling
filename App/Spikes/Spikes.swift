import AppKit
import CoreGraphics
import os
@preconcurrency import UserNotifications

/// Phase 1 throwaway spikes. Each logs its result with os.Logger (subsystem com.danielabar.gazeling; see docs/development.md for how to read it) so results can be read from the terminal.
/// Replaced by real adapters in Phase 3.
@MainActor
enum Spikes {
    nonisolated private static let logger = Logger(subsystem: "com.danielabar.gazeling", category: "spike")

    nonisolated static func log(_ message: String) {
        logger.notice("\(message, privacy: .public)")
    }

    private static var overlayWindows: [NSWindow] = []

    // MARK: Overlay

    private final class OverlayWindow: NSWindow {
        override var canBecomeKey: Bool { true }

        override func keyDown(with event: NSEvent) {
            if event.keyCode == 53 { Spikes.hideOverlay() }  // Esc
        }
    }

    static func showOverlay() {
        hideOverlay()
        for screen in NSScreen.screens {
            // Create without `screen:` because that makes contentRect relative to the screen, not global.
            let window = OverlayWindow(
                contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false)
            window.setFrame(screen.frame, display: true)
            window.level = .screenSaver
            window.backgroundColor = NSColor.black.withAlphaComponent(0.7)
            window.isOpaque = false
            window.hasShadow = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            let label = NSTextField(labelWithString: "Gazeling spike: press Esc")
            label.font = .systemFont(ofSize: 32)
            label.textColor = .white
            label.sizeToFit()
            label.frame.origin = CGPoint(
                x: (screen.frame.width - label.frame.width) / 2,
                y: (screen.frame.height - label.frame.height) / 2)
            window.contentView?.addSubview(label)
            window.makeKeyAndOrderFront(nil)
            overlayWindows.append(window)
        }
        NSApp.activate()
        log("overlay: shown on \(overlayWindows.count) screen(s)")
    }

    static func hideOverlay() {
        overlayWindows.forEach { $0.orderOut(nil) }
        overlayWindows.removeAll()
    }

    // MARK: Notification

    /// Without a delegate, macOS hides banners while the posting app counts as frontmost,
    /// which a menu bar app often does right after a menu click.
    private final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
        func userNotificationCenter(
            _ center: UNUserNotificationCenter, willPresent notification: UNNotification
        ) async -> UNNotificationPresentationOptions {
            [.banner, .sound]
        }
    }

    private static let notificationDelegate = NotificationDelegate()

    static func postNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = notificationDelegate
        center.getNotificationSettings { settings in
            log("notification: status before request=\(settings.authorizationStatus.rawValue) (0 notDetermined, 1 denied, 2 authorized)")
        }
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            log("notification: permission granted=\(granted) error=\(String(describing: error))")
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Gazeling"
            content.body = "Eye break in 30 seconds"
            let request = UNNotificationRequest(identifier: "spike", content: content, trigger: nil)
            center.add(request) { error in
                log("notification: posted error=\(String(describing: error))")
            }
        }
    }

    // MARK: Idle and sleep/wake

    static func idleSeconds() -> Double {
        // anyInputEventType is not exposed in Swift; ~0 means any event type.
        CGEventSource.secondsSinceLastEventType(
            .combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
    }

    static func printIdle() {
        log("idle: \(idleSeconds()) seconds since last input")
    }

    static func observeSleepWake() {
        let center = NSWorkspace.shared.notificationCenter
        for name in [
            NSWorkspace.willSleepNotification, NSWorkspace.didWakeNotification,
            NSWorkspace.screensDidSleepNotification, NSWorkspace.screensDidWakeNotification,
            NSWorkspace.sessionDidResignActiveNotification, NSWorkspace.sessionDidBecomeActiveNotification,
        ] {
            center.addObserver(forName: name, object: nil, queue: .main) { note in
                log("power: \(note.name.rawValue)")
            }
        }
    }

    // MARK: Launch arguments (for terminal testing)

    static func runLaunchArguments() {
        let args = CommandLine.arguments
        if args.contains("--spike-overlay") { showOverlay() }
        if args.contains("--spike-notify") { postNotification() }
        if args.contains("--spike-idle") { printIdle() }
    }
}
