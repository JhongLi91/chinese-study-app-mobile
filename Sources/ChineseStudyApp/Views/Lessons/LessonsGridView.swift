import SwiftUI

/// Main grid view displaying all 120 lessons.
public struct LessonsGridView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var studyData: StudyDataViewModel
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    public init() {}

    public var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(studyData.lessons) { lesson in
                    Button {
                        appState.navigateToLessonFlashcards(lessonNumber: lesson.lessonNumber)
                    } label: {
                        LessonCardItemView(lesson: lesson)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
    }
}
