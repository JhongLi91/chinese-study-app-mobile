import Foundation
import SwiftUI
import Combine

/// Core ViewModel managing curriculum navigation, flashcard review queues, and progress statistics.
@MainActor
public final class StudyDataViewModel: ObservableObject {
    public static let shared = StudyDataViewModel()

    private let repository: ProgressRepositoryProtocol
    private let audioService: AudioService
    private let hapticService: HapticService

    // Published Curriculum & Character State
    @Published public var lessons: [LessonInfo] = []
    @Published public var allCharacters: [HanziCharacter] = []
    @Published public var currentLessonCharacters: [HanziCharacter] = []
    @Published public var activeLessonNumber: Int = 1

    // Flashcard Queue State
    @Published public var activeCardIndex: Int = 0
    @Published public var isCardFlipped: Bool = false

    // Search & Filter State (Vocab List / Dictionary)
    @Published public var searchQuery: String = ""
    @Published public var selectedFilterStatus: StudyStatus? = nil
    @Published public var selectedHskFilter: Int? = nil
    @Published public var selectedLessonFilter: Int? = nil

    public init(
        repository: ProgressRepositoryProtocol = ProgressRepository.shared,
        audioService: AudioService = .shared,
        hapticService: HapticService = .shared
    ) {
        self.repository = repository
        self.audioService = audioService
        self.hapticService = hapticService
        loadData()
    }

    // MARK: - Data Loading

    public func loadData() {
        self.allCharacters = repository.getAllCharacters()
        self.lessons = repository.getAllLessons()
        loadLesson(lessonNumber: activeLessonNumber)
    }

    public func loadLesson(lessonNumber: Int) {
        self.activeLessonNumber = lessonNumber
        self.currentLessonCharacters = repository.getCharacters(forLesson: lessonNumber)
        self.activeCardIndex = 0
        self.isCardFlipped = false
    }

    // MARK: - Current Card & Queue Navigation

    public var currentCard: HanziCharacter? {
        guard !currentLessonCharacters.isEmpty,
              activeCardIndex >= 0,
              activeCardIndex < currentLessonCharacters.count else {
            return nil
        }
        return currentLessonCharacters[activeCardIndex]
    }

    public func flipCard() {
        isCardFlipped.toggle()
        audioService.playSoundEffect(.flip, isEnabled: AppState.shared.isSoundEffectsEnabled)
        hapticService.trigger(.lightImpact)

        if isCardFlipped, AppState.shared.autoPlayAudioOnFlip, let card = currentCard {
            audioService.speak(text: card.character, rate: AppState.shared.speechRate)
        }
    }

    public func nextCard() {
        guard !currentLessonCharacters.isEmpty else { return }
        isCardFlipped = false
        if activeCardIndex < currentLessonCharacters.count - 1 {
            activeCardIndex += 1
        } else {
            // Reached end of lesson queue
            audioService.playSoundEffect(.victory, isEnabled: AppState.shared.isSoundEffectsEnabled)
            hapticService.trigger(.success)
        }
    }

    public func previousCard() {
        guard !currentLessonCharacters.isEmpty else { return }
        isCardFlipped = false
        if activeCardIndex > 0 {
            activeCardIndex -= 1
        }
    }

    public func shuffleCurrentQueue() {
        isCardFlipped = false
        currentLessonCharacters.shuffle()
        activeCardIndex = 0
    }

    // MARK: - Status Mutations

    public func markCurrentCardLearned() {
        guard let card = currentCard else { return }
        updateStatus(for: card, to: .learned)
        audioService.playSoundEffect(.learned, isEnabled: AppState.shared.isSoundEffectsEnabled)
        hapticService.trigger(.success)
        nextCard()
    }

    public func markCurrentCardInProgress() {
        guard let card = currentCard else { return }
        updateStatus(for: card, to: .inProgress)
        audioService.playSoundEffect(.inProgress, isEnabled: AppState.shared.isSoundEffectsEnabled)
        hapticService.trigger(.mediumImpact)
        nextCard()
    }

    public func updateStatus(for character: HanziCharacter, to status: StudyStatus) {
        repository.updateStatus(for: character.frequencyRank, to: status)

        // Update in-memory collections reactively
        if let idx = currentLessonCharacters.firstIndex(where: { $0.frequencyRank == character.frequencyRank }) {
            currentLessonCharacters[idx].status = status
        }
        if let allIdx = allCharacters.firstIndex(where: { $0.frequencyRank == character.frequencyRank }) {
            allCharacters[allIdx].status = status
        }
        refreshLessonStats()
    }

    public func batchMarkLearned(ranks: [Int]) {
        repository.batchUpdateStatus(for: ranks, to: .learned)
        loadData()
    }

    public func resetLessonProgress(lessonNumber: Int) {
        repository.resetLesson(lessonNumber: lessonNumber)
        loadData()
    }

    public func resetAllProgress() {
        repository.resetAll()
        loadData()
    }

    private func refreshLessonStats() {
        self.lessons = repository.getAllLessons()
    }

    // MARK: - Search & Filtering

    public var filteredCharacters: [HanziCharacter] {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        return allCharacters.filter { char in
            // Status filter
            if let status = selectedFilterStatus, char.status != status {
                return false
            }
            // HSK level filter
            if let hsk = selectedHskFilter, char.hskLevel != hsk {
                return false
            }
            // Lesson filter
            if let lesson = selectedLessonFilter, char.lessonNumber != lesson {
                return false
            }
            // Text query
            if query.isEmpty {
                return true
            }
            return char.character.contains(query) ||
                   char.pinyin.lowercased().contains(query) ||
                   char.definition.lowercased().contains(query)
        }
    }

    // MARK: - Global Progress Metrics

    public var totalLearnedCount: Int {
        allCharacters.filter { $0.status == .learned }.count
    }

    public var totalInProgressCount: Int {
        allCharacters.filter { $0.status == .inProgress }.count
    }

    public var totalNewCount: Int {
        allCharacters.filter { $0.status == .new }.count
    }

    public var overallLearnedPercentage: Double {
        guard !allCharacters.isEmpty else { return 0.0 }
        return Double(totalLearnedCount) / Double(allCharacters.count)
    }
}
