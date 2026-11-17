import Foundation

/// The audio files shipped with the app, made by `scripts/generate-audio.sh`.
public enum BundledAudio {
    public static var breakStart: URL? { url("break-start") }
    public static var breakEnd: URL? { url("break-end") }

    /// The spoken instruction for an exercise, in `language` (a code such as "en"), falling back to English.
    public static func voiceClip(for exerciseID: String, language: String = "en") -> URL? {
        url("\(exerciseID).\(language)") ?? url("\(exerciseID).en")
    }

    private static func url(_ name: String) -> URL? {
        Bundle.module.url(forResource: name, withExtension: "m4a")
            ?? Bundle.module.url(forResource: name, withExtension: "m4a", subdirectory: "Audio")
    }
}
