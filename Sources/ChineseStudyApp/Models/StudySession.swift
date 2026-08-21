import Foundation

/// Represents a study timer logging entry.
public struct StudySession: Identifiable, Codable, Hashable, Sendable {
    public let id: Int?
    public let sessionType: String
    public let startTime: Int64
    public let durationSeconds: Int
    public let cardsReviewed: Int
    public let createdAt: Int64

    public init(
        id: Int? = nil,
        sessionType: String,
        startTime: Int64,
        durationSeconds: Int,
        cardsReviewed: Int,
        createdAt: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    ) {
        self.id = id
        self.sessionType = sessionType
        self.startTime = startTime
        self.durationSeconds = durationSeconds
        self.cardsReviewed = cardsReviewed
        self.createdAt = createdAt
    }
}
