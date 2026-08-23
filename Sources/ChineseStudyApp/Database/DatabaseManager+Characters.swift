import Foundation
import SkipSQLCore
import SkipSQL

extension DatabaseManager {
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

    func fetchWordAssociationsInternal(characterId: Int) -> [WordAssociation] {
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
}
