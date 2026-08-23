import SwiftUI

public struct CardScrubberView: View {
    @EnvironmentObject var studyData: StudyDataViewModel

    public init() {}

    public var body: some View {
        HStack(spacing: 20) {
            Button {
                studyData.previousCard()
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(studyData.activeCardIndex > 0 ? AppTheme.textPrimary : AppTheme.cardBorder)
            }
            .disabled(studyData.activeCardIndex == 0)

            VStack {
                Text("\(studyData.activeCardIndex + 1) / \(studyData.currentLessonCharacters.count)")
                    .font(.headline)
                    .foregroundColor(AppTheme.textPrimary)
                
                ProgressView(value: Double(studyData.activeCardIndex + 1), total: Double(max(1, studyData.currentLessonCharacters.count)))
                    .tint(AppTheme.statusLearned)
            }
            .frame(maxWidth: 150)

            Button {
                studyData.nextCard()
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(studyData.activeCardIndex < studyData.currentLessonCharacters.count - 1 ? AppTheme.textPrimary : AppTheme.cardBorder)
            }
            .disabled(studyData.activeCardIndex >= studyData.currentLessonCharacters.count - 1)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppTheme.cardBorder, lineWidth: 1)
        )
    }
}
