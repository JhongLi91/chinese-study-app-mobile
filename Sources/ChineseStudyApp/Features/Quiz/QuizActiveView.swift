import SwiftUI

public struct QuizActiveView: View {
    let quizQueue: [HanziCharacter]
    let currentIndex: Int
    let correctCount: Int
    let incorrectCount: Int
    @Binding var isFlipped: Bool
    let onRecordAnswer: (Bool) -> Void
    
    public var body: some View {
        VStack(spacing: 24) {
            // Progress Bar
            VStack(spacing: 8) {
                HStack {
                    Text("Card \\(currentIndex + 1) of \\(quizQueue.count)")
                        .font(.subheadline.bold())
                        .foregroundColor(AppTheme.textSecondary)
                    Spacer()
                    Text("\\(correctCount) Correct / \\(incorrectCount) Wrong")
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
                    onRecordAnswer(false)
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
                    onRecordAnswer(true)
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
}
