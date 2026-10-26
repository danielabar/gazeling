import Foundation
import CoreGraphics
import GazelingKit

struct SystemIdleMonitor: IdleMonitor {
    func idleSeconds() -> TimeInterval {
        // ~0 is "any input event type"; Swift does not expose kCGAnyInputEventType.
        CGEventSource.secondsSinceLastEventType(
            .combinedSessionState, eventType: CGEventType(rawValue: ~0)!)
    }
}
