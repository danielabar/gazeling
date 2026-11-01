#if DEBUG
    import OSLog
    import ServiceManagement

    /// Debug-only spike: tries launch at login inside the App Sandbox and logs what macOS says.
    /// Read the result with `make logs`. Review for removal in the debug cleanup (see worklog).
    @MainActor
    enum LaunchAtLoginSpike {
        private static let logger = Logger(subsystem: "com.danielabar.gazeling", category: "launch-at-login-spike")

        static func logStatus() {
            logger.notice("status = \(describe(SMAppService.mainApp.status), privacy: .public)")
        }

        static func register() {
            logger.notice(
                "register() called, status before = \(describe(SMAppService.mainApp.status), privacy: .public)")
            do {
                try SMAppService.mainApp.register()
                logger.notice("register() succeeded")
            } catch {
                logger.error("register() failed: \(error.localizedDescription, privacy: .public)")
            }
            logStatus()
        }

        static func unregister() {
            logger.notice(
                "unregister() called, status before = \(describe(SMAppService.mainApp.status), privacy: .public)")
            do {
                try SMAppService.mainApp.unregister()
                logger.notice("unregister() succeeded")
            } catch {
                logger.error("unregister() failed: \(error.localizedDescription, privacy: .public)")
            }
            logStatus()
        }

        static func openLoginItems() {
            SMAppService.openSystemSettingsLoginItems()
        }

        private static func describe(_ status: SMAppService.Status) -> String {
            switch status {
            case .notRegistered: "notRegistered"
            case .enabled: "enabled"
            case .requiresApproval: "requiresApproval"
            case .notFound: "notFound"
            @unknown default: "unknown"
            }
        }
    }
#endif
