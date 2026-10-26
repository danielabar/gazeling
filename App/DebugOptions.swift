import Foundation
import GazelingKit

/// Debug-only launch arguments, so a break can be seen without waiting 20 minutes.
/// Example: `Gazeling --short-interval 10 --heads-up 5 --break-now`. Values are seconds.
/// `--no-auto-breaks` stops scheduled breaks, so only the debug menu starts one.
/// Overrides are laid over the user's settings and never saved.
struct DebugOptions {
    var overrides = TimingOverrides()
    var breakNow = false

    init(arguments: [String] = CommandLine.arguments) {
        #if DEBUG
            func seconds(_ flag: String) -> TimeInterval? {
                guard let i = arguments.firstIndex(of: flag), i + 1 < arguments.count else { return nil }
                return TimeInterval(arguments[i + 1].trimmingSuffix("s"))
            }
            overrides.shortInterval = seconds("--short-interval")
            overrides.shortDuration = seconds("--short-duration")
            overrides.longInterval = seconds("--long-interval")
            overrides.longDuration = seconds("--long-duration")
            overrides.headsUpLead = seconds("--heads-up")
            if arguments.contains("--no-auto-breaks") {
                // Effectively never: a day. For inspecting animations from the debug menu without interruptions.
                overrides.shortInterval = 24 * 60 * 60
                overrides.longInterval = 24 * 60 * 60
            }
            breakNow = arguments.contains("--break-now")
        #endif
    }
}

extension StringProtocol {
    fileprivate func trimmingSuffix(_ suffix: String) -> String {
        hasSuffix(suffix) ? String(dropLast(suffix.count)) : String(self)
    }
}
