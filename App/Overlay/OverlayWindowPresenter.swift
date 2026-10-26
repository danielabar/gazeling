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

    private final class OverlayWindow: NSWindow {
        var onEscape: (() -> Void)?
        override var canBecomeKey: Bool { true }
        override func keyDown(with event: NSEvent) {
            if event.keyCode == 53 { onEscape?() } else { super.keyDown(with: event) }
        }
    }

    func show(session: BreakSession, onSkip: @escaping @MainActor () -> Void) {
        current = (session, onSkip)
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.rebuild() }
        }
        rebuild()
    }

    func hide() {
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
        for screen in NSScreen.screens {
            // No `screen:` argument: it would make the frame relative to that screen.
            let window = OverlayWindow(
                contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false)
            window.setFrame(screen.frame, display: true)
            window.level = .screenSaver
            window.backgroundColor = NSColor.black.withAlphaComponent(0.75)
            window.isOpaque = false
            window.hasShadow = false
            window.isReleasedWhenClosed = false
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary]
            window.onEscape = { onSkip() }
            if screen == contentScreen {
                window.contentView = NSHostingView(rootView: BreakOverlayView(session: session, onSkip: onSkip))
            }
            window.makeKeyAndOrderFront(nil)
            windows.append(window)
        }
        NSApp.activate()
    }

    private func screenWithPointer() -> NSScreen? {
        let pointer = NSEvent.mouseLocation
        return NSScreen.screens.first { $0.frame.contains(pointer) } ?? NSScreen.main
    }
}
