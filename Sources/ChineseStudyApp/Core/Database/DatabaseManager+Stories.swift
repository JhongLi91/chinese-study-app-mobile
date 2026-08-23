import Foundation
import SkipSQLCore
import SkipSQL

extension DatabaseManager {
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
}
