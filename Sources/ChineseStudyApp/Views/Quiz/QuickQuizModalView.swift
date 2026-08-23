import SwiftUI

public enum QuizState: Sendable {
    case setup
    case active
    case finished
}

public struct QuickQuizModalView: View {
    let sourceCharacters: [HanziCharacter]
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var quizState: QuizState = .setup
    @State private var selectedCount: Int = 10
    
    @State private var quizQueue: [HanziCharacter] = []
    @State private var currentIndex: Int = 0
    @State private var isFlipped: Bool = false
    
    @State private var correctCount: Int = 0
    @State private var incorrectCount: Int = 0
    
    let countOptions = [10, 20, 50]

    public init(sourceCharacters: [HanziCharacter]) {
        self.sourceCharacters = sourceCharacters
    }

    public var body: some View {
        NavigationStack {
            VStack {
                switch quizState {
                case .setup:
                    QuizSetupView(
                        sourceCharacters: sourceCharacters,
                        selectedCount: $selectedCount,
                        onStart: startQuiz
                    )
                case .active:
                    QuizActiveView(
                        quizQueue: quizQueue,
                        currentIndex: currentIndex,
                        correctCount: correctCount,
                        incorrectCount: incorrectCount,
                        isFlipped: $isFlipped,
                        onRecordAnswer: recordAnswer
                    )
                case .finished:
                    QuizResultsView(
                        quizQueue: quizQueue,
                        correctCount: correctCount,
                        incorrectCount: incorrectCount,
                        onDone: { dismiss() }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Quick Quiz")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Logic Helpers
    
    private func startQuiz() {
        let size = min(selectedCount, sourceCharacters.count)
        quizQueue = Array(sourceCharacters.shuffled().prefix(size))
        currentIndex = 0
        correctCount = 0
        incorrectCount = 0
        isFlipped = false
        withAnimation {
            quizState = .active
        }
    }
    
    private func recordAnswer(correct: Bool) {
        if correct {
            correctCount += 1
            AudioService.shared.playSoundEffect(.learned, isEnabled: AppState.shared.isSoundEffectsEnabled)
        } else {
            incorrectCount += 1
            AudioService.shared.playSoundEffect(.wrong, isEnabled: AppState.shared.isSoundEffectsEnabled)
        }
        
        isFlipped = false
        
        if currentIndex < quizQueue.count - 1 {
            withAnimation {
                currentIndex += 1
            }
        } else {
            AudioService.shared.playSoundEffect(.victory, isEnabled: AppState.shared.isSoundEffectsEnabled)
            withAnimation {
                quizState = .finished
            }
        }
    }
}
