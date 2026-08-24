import Foundation
import SwiftUI
import Combine

/// Pinyin annotation mode for story reading.
public enum PinyinMode: String, CaseIterable, Identifiable, Sendable {
    case ruby = "Ruby"
    case inline = "Inline"
    case hidden = "Hidden"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .ruby: return "Pinyin Above"
        case .inline: return "Inline Pinyin"
        case .hidden: return "Characters Only"
        }
    }
}

/// ViewModel managing graded stories, sentence-by-sentence audio narration, and comprehension quizzes.
@MainActor
public final class StoryViewModel: ObservableObject {
    public static let shared = StoryViewModel()

    private let repository: ProgressRepositoryProtocol
    private let audioService: AudioService
    private let hapticService: HapticService

    // Published State
    @Published public var stories: [Story] = []
    @Published public var selectedStory: Story? = nil
    @Published public var activeSentenceIndex: Int? = nil
    @Published public var pinyinMode: PinyinMode = .ruby
    @Published public var showEnglishTranslation: Bool = false

    // Quiz State
    @Published public var selectedQuizAnswers: [Int: Int] = [:] // [QuestionIndex: SelectedOptionIndex]
    @Published public var isQuizSubmitted: Bool = false
    @Published public var quizScore: Int = 0

    public init(
        repository: ProgressRepositoryProtocol = ProgressRepository.shared,
        audioService: AudioService = .shared,
        hapticService: HapticService = .shared
    ) {
        self.repository = repository
        self.audioService = audioService
        self.hapticService = hapticService
        loadStories()
    }

    public func loadStories() {
        guard stories.isEmpty else { return }
        self.stories = repository.getStories()
        if selectedStory == nil, let first = stories.first {
            selectStory(first)
        }
    }

    public func selectStory(_ story: Story) {
        self.selectedStory = story
        self.activeSentenceIndex = nil
        resetQuiz()
    }

    // MARK: - Audio Narration

    public func playSentenceAudio(sentence: StorySentence, index: Int) {
        self.activeSentenceIndex = index
        audioService.speak(text: sentence.zh, rate: AppState.shared.speechRate)
    }

    public func playFullStory() {
        guard let story = selectedStory else { return }
        let fullZh = story.paragraphs.map { $0.sentences.map { $0.zh }.joined(separator: " ") }.joined(separator: "\n")
        self.activeSentenceIndex = nil
        audioService.speak(text: fullZh, rate: AppState.shared.speechRate)
    }

    public func stopAudio() {
        audioService.stopSpeaking()
        self.activeSentenceIndex = nil
    }

    // MARK: - Comprehension Quiz

    public func selectQuizOption(questionIndex: Int, optionIndex: Int) {
        guard !isQuizSubmitted else { return }
        selectedQuizAnswers[questionIndex] = optionIndex
        hapticService.trigger(.lightImpact)
    }

    public func submitQuiz() {
        guard let story = selectedStory, !story.questions.isEmpty else { return }
        var correctCount = 0
        for (qIdx, question) in story.questions.enumerated() {
            if let selected = selectedQuizAnswers[qIdx], selected == question.correctAnswer {
                correctCount += 1
            }
        }
        self.quizScore = correctCount
        self.isQuizSubmitted = true

        if correctCount == story.questions.count {
            audioService.playSoundEffect(.victory, isEnabled: AppState.shared.isSoundEffectsEnabled)
            hapticService.trigger(.success)
        } else {
            audioService.playSoundEffect(.learned, isEnabled: AppState.shared.isSoundEffectsEnabled)
            hapticService.trigger(.mediumImpact)
        }
    }

    public func resetQuiz() {
        self.selectedQuizAnswers = [:]
        self.isQuizSubmitted = false
        self.quizScore = 0
    }
}
