import Foundation

/// Plain-language durations for the UI, such as "5 minutes" or "1 hour, 30 minutes".
public enum DurationText {
    public static func format(_ seconds: TimeInterval, locale: Locale = .current) -> String {
        Duration.seconds(seconds)
            .formatted(.units(allowed: [.hours, .minutes, .seconds], width: .wide).locale(locale))
    }
}
