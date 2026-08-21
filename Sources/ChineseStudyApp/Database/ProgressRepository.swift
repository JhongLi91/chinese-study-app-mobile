import Foundation

/// Repository protocol for managing user study progress and sessions.
public protocol ProgressRepositoryProtocol: Sendable {
    func getCharacters(forLesson lessonNumber: Int) -> [HanziCharacter]
    func getAllCharacters() -> [HanziCharacter]
    func getCharacter(rank: Int) -> HanziCharacter?
    func getCharacter(glyph: String) -> HanziCharacter?
    func getAllLessons() -> [LessonInfo]
    func updateStatus(for rank: Int, to status: StudyStatus)
    func batchUpdateStatus(for ranks: [Int], to status: StudyStatus)
    func resetLesson(lessonNumber: Int)
    func resetAll()
    func logSession(_ session: StudySession)
    func getSessions() -> [StudySession]
    func getStories() -> [Story]
    func getStory(id: String) -> Story?
    func exportProgress() -> [ProgressRecord]
    func restoreProgress(records: [ProgressRecord]) -> Int
}

/// Default production repository executing queries via DatabaseManager.
public final class ProgressRepository: ProgressRepositoryProtocol, @unchecked Sendable {
    public static let shared = ProgressRepository()
    private let db: DatabaseManager

    public init(db: DatabaseManager = .shared) {
        self.db = db
    }

    public func getCharacters(forLesson lessonNumber: Int) -> [HanziCharacter] {
        db.fetchCharacters(forLesson: lessonNumber)
    }

    public func getAllCharacters() -> [HanziCharacter] {
        db.fetchAllCharacters()
    }

    public func getCharacter(rank: Int) -> HanziCharacter? {
        db.fetchCharacter(rank: rank)
    }

    public func getCharacter(glyph: String) -> HanziCharacter? {
        db.fetchCharacter(byGlyph: glyph)
    }

    public func getAllLessons() -> [LessonInfo] {
        db.fetchAllLessons()
    }

    public func updateStatus(for rank: Int, to status: StudyStatus) {
        db.updateCharacterStatus(rank: rank, status: status)
    }

    public func batchUpdateStatus(for ranks: [Int], to status: StudyStatus) {
        db.batchUpdateCharacterStatus(ranks: ranks, status: status)
    }

    public func resetLesson(lessonNumber: Int) {
        db.resetLessonProgress(lessonNumber: lessonNumber)
    }

    public func resetAll() {
        db.resetAllProgress()
    }

    public func logSession(_ session: StudySession) {
        db.logStudySession(session: session)
    }

    public func getSessions() -> [StudySession] {
        db.fetchStudySessions()
    }

    public func getStories() -> [Story] {
        db.fetchStories()
    }

    public func getStory(id: String) -> Story? {
        db.fetchStory(id: id)
    }

    public func exportProgress() -> [ProgressRecord] {
        db.exportProgressSnapshot()
    }

    public func restoreProgress(records: [ProgressRecord]) -> Int {
        db.restoreProgressSnapshot(records: records)
    }
}
