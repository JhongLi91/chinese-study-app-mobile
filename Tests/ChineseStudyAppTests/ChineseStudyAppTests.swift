import Testing
import Foundation
@testable import ChineseStudyApp

@Suite struct ChineseStudyAppTests {

    @Test func testDatabaseInitialLoadAndCounts() throws {
        let db = DatabaseManager.shared
        let allChars = db.fetchAllCharacters()
        #expect(allChars.count == 3000, "Should load all 3000 characters from bundled database")
        
        let lesson1Chars = db.fetchCharacters(forLesson: 1)
        #expect(lesson1Chars.count == 25, "Lesson 1 should contain exactly 25 characters")
        #expect(lesson1Chars.first?.character == "的一是不了人在有我他这中大人上个国到说们为子和地".prefix(1).description || lesson1Chars.first?.frequencyRank == 1)

        let stories = db.fetchStories()
        #expect(stories.count == 6, "Should load all 6 HSK stories")
    }

    @Test func testCharacterStatusMutations() throws {
        let db = DatabaseManager.shared
        // Update character #1 to learned
        db.updateCharacterStatus(rank: 1, status: .learned)
        let char1 = db.fetchCharacter(rank: 1)
        #expect(char1?.status == .learned)

        // Update character #2 to in-progress
        db.updateCharacterStatus(rank: 2, status: .inProgress)
        let char2 = db.fetchCharacter(rank: 2)
        #expect(char2?.status == .inProgress)

        // Reset lesson 1
        db.resetLessonProgress(lessonNumber: 1)
        let resetChar1 = db.fetchCharacter(rank: 1)
        #expect(resetChar1?.status == .new)
    }

    @Test func testLessonsProgressCalculation() throws {
        let db = DatabaseManager.shared
        let lessons = db.fetchAllLessons()
        #expect(lessons.count == 120, "Should calculate metrics for all 120 lessons")
    }
}
