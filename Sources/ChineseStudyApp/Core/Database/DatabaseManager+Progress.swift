import Foundation
import SkipSQLCore
import SkipSQL

extension DatabaseManager {
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
}
