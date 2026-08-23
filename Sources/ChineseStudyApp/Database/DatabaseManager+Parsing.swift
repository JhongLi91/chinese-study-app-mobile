import Foundation
import SkipSQLCore
import SkipSQL

extension DatabaseManager {
    func parseCharacter(row: [SQLValue]) -> HanziCharacter? {
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

    func parseWordAssociation(row: [SQLValue]) -> WordAssociation? {
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

    func extractString(from value: SQLValue) -> String? {
        if case .text(let str) = value { return str }
        return nil
    }

    func extractInt(from value: SQLValue) -> Int? {
        if case .long(let longNum) = value { return Int(longNum) }
        return nil
    }

    func extractInt64(from value: SQLValue) -> Int64? {
        if case .long(let longNum) = value { return longNum }
        return nil
    }
}
