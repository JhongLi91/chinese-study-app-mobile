import Foundation
import SkipSQLCore
import SkipSQL

extension DatabaseManager {
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

        let sql = "SELECT id, session_type, start_time, duration_seconds, cards_reviewed, created_at FROM study_sessions ORDER BY created_at DESC LIMIT 100"
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
}
