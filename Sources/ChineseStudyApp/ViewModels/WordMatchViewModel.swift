import Foundation
import SwiftUI
import Combine

/// ViewModel managing the interactive tile matching mini-game logic.
@MainActor
public final class WordMatchViewModel: ObservableObject {
    public static let shared = WordMatchViewModel()

    private let repository: ProgressRepositoryProtocol
    private let audioService: AudioService
    private let hapticService: HapticService

    // Game Board State
    @Published public var cards: [MatchCard] = []
    @Published public var selectedFirstCardId: String? = nil
    @Published public var selectedSecondCardId: String? = nil

    // Game Metrics
    @Published public var activeLessonNumber: Int = 1
    @Published public var matchedPairCount: Int = 0
    @Published public var totalPairs: Int = 4
    @Published public var attempts: Int = 0
    @Published public var streak: Int = 0
    @Published public var isGameComplete: Bool = false
    @Published public var isProcessingMismatch: Bool = false

    public init(
        repository: ProgressRepositoryProtocol = ProgressRepository.shared,
        audioService: AudioService = .shared,
        hapticService: HapticService = .shared
    ) {
        self.repository = repository
        self.audioService = audioService
        self.hapticService = hapticService
        startNewGame(lessonNumber: 1)
    }

    // MARK: - Game Setup

    public func startNewGame(lessonNumber: Int = 1) {
        self.activeLessonNumber = lessonNumber
        self.selectedFirstCardId = nil
        self.selectedSecondCardId = nil
        self.matchedPairCount = 0
        self.attempts = 0
        self.streak = 0
        self.isGameComplete = false
        self.isProcessingMismatch = false

        let lessonChars = repository.getCharacters(forLesson: lessonNumber)
        guard !lessonChars.isEmpty else { return }

        // Pick 4 characters for an 8-card grid
        let sampleSize = min(4, lessonChars.count)
        let sampled = Array(lessonChars.shuffled().prefix(sampleSize))
        self.totalPairs = sampled.count

        var deck: [MatchCard] = []
        for (idx, char) in sampled.enumerated() {
            // Glyph Card
            deck.append(
                MatchCard(
                    id: "glyph_\(char.frequencyRank)_\(idx)",
                    pairId: char.frequencyRank,
                    displayText: char.character,
                    subText: char.pinyin,
                    type: .character
                )
            )
            // Meaning Card
            deck.append(
                MatchCard(
                    id: "meaning_\(char.frequencyRank)_\(idx)",
                    pairId: char.frequencyRank,
                    displayText: char.cleanDefinition,
                    subText: nil,
                    type: .definition
                )
            )
        }

        self.cards = deck.shuffled()
    }

    // MARK: - Tile Tap Selection

    public func selectCard(_ card: MatchCard) {
        guard !isProcessingMismatch, !card.isMatched else { return }

        // Ignore clicking the already selected first card
        if let firstId = selectedFirstCardId, firstId == card.id {
            return
        }

        hapticService.trigger(.lightImpact)
        audioService.playSoundEffect(.flip, isEnabled: AppState.shared.isSoundEffectsEnabled)

        if selectedFirstCardId == nil {
            // First card selected
            selectedFirstCardId = card.id
            updateCardState(id: card.id, isSelected: true)
        } else if selectedSecondCardId == nil {
            // Second card selected
            selectedSecondCardId = card.id
            updateCardState(id: card.id, isSelected: true)
            attempts += 1

            // Evaluate Match
            evaluateMatch()
        }
    }

    private func evaluateMatch() {
        guard let firstId = selectedFirstCardId,
              let secondId = selectedSecondCardId,
              let firstCard = cards.first(where: { $0.id == firstId }),
              let secondCard = cards.first(where: { $0.id == secondId }) else {
            return
        }

        if firstCard.pairId == secondCard.pairId && firstCard.type != secondCard.type {
            // Correct Match!
            streak += 1
            matchedPairCount += 1

            updateCardState(id: firstId, isSelected: false, isMatched: true)
            updateCardState(id: secondId, isSelected: false, isMatched: true)

            // Speak Chinese character if matched
            if firstCard.type == .character {
                audioService.speak(text: firstCard.displayText, rate: AppState.shared.speechRate)
            } else {
                audioService.speak(text: secondCard.displayText, rate: AppState.shared.speechRate)
            }

            audioService.playSoundEffect(.learned, isEnabled: AppState.shared.isSoundEffectsEnabled)
            hapticService.trigger(.success)

            selectedFirstCardId = nil
            selectedSecondCardId = nil

            if matchedPairCount >= totalPairs {
                // Game Finished
                isGameComplete = true
                audioService.playSoundEffect(.victory, isEnabled: AppState.shared.isSoundEffectsEnabled)
                hapticService.trigger(.heavyImpact)
            }
        } else {
            // Mismatch
            streak = 0
            isProcessingMismatch = true
            updateCardState(id: firstId, isWrong: true)
            updateCardState(id: secondId, isWrong: true)
            audioService.playSoundEffect(.wrong, isEnabled: AppState.shared.isSoundEffectsEnabled)
            hapticService.trigger(.error)

            // Reset selection after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
                guard let self = self else { return }
                self.updateCardState(id: firstId, isSelected: false, isWrong: false)
                self.updateCardState(id: secondId, isSelected: false, isWrong: false)
                self.selectedFirstCardId = nil
                self.selectedSecondCardId = nil
                self.isProcessingMismatch = false
            }
        }
    }

    private func updateCardState(id: String, isSelected: Bool? = nil, isMatched: Bool? = nil, isWrong: Bool? = nil) {
        if let idx = cards.firstIndex(where: { $0.id == id }) {
            if let sel = isSelected { cards[idx].isSelected = sel }
            if let mat = isMatched { cards[idx].isMatched = mat }
            if let wro = isWrong { cards[idx].isWrong = wro }
        }
    }
}
