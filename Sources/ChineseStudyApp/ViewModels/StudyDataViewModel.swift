import Foundation
import SwiftUI

/// Core ViewModel managing curriculum navigation, flashcard review queues, and progress statistics.
@MainActor
public final class StudyDataViewModel: ObservableObject {
    public static let shared = StudyDataViewModel()

    private let repository: ProgressRepositoryProtocol
    private let audioService: AudioService
    private let hapticService: HapticService

    // Published Curriculum & Character State
    @Published public var lessons: [LessonInfo] = []
    @Published public var currentLessonCharacters: [HanziCharacter] = []
    @Published public var activeLessonNumber: Int = 1

    // Flashcard Queue State
    @Published public var activeCardIndex: Int = 0
    @Published public var isCardFlipped: Bool = false

    // Search & Filter State (Vocab List / Dictionary)
    @Published public var searchQuery: String = "" {
        didSet { recomputeFilteredCharacters() }
    }
    @Published public var selectedFilterStatus: StudyStatus? = nil {
        didSet { recomputeFilteredCharacters() }
    }
    @Published public var selectedHskFilter: Int? = nil {
        didSet { recomputeFilteredCharacters() }
    }
    @Published public var selectedLessonFilter: Int? = nil {
        didSet { recomputeFilteredCharacters() }
    }

    // Cached filtered results & aggregate stats
    @Published public private(set) var filteredCharacters: [HanziCharacter] = []
    @Published public private(set) var totalLearnedCount: Int = 0
    @Published public private(set) var totalInProgressCount: Int = 0
    @Published public private(set) var totalNewCount: Int = 0
    @Published public private(set) var overallLearnedPercentage: Double = 0.0

    // Internal backing store — NOT @Published to avoid cascade recompositions.
    // Views that need access use the computed filteredCharacters or stats above.
    private var _allCharacters: [HanziCharacter] = []
    public var allCharacters: [HanziCharacter] {
        get { _allCharacters }
        set {
            _allCharacters = newValue
            recomputeStats()
            recomputeFilteredCharacters()
        }
    }

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

    // MARK: - Recompute Helpers (simple imperative, no Combine overhead)

    private func recomputeFilteredCharacters() {
        let query = searchQuery.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).lowercased()
        let statusFilter = selectedFilterStatus
        let hskFilter = selectedHskFilter
        let lessonFilter = selectedLessonFilter
        let source = _allCharacters

        filteredCharacters = source.filter { char in
            if let status = statusFilter, char.status != status { return false }
            if let hsk = hskFilter, char.hskLevel != hsk { return false }
            if let lesson = lessonFilter, char.lessonNumber != lesson { return false }
            if query.isEmpty { return true }
            return char.character.contains(query) ||
                   char.pinyin.lowercased().contains(query) ||
                   char.definition.lowercased().contains(query)
        }
    }

    private func recomputeStats() {
        var learned = 0
        var inProgress = 0
        var newCount = 0
        for char in _allCharacters {
            switch char.status {
            case .learned: learned += 1
            case .inProgress: inProgress += 1
            case .new: newCount += 1
            }
        }
        totalLearnedCount = learned
        totalInProgressCount = inProgress
        totalNewCount = newCount
        overallLearnedPercentage = _allCharacters.isEmpty ? 0.0 : Double(learned) / Double(_allCharacters.count)
    }

    // MARK: - Data Loading (async to avoid blocking main thread)

    public func loadData() {
        let repo = self.repository
        let lesson = self.activeLessonNumber
        Task.detached(priority: .userInitiated) {
            let chars = repo.getAllCharacters()
            let lessons = repo.getAllLessons()
            let lessonChars = repo.getCharacters(forLesson: lesson)
            await MainActor.run {
                self._allCharacters = chars
                self.lessons = lessons
                self.currentLessonCharacters = lessonChars
                self.activeCardIndex = 0
                self.isCardFlipped = false
                self.recomputeStats()
                self.recomputeFilteredCharacters()
            }
        }
    }

    public func loadLesson(lessonNumber: Int) {
        self.activeLessonNumber = lessonNumber
        let repo = self.repository
        Task.detached(priority: .userInitiated) {
            let chars = repo.getCharacters(forLesson: lessonNumber)
            await MainActor.run {
                self.currentLessonCharacters = chars
                self.activeCardIndex = 0
                self.isCardFlipped = false
            }
        }
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
        // Fire-and-forget the DB write on a background thread
        let repo = self.repository
        let rank = character.frequencyRank
        Task.detached(priority: .utility) {
            repo.updateStatus(for: rank, to: status)
        }

        // Update in-memory collections immediately (no DB round-trip)
        if let idx = currentLessonCharacters.firstIndex(where: { $0.frequencyRank == character.frequencyRank }) {
            currentLessonCharacters[idx].status = status
        }
        if let allIdx = _allCharacters.firstIndex(where: { $0.frequencyRank == character.frequencyRank }) {
            _allCharacters[allIdx].status = status
        }
        // Recompute stats from in-memory data (no DB query)
        recomputeStats()
        recomputeFilteredCharacters()
        refreshLessonStatsFromMemory()
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

    /// Recompute lesson stats from the in-memory character array instead of querying DB.
    private func refreshLessonStatsFromMemory() {
        var lessonStats: [Int: (total: Int, learned: Int, inProgress: Int)] = [:]
        for char in _allCharacters {
            var stats = lessonStats[char.lessonNumber] ?? (total: 0, learned: 0, inProgress: 0)
            stats.total += 1
            if char.status == .learned { stats.learned += 1 }
            if char.status == .inProgress { stats.inProgress += 1 }
            lessonStats[char.lessonNumber] = stats
        }
        self.lessons = lessonStats.keys.sorted().map { lessonNum in
            let stats = lessonStats[lessonNum]!
            return LessonInfo(
                lessonNumber: lessonNum,
                totalCount: stats.total,
                learnedCount: stats.learned,
                inProgressCount: stats.inProgress,
                newCount: max(0, stats.total - stats.learned - stats.inProgress)
            )
        }
    }
}
