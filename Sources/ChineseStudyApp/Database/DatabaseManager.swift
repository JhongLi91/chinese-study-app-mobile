import Foundation
import SkipSQLCore
import SkipSQL

/// Thread-safe SQLite database manager for Chinese Study Mobile.
/// Handles character queries, learning status mutations, word associations, stories, and study sessions.
public final class DatabaseManager: @unchecked Sendable {
    public static let shared = DatabaseManager()

    private let lock = NSLock()
    private var context: SQLContext?
    public private(set) var dbPath: URL?

    public init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let fileManager = FileManager.default
            let appSupportDir = URL.applicationSupportDirectory

            if !fileManager.fileExists(atPath: appSupportDir.path) {
                try? fileManager.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
            }

            let destinationURL = appSupportDir.appendingPathComponent("hanzi_db.sqlite")
            self.dbPath = destinationURL

            // Copy pre-seeded database if it doesn't exist in app support
            if !fileManager.fileExists(atPath: destinationURL.path) {
                if let bundleURL = Bundle.module.url(forResource: "hanzi_db", withExtension: "sqlite") {
                    do {
                        let data = try Data(contentsOf: bundleURL)
                        try data.write(to: destinationURL)
                    } catch {
                        print("Failed to copy database: \(error)")
                    }
                } else {
                    print("Could not find hanzi_db.sqlite in bundle.")
                }
            }

            let ctx = try SQLContext(
                path: destinationURL.path,
                flags: [SQLContext.OpenFlags.create, SQLContext.OpenFlags.readWrite],
                configuration: SQLiteConfiguration.platform
            )
            self.context = ctx
            ensureSchema()
        } catch {
            print("Database initialization error: \(error)")
        }
    }

    private func ensureSchema() {
        guard let ctx = context else { return }
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS characters (
            frequency_rank INTEGER PRIMARY KEY,
            character TEXT NOT NULL,
            pinyin TEXT NOT NULL,
            definition TEXT NOT NULL,
            radical TEXT,
            radical_code TEXT,
            stroke_count INTEGER,
            hsk_level INTEGER,
            lesson_number INTEGER NOT NULL,
            example_zh TEXT,
            example_py TEXT,
            example_en TEXT
        );
        """)
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS progress (
            character_id INTEGER PRIMARY KEY,
            status TEXT NOT NULL CHECK(status IN ('new', 'in-progress', 'learned')),
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (character_id) REFERENCES characters(frequency_rank) ON DELETE CASCADE
        );
        """)
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS word_associations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL,
            character_char TEXT NOT NULL,
            word TEXT NOT NULL,
            pinyin TEXT NOT NULL,
            meaning TEXT NOT NULL,
            FOREIGN KEY (character_id) REFERENCES characters(frequency_rank)
        );
        """)
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS stories (
            id TEXT PRIMARY KEY,
            title_zh TEXT NOT NULL,
            title_py TEXT NOT NULL,
            title_en TEXT NOT NULL,
            level TEXT NOT NULL,
            source TEXT NOT NULL,
            lesson_target TEXT NOT NULL,
            description TEXT NOT NULL,
            data_json TEXT NOT NULL
        );
        """)
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS study_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_type TEXT NOT NULL,
            start_time INTEGER NOT NULL,
            duration_seconds INTEGER NOT NULL,
            cards_reviewed INTEGER NOT NULL,
            created_at INTEGER NOT NULL
        );
        """)
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_characters_lesson ON characters(lesson_number);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_characters_char ON characters(character);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_characters_hsk ON characters(hsk_level);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_progress_status ON progress(status);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_word_assoc_char_id ON word_associations(character_id);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_word_assoc_word ON word_associations(word);")
    }

    // MARK: - Characters Queries

    public func fetchAllCharacters() -> [HanziCharacter] {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return [] }

        let sql = """
        SELECT c.frequency_rank, c.character, c.pinyin, c.definition, c.radical, c.radical_code,
               c.stroke_count, c.hsk_level, c.lesson_number, c.example_zh, c.example_py, c.example_en,
               p.status, p.updated_at
        FROM characters c
        LEFT JOIN progress p ON c.frequency_rank = p.character_id
        ORDER BY c.frequency_rank ASC
        """

        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql)) ?? []
        var results: [HanziCharacter] = []
        for row in rows {
            if let char = parseCharacter(row: row) {
                results.append(char)
            }
        }
        return results
    }

    public func fetchCharacters(forLesson lessonNumber: Int) -> [HanziCharacter] {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return [] }

        let sql = """
        SELECT c.frequency_rank, c.character, c.pinyin, c.definition, c.radical, c.radical_code,
               c.stroke_count, c.hsk_level, c.lesson_number, c.example_zh, c.example_py, c.example_en,
               p.status, p.updated_at
        FROM characters c
        LEFT JOIN progress p ON c.frequency_rank = p.character_id
        WHERE c.lesson_number = ?
        ORDER BY c.frequency_rank ASC
        """

        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql, parameters: [SQLValue.long(Int64(lessonNumber))])) ?? []
        var results: [HanziCharacter] = []
        for row in rows {
            if let char = parseCharacter(row: row) {
                results.append(char)
            }
        }
        return results
    }

    public func fetchCharacter(rank: Int) -> HanziCharacter? {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return nil }

        let sql = """
        SELECT c.frequency_rank, c.character, c.pinyin, c.definition, c.radical, c.radical_code,
               c.stroke_count, c.hsk_level, c.lesson_number, c.example_zh, c.example_py, c.example_en,
               p.status, p.updated_at
        FROM characters c
        LEFT JOIN progress p ON c.frequency_rank = p.character_id
        WHERE c.frequency_rank = ?
        LIMIT 1
        """

        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql, parameters: [SQLValue.long(Int64(rank))])) ?? []
        guard let first = rows.first, let char = parseCharacter(row: first) else { return nil }
        var result = char
        result.wordAssociations = fetchWordAssociationsInternal(characterId: rank)
        return result
    }

    public func fetchCharacter(byGlyph glyph: String) -> HanziCharacter? {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return nil }

        let sql = """
        SELECT c.frequency_rank, c.character, c.pinyin, c.definition, c.radical, c.radical_code,
               c.stroke_count, c.hsk_level, c.lesson_number, c.example_zh, c.example_py, c.example_en,
               p.status, p.updated_at
        FROM characters c
        LEFT JOIN progress p ON c.frequency_rank = p.character_id
        WHERE c.character = ?
        LIMIT 1
        """

        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql, parameters: [SQLValue.text(glyph)])) ?? []
        guard let first = rows.first, let char = parseCharacter(row: first) else { return nil }
        var result = char
        result.wordAssociations = fetchWordAssociationsInternal(characterId: result.frequencyRank)
        return result
    }

    // MARK: - Word Associations

    public func fetchWordAssociations(for characterId: Int) -> [WordAssociation] {
        lock.lock()
        defer { lock.unlock() }
        return fetchWordAssociationsInternal(characterId: characterId)
    }

    private func fetchWordAssociationsInternal(characterId: Int) -> [WordAssociation] {
        guard let ctx = context else { return [] }
        let sql = """
        SELECT id, character_id, character_char, word, pinyin, meaning
        FROM word_associations
        WHERE character_id = ?
        ORDER BY id ASC
        """
        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql, parameters: [SQLValue.long(Int64(characterId))])) ?? []
        var results: [WordAssociation] = []
        for row in rows {
            if let assoc = parseWordAssociation(row: row) {
                results.append(assoc)
            }
        }
        return results
    }

    // MARK: - Lessons & Progress Calculations

    public func fetchAllLessons() -> [LessonInfo] {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return [] }

        let sql = """
        SELECT c.lesson_number,
               COUNT(c.frequency_rank) as total,
               SUM(CASE WHEN p.status = 'learned' THEN 1 ELSE 0 END) as learned,
               SUM(CASE WHEN p.status = 'in-progress' THEN 1 ELSE 0 END) as in_progress
        FROM characters c
        LEFT JOIN progress p ON c.frequency_rank = p.character_id
        GROUP BY c.lesson_number
        ORDER BY c.lesson_number ASC
        """

        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql)) ?? []
        var results: [LessonInfo] = []
        for row in rows {
            guard row.count >= 4 else { continue }
            guard let lessonNum = extractInt(from: row[0]) else { continue }
            let total = extractInt(from: row[1]) ?? 25
            let learned = extractInt(from: row[2]) ?? 0
            let inProgress = extractInt(from: row[3]) ?? 0
            let newCount = max(0, total - learned - inProgress)
            results.append(LessonInfo(
                lessonNumber: lessonNum,
                totalCount: total,
                learnedCount: learned,
                inProgressCount: inProgress,
                newCount: newCount
            ))
        }
        return results
    }

    // MARK: - Status Mutations

    public func updateCharacterStatus(rank: Int, status: StudyStatus) {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return }

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let sql = """
        INSERT INTO progress (character_id, status, updated_at)
        VALUES (?, ?, ?)
        ON CONFLICT(character_id) DO UPDATE SET
            status = excluded.status,
            updated_at = excluded.updated_at
        """
        try? ctx.exec(
            sql: sql,
            parameters: [
                SQLValue.long(Int64(rank)),
                SQLValue.text(status.rawValue),
                SQLValue.long(timestamp)
            ]
        )
    }

    public func batchUpdateCharacterStatus(ranks: [Int], status: StudyStatus) {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context, !ranks.isEmpty else { return }

        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let sql = """
        INSERT INTO progress (character_id, status, updated_at)
        VALUES (?, ?, ?)
        ON CONFLICT(character_id) DO UPDATE SET
            status = excluded.status,
            updated_at = excluded.updated_at
        """

        try? ctx.transaction {
            guard let stmt = try? ctx.prepare(sql: sql) else { return }
            defer { try? stmt.close() }
            for rank in ranks {
                try? stmt.update(parameters: [
                    SQLValue.long(Int64(rank)),
                    SQLValue.text(status.rawValue),
                    SQLValue.long(timestamp)
                ])
            }
        }
    }

    public func resetLessonProgress(lessonNumber: Int) {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return }

        let sql = """
        DELETE FROM progress
        WHERE character_id IN (
            SELECT frequency_rank FROM characters WHERE lesson_number = ?
        )
        """
        try? ctx.exec(sql: sql, parameters: [SQLValue.long(Int64(lessonNumber))])
    }

    public func resetAllProgress() {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return }
        try? ctx.exec(sql: "DELETE FROM progress")
    }

    // MARK: - Stories Queries

    public func fetchStories() -> [Story] {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return [] }

        let sql = "SELECT id, data_json FROM stories ORDER BY id ASC"
        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql)) ?? []
        let decoder = JSONDecoder()
        var results: [Story] = []

        for row in rows {
            guard row.count >= 2, let jsonStr = extractString(from: row[1]) else { continue }
            guard let data = jsonStr.data(using: .utf8) else { continue }
            if let story = try? decoder.decode(Story.self, from: data) {
                results.append(story)
            }
        }
        return results
    }

    public func fetchStory(id: String) -> Story? {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return nil }

        let sql = "SELECT data_json FROM stories WHERE id = ? LIMIT 1"
        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql, parameters: [SQLValue.text(id)])) ?? []
        guard let first = rows.first, let jsonStr = extractString(from: first[0]) else { return nil }
        guard let data = jsonStr.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(Story.self, from: data)
    }

    // MARK: - Study Sessions Logging

    public func logStudySession(session: StudySession) {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return }

        let sql = """
        INSERT INTO study_sessions (session_type, start_time, duration_seconds, cards_reviewed, created_at)
        VALUES (?, ?, ?, ?, ?)
        """
        try? ctx.exec(
            sql: sql,
            parameters: [
                SQLValue.text(session.sessionType),
                SQLValue.long(session.startTime),
                SQLValue.long(Int64(session.durationSeconds)),
                SQLValue.long(Int64(session.cardsReviewed)),
                SQLValue.long(session.createdAt)
            ]
        )
    }

    public func fetchStudySessions() -> [StudySession] {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return [] }

        let sql = "SELECT id, session_type, start_time, duration_seconds, cards_reviewed, created_at FROM study_sessions ORDER BY created_at DESC"
        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql)) ?? []
        var results: [StudySession] = []

        for row in rows {
            guard row.count >= 6 else { continue }
            let id = extractInt(from: row[0])
            guard let type = extractString(from: row[1]),
                  let start = extractInt64(from: row[2]),
                  let duration = extractInt(from: row[3]),
                  let cards = extractInt(from: row[4]),
                  let created = extractInt64(from: row[5]) else { continue }

            results.append(StudySession(
                id: id,
                sessionType: type,
                startTime: start,
                durationSeconds: duration,
                cardsReviewed: cards,
                createdAt: created
            ))
        }
        return results
    }

    // MARK: - Backup & Snapshot

    public func exportProgressSnapshot() -> [ProgressRecord] {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context else { return [] }

        let sql = "SELECT character_id, status, updated_at FROM progress"
        let rows: [[SQLValue]] = (try? ctx.selectAll(sql: sql)) ?? []
        var results: [ProgressRecord] = []

        for row in rows {
            guard row.count >= 3,
                  let rank = extractInt(from: row[0]),
                  let status = extractString(from: row[1]),
                  let updated = extractInt64(from: row[2]) else { continue }
            results.append(ProgressRecord(
                rank: rank,
                status: status,
                updatedAt: updated
            ))
        }
        return results
    }

    public func restoreProgressSnapshot(records: [ProgressRecord]) -> Int {
        lock.lock()
        defer { lock.unlock() }
        guard let ctx = context, !records.isEmpty else { return 0 }

        var restoredCount = 0
        try? ctx.transaction {
            let sql = """
            INSERT INTO progress (character_id, status, updated_at)
            VALUES (?, ?, ?)
            ON CONFLICT(character_id) DO UPDATE SET
                status = excluded.status,
                updated_at = excluded.updated_at
            """
            guard let stmt = try? ctx.prepare(sql: sql) else { return }
            defer { try? stmt.close() }

            for rec in records {
                try? stmt.update(parameters: [
                    SQLValue.long(Int64(rec.rank)),
                    SQLValue.text(rec.status),
                    SQLValue.long(rec.updatedAt)
                ])
                restoredCount += 1
            }
        }
        return restoredCount
    }

    // MARK: - Row Parsing Helpers

    private func parseCharacter(row: [SQLValue]) -> HanziCharacter? {
        guard row.count >= 12 else { return nil }
        guard let rank = extractInt(from: row[0]),
              let char = extractString(from: row[1]),
              let pinyin = extractString(from: row[2]),
              let definition = extractString(from: row[3]),
              let lesson = extractInt(from: row[8]) else {
            return nil
        }

        let radical = extractString(from: row[4])
        let radicalCode = extractString(from: row[5])
        let strokeCount = extractInt(from: row[6])
        let hskLevel = extractInt(from: row[7])
        let exZh = extractString(from: row[9])
        let exPy = extractString(from: row[10])
        let exEn = extractString(from: row[11])

        let statusRaw = row.count > 12 ? extractString(from: row[12]) : nil
        let status = statusRaw.flatMap { StudyStatus(rawValue: $0) } ?? .new
        let updatedAt = row.count > 13 ? extractInt64(from: row[13]) : nil

        return HanziCharacter(
            frequencyRank: rank,
            character: char,
            pinyin: pinyin,
            definition: definition,
            radical: radical,
            radicalCode: radicalCode,
            strokeCount: strokeCount,
            hskLevel: hskLevel,
            lessonNumber: lesson,
            exampleZh: exZh,
            examplePy: exPy,
            exampleEn: exEn,
            status: status,
            updatedAt: updatedAt,
            wordAssociations: []
        )
    }

    private func parseWordAssociation(row: [SQLValue]) -> WordAssociation? {
        guard row.count >= 6,
              let id = extractInt(from: row[0]),
              let charId = extractInt(from: row[1]),
              let char = extractString(from: row[2]),
              let word = extractString(from: row[3]),
              let pinyin = extractString(from: row[4]),
              let meaning = extractString(from: row[5]) else {
            return nil
        }

        return WordAssociation(
            id: id,
            characterId: charId,
            characterChar: char,
            word: word,
            pinyin: pinyin,
            meaning: meaning
        )
    }

    private func extractString(from value: SQLValue) -> String? {
        if case .text(let str) = value { return str }
        return nil
    }

    private func extractInt(from value: SQLValue) -> Int? {
        if case .long(let longNum) = value { return Int(longNum) }
        return nil
    }

    private func extractInt64(from value: SQLValue) -> Int64? {
        if case .long(let longNum) = value { return longNum }
        return nil
    }
}
