import SwiftUI

public struct QuizResultsView: View {
    let quizQueue: [HanziCharacter]
    let correctCount: Int
    let incorrectCount: Int
    let onDone: () -> Void
    
    public var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            let accuracy = quizQueue.isEmpty ? 0 : Int((Double(correctCount) / Double(quizQueue.count)) * 100)
            
            Image("star", bundle: .module)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(accuracy >= 80 ? AppTheme.statusLearned : AppTheme.statusInProgress)
            
            Text("Quiz Finished!")
                .font(.largeTitle.bold())
                .foregroundColor(AppTheme.textPrimary)
            
            VStack(spacing: 12) {
                Text("Accuracy: \\(accuracy)%")
                    .font(.title2)
                    .foregroundColor(AppTheme.textPrimary)
                
                HStack(spacing: 24) {
                    VStack {
                        Text("\\(correctCount)")
                            .font(.title.bold())
                            .foregroundColor(AppTheme.statusLearned)
                        Text("Correct")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    VStack {
                        Text("\\(incorrectCount)")
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
                onDone()
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
}
