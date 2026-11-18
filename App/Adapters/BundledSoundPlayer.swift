import AVFoundation
import GazelingKit
import os

/// Plays our own chimes and the spoken instruction from the audio files in the GazelingKit bundle.
@MainActor
final class BundledSoundPlayer: SoundPlayer {
    /// The voice starts after the start chime has mostly rung out, so the two do not overlap.
    private static let voiceDelay = Duration.milliseconds(800)

    private let logger = Logger(subsystem: "com.danielabar.gazeling", category: "sound")
    private var chime: AVAudioPlayer?
    private var voice: AVAudioPlayer?
    private var voiceTask: Task<Void, Never>?

    func playBreakStart() { playChime(BundledAudio.breakStart) }

    func playBreakEnd() { playChime(BundledAudio.breakEnd) }

    func playInstruction(of exercise: Exercise) {
        stopInstruction()
        let language = Locale.current.language.languageCode?.identifier ?? "en"
        guard let url = BundledAudio.voiceClip(for: exercise.id, language: language) else {
            logger.error("no voice clip for \(exercise.id, privacy: .public)")
            return
        }
        voiceTask = Task { [weak self] in
            try? await Task.sleep(for: Self.voiceDelay)
            guard !Task.isCancelled, let self else { return }
            self.voice = self.makePlayer(url)
            self.voice?.play()
        }
    }

    func stopInstruction() {
        voiceTask?.cancel()
        voiceTask = nil
        voice?.stop()
        voice = nil
    }

    private func playChime(_ url: URL?) {
        guard let url else {
            logger.error("chime file missing")
            return
        }
        chime = makePlayer(url)
        chime?.play()
    }

    private func makePlayer(_ url: URL) -> AVAudioPlayer? {
        do {
            return try AVAudioPlayer(contentsOf: url)
        } catch {
            logger.error(
                "cannot play \(url.lastPathComponent, privacy: .public): \(error.localizedDescription, privacy: .public)"
            )
            return nil
        }
    }
}
