import Foundation

/// Progress metrics and presentation data for a single curriculum lesson (1..120).
public struct LessonInfo: Identifiable, Codable, Hashable, Sendable {
    public var id: Int { lessonNumber }
    public let lessonNumber: Int
    public let totalCount: Int
    public var learnedCount: Int
    public var inProgressCount: Int
    public var newCount: Int

    public init(
        lessonNumber: Int,
        totalCount: Int = 25,
        learnedCount: Int = 0,
        inProgressCount: Int = 0,
        newCount: Int = 25
    ) {
        self.lessonNumber = lessonNumber
        self.totalCount = totalCount
        self.learnedCount = learnedCount
        self.inProgressCount = inProgressCount
        self.newCount = newCount
    }

    public var title: String {
        "Lesson \(lessonNumber)"
    }

    public var characterRangeString: String {
        let start = (lessonNumber - 1) * 25 + 1
        let end = min(lessonNumber * 25, 3000)
        return "#\(start) – #\(end)"
    }

    public var masteryPercentage: Double {
        guard totalCount > 0 else { return 0.0 }
        return (Double(learnedCount) / Double(totalCount)) * 100.0
    }

    public var isFullyLearned: Bool {
        learnedCount == totalCount && totalCount > 0
    }

    public var isInProgress: Bool {
        inProgressCount > 0 || (learnedCount > 0 && !isFullyLearned)
    }
}
