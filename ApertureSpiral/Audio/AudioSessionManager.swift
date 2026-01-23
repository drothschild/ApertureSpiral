import AVFoundation
import Combine

class AudioSessionManager: ObservableObject {
    static let shared = AudioSessionManager()

    /// Tracks whether other audio was playing before we paused it
    @Published var wasPlayingBeforePause: Bool = false

    /// For testing: simulates whether other audio is currently playing
    var simulateOtherAudioPlaying: Bool = false

    private let isTestMode: Bool
    private let audioSession: AVAudioSession

    private init() {
        self.isTestMode = false
        self.audioSession = AVAudioSession.sharedInstance()
    }

    /// Creates an instance for testing purposes
    init(forTesting: Bool) {
        self.isTestMode = forTesting
        self.audioSession = AVAudioSession.sharedInstance()
    }

    /// Checks if other audio is currently playing
    private func isOtherAudioPlaying() -> Bool {
        if isTestMode {
            return simulateOtherAudioPlaying
        }
        return audioSession.isOtherAudioPlaying
    }

    /// Pauses other apps' audio by activating our audio session with duck others option
    func pauseOtherAudio() {
        // Don't override if we already tracked that audio was playing
        if wasPlayingBeforePause {
            return
        }

        // Check if other audio is playing before we pause it
        if isOtherAudioPlaying() {
            wasPlayingBeforePause = true

            if !isTestMode {
                do {
                    // Configure audio session to interrupt other audio
                    try audioSession.setCategory(.playback, mode: .default, options: [])
                    try audioSession.setActive(true, options: [])
                } catch {
                    print("Failed to pause other audio: \(error)")
                }
            }
        }
    }

    /// Resumes other apps' audio by deactivating our audio session
    func resumeOtherAudio() {
        guard wasPlayingBeforePause else { return }

        wasPlayingBeforePause = false

        if !isTestMode {
            do {
                // Deactivate our audio session to allow other apps to resume
                try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                print("Failed to resume other audio: \(error)")
            }
        }
    }

    /// Handles spiral frozen state changes - called when spiralFrozen changes
    func handleSpiralFrozenChange(isFrozen: Bool) {
        if isFrozen {
            pauseOtherAudio()
        } else {
            resumeOtherAudio()
        }
    }
}
