import SwiftUI

/// Main grid view displaying all 120 lessons.
public struct LessonsGridView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var studyData: StudyDataViewModel
    
    // Grid columns handled manually via chunked HStack

    public init() {}

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                let chunks = stride(from: 0, to: studyData.lessons.count, by: 10).map {
                    Array(studyData.lessons[$0 ..< Swift.min($0 + 10, studyData.lessons.count)])
                }
                
                ForEach(0..<chunks.count, id: \.self) { chunkIndex in
                    LessonChunkView(chunk: chunks[chunkIndex])
                }
            }
            .padding(16)
        }
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
        .navigationDestination(for: Int.self) { lessonNumber in
            FlashcardStudyView()
                .navigationTitle("Lesson \(lessonNumber)")
                .onAppear {
                    studyData.loadLesson(lessonNumber: lessonNumber)
                }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ThemeToggle()
            }
        }
    }
}

private struct LessonChunkView: View {
    let chunk: [LessonInfo]
    @EnvironmentObject var studyData: StudyDataViewModel
    @State private var isExpanded: Bool = false

    var body: some View {
        if let first = chunk.first, let last = chunk.last {
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text("Lessons \(first.lessonNumber) - \(last.lessonNumber)")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(isExpanded ? 90.0 : 0.0))
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding()
                
                if isExpanded {
                    let rowCount = (chunk.count + 1) / 2
                    VStack(spacing: 16) {
                        ForEach(0..<rowCount, id: \.self) { rowIndex in
                            HStack(spacing: 16) {
                                let firstIndex = rowIndex * 2
                                let secondIndex = firstIndex + 1
                                
                                if firstIndex < chunk.count {
                                    lessonButton(for: chunk[firstIndex])
                                }
                                
                                if secondIndex < chunk.count {
                                    lessonButton(for: chunk[secondIndex])
                                } else {
                                    Color.clear.frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }

    private func lessonButton(for lesson: LessonInfo) -> some View {
        NavigationLink(value: lesson.lessonNumber) {
            LessonCardItemView(lesson: lesson)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
