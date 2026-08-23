import SwiftUI

public struct StoryQuizView: View {
    public let story: Story
    @StateObject private var storyViewModel = StoryViewModel.shared
    @Environment(\.dismiss) var dismiss

    public init(story: Story) {
        self.story = story
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                if storyViewModel.isQuizSubmitted {
                    // Results View
                    VStack(spacing: 16) {
                        Image(systemName: storyViewModel.quizScore == story.questions.count ? "star.fill" : "star.leadinghalf.filled")
                            .font(.system(size: 64))
                            .foregroundColor(AppTheme.statusLearned)
                        
                        Text("Quiz Complete!")
                            .font(.largeTitle.bold())
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text("Score: \(storyViewModel.quizScore) / \(story.questions.count)")
                            .font(.title2)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(16)
                }
                
                // Questions
                ForEach(0..<story.questions.count, id: \.self) { index in
                    let question = story.questions[index]
                    VStack(alignment: .leading, spacing: 16) {
                        Text("\(index + 1). \(question.question)")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        ForEach(0..<question.options.count, id: \.self) { optIndex in
                            let option = question.options[optIndex]
                            Button {
                                storyViewModel.selectQuizOption(questionIndex: index, optionIndex: optIndex)
                            } label: {
                                HStack {
                                    Image(systemName: getIcon(questionIndex: index, optionIndex: optIndex, question: question))
                                        .foregroundColor(getColor(questionIndex: index, optionIndex: optIndex, question: question))
                                    Text(option)
                                        .foregroundColor(AppTheme.textPrimary)
                                        .multilineTextAlignment(.leading)
                                    Spacer()
                                }
                                .padding()
                                .background(AppTheme.surfaceBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(getColor(questionIndex: index, optionIndex: optIndex, question: question), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(storyViewModel.isQuizSubmitted)
                        }
                        
                        if storyViewModel.isQuizSubmitted {
                            Text(question.explanation)
                                .font(.callout)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding()
                                .background(AppTheme.surfaceBackground)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(16)
                }
                
                if !storyViewModel.isQuizSubmitted {
                    Button {
                        storyViewModel.submitQuiz()
                    } label: {
                        Text("Submit Answers")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.statusLearned)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(storyViewModel.selectedQuizAnswers.count < story.questions.count)
                } else {
                    Button {
                        dismiss()
                    } label: {
                        Text("Return to Story")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.cardBorder)
                            .foregroundColor(AppTheme.textPrimary)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
        .navigationTitle("Comprehension Quiz")
    }
    
    private func getIcon(questionIndex: Int, optionIndex: Int, question: StoryQuizQuestion) -> String {
        let isSelected = storyViewModel.selectedQuizAnswers[questionIndex] == optionIndex
        
        if !storyViewModel.isQuizSubmitted {
            return isSelected ? "largecircle.fill.circle" : "circle"
        } else {
            if optionIndex == question.correctAnswer {
                return "checkmark.circle.fill"
            } else if isSelected {
                return "xmark.circle.fill"
            } else {
                return "circle"
            }
        }
    }
    
    private func getColor(questionIndex: Int, optionIndex: Int, question: StoryQuizQuestion) -> Color {
        let isSelected = storyViewModel.selectedQuizAnswers[questionIndex] == optionIndex
        
        if !storyViewModel.isQuizSubmitted {
            return isSelected ? AppTheme.statusInProgress : AppTheme.cardBorder
        } else {
            if optionIndex == question.correctAnswer {
                return AppTheme.statusLearned
            } else if isSelected {
                return AppTheme.tone1 // red
            } else {
                return AppTheme.cardBorder
            }
        }
    }
}
