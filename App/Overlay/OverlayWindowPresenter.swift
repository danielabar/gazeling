import AppKit
import GazelingKit
import SwiftUI

/// A borderless window over every screen. Dims all screens and shows the break on the screen with
/// the pointer. Rebuilds the windows if screens are plugged in or out mid-break.
@MainActor
final class OverlayWindowPresenter: OverlayPresenter {
    private var windows: [NSWindow] = []
    private var current: (session: BreakSession, onSkip: @MainActor () -> Void)?
    private var screenObserver: NSObjectProtocol?
    private var keyMonitor: Any?

    /// A non-activating panel can receive key presses without Gazeling becoming the active app.
    /// That matters because a break starts while another app is in front, and macOS does not let
    /// a background app take over activation, so Esc would do nothing until the user clicked.
    private final class OverlayWindow: NSPanel {
        override var canBecomeKey: Bool { true }
    }

    func show(session: BreakSession, onSkip: @escaping @MainActor () -> Void) {
        current = (session, onSkip)
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
        guard let (session, onSkip) = current else { return }
        let contentScreen = screenWithPointer()
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
            if screen == contentScreen {
                let host = NSHostingView(rootView: BreakOverlayView(session: session, onSkip: onSkip))
                // By default the hosting view resizes the window to fit the SwiftUI content.
                host.sizingOptions = []
                window.contentView = host
                window.setFrame(screen.frame, display: true)
            }
            window.orderFrontRegardless()
            windows.append(window)
            if screen == contentScreen { contentWindow = window }
        }
        // Make the window with the break content key last, so it receives key presses.
        contentWindow?.makeKey()
        NSApp.activate()
    }

    private func screenWithPointer() -> NSScreen? {
        let pointer = NSEvent.mouseLocation
        return NSScreen.screens.first { $0.frame.contains(pointer) } ?? NSScreen.main
    }
}
