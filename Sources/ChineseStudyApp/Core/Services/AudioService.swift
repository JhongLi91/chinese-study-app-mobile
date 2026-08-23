import Foundation
import SwiftUI
#if !SKIP
import AVFoundation
import AudioToolbox
#else
import android.content.Context
import android.speech.tts.TextToSpeech
import java.util.Locale
#endif

/// Sound effect types for tactile study interactions.
public enum SoundEffect: String, CaseIterable, Sendable {
    case flip = "flip"
    case learned = "learned"
    case inProgress = "inProgress"
    case victory = "victory"
    case streak = "streak"
    case wrong = "wrong"
}

/// Unified cross-platform Mandarin Text-To-Speech and audio feedback service.
@MainActor
public final class AudioService: NSObject, ObservableObject {
    public static let shared = AudioService()

    @Published public var isSpeaking: Bool = false

    #if !SKIP
    private let synthesizer = AVSpeechSynthesizer()
    private let zhVoice = AVSpeechSynthesisVoice(language: "zh-CN")
    #else
    private var tts: TextToSpeech?
    private var isTtsInitialized = false
    #endif

    override private init() {
        super.init()
        #if os(iOS)
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.duckOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
        #elseif SKIP
        setupAndroidTTS()
        #endif
    }

    #if SKIP
    private func setupAndroidTTS() {
        let appContext = ProcessInfo.processInfo.androidContext
        self.tts = TextToSpeech(appContext, { status in
            if status == TextToSpeech.SUCCESS {
                self.tts?.setLanguage(Locale.CHINESE)
                self.isTtsInitialized = true
            }
        })
    }
    #endif

    // MARK: - Speech Synthesis

    /// Speaks Chinese text (characters, sentences, or stories) in Mandarin (zh-CN).
    public func speak(text: String, rate: Double = 1.0) {
        guard !text.isEmpty else { return }

        #if !SKIP
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = zhVoice ?? AVSpeechSynthesisVoice(language: "zh-CN")
        // iOS speech rate ranges from 0.0 (slowest) to 1.0 (fastest), default 0.5
        let clampedRate = Float(max(0.2, min(1.0, 0.5 * rate)))
        utterance.rate = clampedRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0

        isSpeaking = true
        synthesizer.speak(utterance)
        #else
        if isTtsInitialized, let tts = tts {
            tts.setSpeechRate(Float(rate))
            tts.speak(text, TextToSpeech.QUEUE_FLUSH, nil, "chinese_study_tts")
            isSpeaking = true
        }
        #endif
    }

    /// Stops any ongoing speech immediately.
    public func stopSpeaking() {
        #if !SKIP
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        #else
        tts?.stop()
        #endif
        isSpeaking = false
    }

    // MARK: - Sound Effects

    /// Plays synthesized auditory feedback for mobile interactions.
    public func playSoundEffect(_ effect: SoundEffect, isEnabled: Bool = true) {
        guard isEnabled else { return }

        #if !SKIP
        switch effect {
        case .flip:
            // Standard system click (1104 / 1306)
            AudioServicesPlaySystemSound(1104)
        case .learned:
            // Pleasant positive chime (1054 / 1025)
            AudioServicesPlaySystemSound(1054)
        case .inProgress:
            // Low confirmation tick (1103)
            AudioServicesPlaySystemSound(1103)
        case .victory:
            // Fanfare / success alert (1022)
            AudioServicesPlaySystemSound(1022)
        case .streak:
            // Quick high double tone (1057)
            AudioServicesPlaySystemSound(1057)
        case .wrong:
            // Short alert tone (1053)
            AudioServicesPlaySystemSound(1053)
        }
        #endif
    }
}
