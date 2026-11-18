import AppKit
import GazelingKit
import SwiftUI

/// A borderless window over every screen. Dims all screens and shows the break on the chosen screens.
/// Screens without the break let clicks through, so the user can still pause a video there.
/// Rebuilds the windows if screens are plugged in or out mid-break.
@MainActor
final class OverlayWindowPresenter: OverlayPresenter {
    private var windows: [NSWindow] = []
    private var current: (session: BreakSession, screens: OverlayScreen, onSkip: @MainActor () -> Void)?
    private var screenObserver: NSObjectProtocol?
    private var keyMonitor: Any?

    /// A non-activating panel can receive key presses without Gazeling becoming the active app.
    /// That matters because a break starts while another app is in front, and macOS does not let
    /// a background app take over activation, so Esc would do nothing until the user clicked.
    private final class OverlayWindow: NSPanel {
        override var canBecomeKey: Bool { true }
    }

    func show(session: BreakSession, contentScreens: OverlayScreen, onSkip: @escaping @MainActor () -> Void) {
        current = (session, contentScreens, onSkip)
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.rebuild() }
        }
        // The SwiftUI content can swallow key presses before the window sees them, so watch Esc app-wide.
        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard event.keyCode == 53 else { return event }
            onSkip()
            return nil
        }
        rebuild()
    }

    func hide() {
        if let keyMonitor { NSEvent.removeMonitor(keyMonitor) }
        keyMonitor = nil
        if let screenObserver { NotificationCenter.default.removeObserver(screenObserver) }
        screenObserver = nil
        current = nil
        closeWindows()
    }

    private func closeWindows() {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }

    private func rebuild() {
        closeWindows()
        guard let (session, screens, onSkip) = current else { return }
        let contentScreens = screensShowingContent(screens)
        var contentWindow: NSWindow?
        for screen in NSScreen.screens {
            // No `screen:` argument: it would make the frame relative to that screen.
            let window = OverlayWindow(
                contentRect: .zero, styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
            window.setFrame(screen.frame, display: true)
            window.level = .screenSaver
            window.backgroundColor = NSColor.black.withAlphaComponent(0.75)
            window.isOpaque = false
            window.hasShadow = false
            window.isReleasedWhenClosed = false
            // Panels hide when their app is inactive by default, and Gazeling is inactive during a break.
            window.hidesOnDeactivate = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            if contentScreens.contains(screen) {
                let host = NSHostingView(rootView: BreakOverlayView(session: session, onSkip: onSkip))
                // By default the hosting view resizes the window to fit the SwiftUI content.
                host.sizingOptions = []
                window.contentView = host
                window.setFrame(screen.frame, display: true)
            } else {
                // Dimmed only: clicks reach the app underneath (for example to pause a video).
                window.ignoresMouseEvents = true
            }
            window.orderFrontRegardless()
            windows.append(window)
            if contentScreens.contains(screen), contentWindow == nil { contentWindow = window }
        }
        // Make the window with the break content key last, so it receives key presses.
        contentWindow?.makeKey()
        NSApp.activate()
    }

    /// Every screen is dimmed; these are the ones that also show the owl.
    /// The first screen is the one with the menu bar. `NSScreen.main` is the one with keyboard focus.
    private func screensShowingContent(_ choice: OverlayScreen) -> [NSScreen] {
        let screens = NSScreen.screens
        let pointer = NSEvent.mouseLocation
        let indexes = choice.screensShowingContent(
            count: screens.count,
            pointer: screens.firstIndex { $0.frame.contains(pointer) },
            builtIn: screens.firstIndex(where: isBuiltIn))
        return indexes.map { screens[$0] }
    }

    /// True for a laptop's own screen (and an iMac's), false for an external monitor.
    private func isBuiltIn(_ screen: NSScreen) -> Bool {
        guard let id = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
        else { return false }
        return CGDisplayIsBuiltin(id) != 0
    }
}
