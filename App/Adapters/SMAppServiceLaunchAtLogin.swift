import GazelingKit
import ServiceManagement

/// Launch at login through `SMAppService`. See the "Launch at login" row in `docs/architecture.md`.
@MainActor
struct SMAppServiceLaunchAtLogin: LaunchAtLogin {
    var status: LaunchAtLoginStatus {
        switch SMAppService.mainApp.status {
        case .enabled: .on
        case .requiresApproval: .requiresApproval
        // A build that was never registered reports .notFound, so it counts as off.
        case .notRegistered, .notFound: .off
        @unknown default: .off
        }
    }

    func register() throws {
        try SMAppService.mainApp.register()
    }

    func unregister() throws {
        try SMAppService.mainApp.unregister()
    }

    func openSystemSettings() {
        SMAppService.openSystemSettingsLoginItems()
    }
}
