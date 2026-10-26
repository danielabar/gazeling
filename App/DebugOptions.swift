import Foundation
import GazelingKit

/// Debug-only launch arguments, so a break can be seen without waiting 20 minutes.
/// Example: `Gazeling --short-interval 10 --heads-up 5 --break-now`. Values are seconds.
/// `--no-auto-breaks` stops scheduled breaks, so only the debug menu starts one.
/// Overrides are not saved to the user's settings.
struct DebugOptions {
    var settings: Settings?
    var breakNow = false

    init(arguments: [String] = CommandLine.arguments) {
        #if DEBUG
            var settings = Settings()
            var overridden = false
            func seconds(_ flag: String) -> TimeInterval? {
                guard let i = arguments.firstIndex(of: flag), i + 1 < arguments.count else { return nil }
                return TimeInterval(arguments[i + 1].trimmingSuffix("s"))
            }
            if let v = seconds("--short-interval") {
                settings.shortBreakInterval = v
                overridden = true
            }
            if let v = seconds("--short-duration") {
                settings.shortBreakDuration = v
                overridden = true
            }
            if let v = seconds("--long-interval") {
                settings.longBreakInterval = v
                overridden = true
            }
            if let v = seconds("--long-duration") {
                settings.longBreakDuration = v
                overridden = true
            }
            if let v = seconds("--heads-up") {
                settings.headsUpLead = v
                overridden = true
            }
            if arguments.contains("--no-auto-breaks") {
                // Effectively never: a day. For inspecting animations from the debug menu without interruptions.
                settings.shortBreakInterval = 24 * 60 * 60
                settings.longBreakInterval = 24 * 60 * 60
                overridden = true
            }
            if overridden { self.settings = settings }
            breakNow = arguments.contains("--break-now")
        #endif
    }
}

extension StringProtocol {
    fileprivate func trimmingSuffix(_ suffix: String) -> String {
        hasSuffix(suffix) ? String(dropLast(suffix.count)) : String(self)
    }
}
