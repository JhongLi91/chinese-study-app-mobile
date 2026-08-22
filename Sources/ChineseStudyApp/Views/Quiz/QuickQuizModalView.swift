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
                    setupView
                case .active:
                    activeQuizView
                case .finished:
                    resultsView
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
    
    // MARK: - Setup View
    
    private var setupView: some View {
        VStack(spacing: 32) {
            Image(systemName: "questionmark.square.dashed")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.statusInProgress)
            
            VStack(spacing: 8) {
                Text("Ready for a quick review?")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                Text("Available pool: \(sourceCharacters.count) characters")
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if sourceCharacters.isEmpty {
                Text("No characters available to quiz.")
                    .foregroundColor(AppTheme.tone1)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Quiz Length:")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 16) {
                        ForEach(countOptions, id: \.self) { count in
                            Button {
                                selectedCount = count
                            } label: {
                                Text("\(count)")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedCount == count ? AppTheme.statusInProgress : AppTheme.cardBackground)
                                    .foregroundColor(selectedCount == count ? .white : AppTheme.textPrimary)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCount == count ? Color.clear : AppTheme.cardBorder, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    
                    Button {
                        selectedCount = sourceCharacters.count
                    } label: {
                        Text("All (\(sourceCharacters.count))")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedCount == sourceCharacters.count ? AppTheme.statusInProgress : AppTheme.cardBackground)
                            .foregroundColor(selectedCount == sourceCharacters.count ? .white : AppTheme.textPrimary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedCount == sourceCharacters.count ? Color.clear : AppTheme.cardBorder, lineWidth: 2)
                            )
                    }
                }
                .padding()
                
                Button {
                    startQuiz()
                } label: {
                    Text("Start Quiz")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.statusLearned)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                }
            }
            Spacer()
        }
        .padding(.top, 40)
    }
    
    // MARK: - Active Quiz View
    
    private var activeQuizView: some View {
        VStack(spacing: 24) {
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Card \(currentIndex + 1) of \(quizQueue.count)")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\(correctCount) Correct / \(incorrectCount) Wrong")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                ProgressView(value: Double(currentIndex), total: Double(quizQueue.count))
                    .tint(AppTheme.statusInProgress)
            }
            .padding(.horizontal)
            
            Spacer()
            
            if currentIndex < quizQueue.count {
                FlashcardView(character: quizQueue[currentIndex], isFlipped: isFlipped)
                    .frame(maxWidth: 340, maxHeight: 460)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isFlipped.toggle()
                        }
                        if isFlipped, AppState.shared.autoPlayAudioOnFlip {
                            AudioService.shared.speak(text: quizQueue[currentIndex].character, rate: AppState.shared.speechRate)
                        }
                    }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 32) {
                Button {
                    recordAnswer(correct: false)
                } label: {
                    VStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold))
                        Text("Didn't Know")
                            .font(.caption.bold())
                    }
                    .foregroundColor(AppTheme.tone1)
                    .frame(width: 80, height: 80)
                    .background(AppTheme.cardBackground)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                }
                
                Button {
                    recordAnswer(correct: true)
                } label: {
                    VStack {
                        Image(systemName: "checkmark")
                            .font(.system(size: 24, weight: .bold))
                        Text("Knew It")
                            .font(.caption.bold())
                    }
                    .foregroundColor(AppTheme.statusLearned)
                    .frame(width: 80, height: 80)
                    .background(AppTheme.cardBackground)
                    .clipShape(Circle())
                    .shadow(radius: 4)
                }
            }
            .opacity(isFlipped ? 1.0 : 0.5)
            .disabled(!isFlipped)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Results View
    
    private var resultsView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            let accuracy = quizQueue.isEmpty ? 0 : Int((Double(correctCount) / Double(quizQueue.count)) * 100)
            
            Image(systemName: accuracy >= 80 ? "star.fill" : (accuracy >= 50 ? "star.leadinghalf.filled" : "star"))
                .font(.system(size: 100))
                .foregroundColor(accuracy >= 80 ? AppTheme.statusLearned : AppTheme.statusInProgress)
            
            Text("Quiz Finished!")
                .font(.largeTitle.bold())
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 12) {
                Text("Accuracy: \(accuracy)%")
                    .font(.title2)
                    .foregroundColor(AppTheme.textPrimary)
                
                HStack(spacing: 24) {
                    VStack {
                        Text("\(correctCount)")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.statusLearned)
                        Text("Correct")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    VStack {
                        Text("\(incorrectCount)")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.tone1)
                        Text("Incorrect")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(16)
            }
            
            Spacer()
            
            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.statusInProgress)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
            }
            .padding(.bottom, 32)
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
