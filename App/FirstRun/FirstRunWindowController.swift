import AppKit
import GazelingKit
import SwiftUI

/// Owns the first-run window. Closing it in any way, including the red button, counts as done.
@MainActor
final class FirstRunWindowController: NSObject, NSWindowDelegate {
    private var window: NSWindow?
    private let model: FirstRunModel

    init(model: FirstRunModel) {
        self.model = model
    }

    func showIfNeeded() {
        if model.isNeeded { show() }
    }

    /// For the debug menu: forget that setup was done, then show it.
    func showAgain() {
        model.reset()
        show()
    }

    func show() {
        if window == nil {
            let window = NSWindow(
                contentRect: .zero, styleMask: [.titled, .closable], backing: .buffered, defer: false)
            window.title = String(localized: "Welcome to Gazeling")
            window.isReleasedWhenClosed = false
            window.delegate = self
            window.contentView = NSHostingView(
                rootView: FirstRunView(model: model, onDone: { [weak window] in window?.close() }))
            window.center()
            self.window = window
        }
        window?.makeKeyAndOrderFront(nil)
        // macOS may refuse to activate the app when another app is in front (for example System
        // Settings after "Open Anyway"), which leaves the window hidden behind it.
        window?.orderFrontRegardless()
        NSApp.activate()
    }

    func windowWillClose(_ notification: Notification) {
        model.complete()
    }
}
