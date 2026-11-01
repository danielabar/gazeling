import Observation

/// What the "start at login" toggle shows and does. Holds no setting of its own: `status` is a copy
/// of what macOS reports, refreshed with `refresh()`.
@MainActor
@Observable
public final class LaunchAtLoginModel {
    public private(set) var status: LaunchAtLoginStatus
    public private(set) var errorMessage: String?
    @ObservationIgnored private let adapter: LaunchAtLogin

    public init(adapter: LaunchAtLogin) {
        self.adapter = adapter
        status = adapter.status
    }

    /// The toggle is on when registered, even if macOS still waits for the user's approval.
    public var isOn: Bool { status != .off }
    public var needsApproval: Bool { status == .requiresApproval }

    public func refresh() {
        status = adapter.status
    }

    public func setEnabled(_ enabled: Bool) {
        refresh()
        guard enabled != isOn else { return }
        do {
            if enabled {
                try adapter.register()
            } else {
                try adapter.unregister()
            }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        refresh()
    }

    public func openSystemSettings() {
        adapter.openSystemSettings()
    }
}
