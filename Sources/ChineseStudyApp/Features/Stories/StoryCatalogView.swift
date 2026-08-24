import SwiftUI

public struct StoryCatalogView: View {
    @ObservedObject private var storyViewModel = StoryViewModel.shared

    public init() {}

    public var body: some View {
        List(storyViewModel.stories) { story in
            NavigationLink(value: story) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(story.titleZh)
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text(story.titlePy)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(story.titleEn)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack {
                        BadgeView(text: "Level \(story.level)", color: AppTheme.statusLearned)
                        BadgeView(text: "Lesson \(story.lessonTarget)", color: AppTheme.statusInProgress)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .listStyle(.plain)
        .background(AppTheme.surfaceBackground)
        .navigationDestination(for: Story.self) { story in
            StoryDetailReaderView(story: story)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ThemeToggle()
            }
        }
    }
}

private struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(8)
    }
}
