import AppKit
import GazelingKit

/// Plays built-in macOS sounds until Phase 6 adds our own chime and voice clips.
struct SystemSoundPlayer: SoundPlayer {
    func playBreakStart() { NSSound(named: "Tink")?.play() }
    func playBreakEnd() { NSSound(named: "Glass")?.play() }
}
