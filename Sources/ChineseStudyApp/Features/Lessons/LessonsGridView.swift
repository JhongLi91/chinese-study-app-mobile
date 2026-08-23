import SwiftUI

/// Main grid view displaying all 120 lessons.
public struct LessonsGridView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var studyData: StudyDataViewModel
    
    // Grid columns handled manually via chunked HStack

    public init() {}

    public var body: some View {
        ScrollView {
            // By using a non-lazy VStack for a relatively small dataset (120 items),
            // we render all rows up-front. This completely eliminates initialization
            // stutter during fast scrolling gestures on both iOS and Android.
            VStack(spacing: 16) {
                let rowCount = (studyData.lessons.count + 1) / 2
                ForEach(0..<rowCount, id: \.self) { rowIndex in
                    HStack(spacing: 16) {
                        let firstIndex = rowIndex * 2
                        let secondIndex = firstIndex + 1
                        
                        if firstIndex < studyData.lessons.count {
                            lessonButton(for: studyData.lessons[firstIndex])
                        }
                        
                        if secondIndex < studyData.lessons.count {
                            lessonButton(for: studyData.lessons[secondIndex])
                        } else {
                            // Invisible spacer block to keep the last odd item aligned to the leading edge
                            Color.clear
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                ThemeToggle()
            }
        }
    }
    
    private func lessonButton(for lesson: LessonInfo) -> some View {
        Button {
            appState.navigateToLessonFlashcards(lessonNumber: lesson.lessonNumber)
        } label: {
            LessonCardItemView(lesson: lesson)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
