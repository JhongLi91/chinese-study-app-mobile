import SwiftUI

/// An individual card tile representing a single lesson in the curriculum grid.
public struct LessonCardItemView: View {
    public let lesson: LessonInfo

    public init(lesson: LessonInfo) {
        self.lesson = lesson
    }

    public var body: some View {
        Card(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lesson.title)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(lesson.characterRangeString)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        CircularProgressView(
                            progress: lesson.masteryPercentage / 100.0,
                            tintColor: AppTheme.statusLearned,
                            lineWidth: 6
                        )
                        .frame(width: 44, height: 44)
                        
                        if lesson.isFullyLearned {
                            Text("✔️")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.statusLearned)
                        } else {
                            Text("\(Int(lesson.masteryPercentage))%")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                        }
                    }
                }
                
                HStack(spacing: 8) {
                    StatusBadge(count: lesson.learnedCount, status: .learned)
                    StatusBadge(count: lesson.inProgressCount, status: .inProgress)
                    StatusBadge(count: lesson.newCount, status: .new)
                }
            }
        }
    }
}

private struct StatusBadge: View {
    let count: Int
    let status: StudyStatus
    
    var icon: String {
        switch status {
        case .learned: return "✅"
        case .inProgress: return "⏳"
        case .new: return "✨"
        }
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Text(icon)
                .font(.system(size: 10))
            Text("\(count)")
                .font(.caption2.bold())
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(AppTheme.color(forStatus: status).opacity(0.2))
        .foregroundColor(AppTheme.color(forStatus: status))
        .cornerRadius(8)
    }
}
