import Foundation

/// Represents the learning status of a character.
public enum StudyStatus: String, Codable, CaseIterable, Sendable {
    case new = "new"
    case inProgress = "in-progress"
    case learned = "learned"

    public var title: String {
        switch self {
        case .new: return "New"
        case .inProgress: return "In-Progress"
        case .learned: return "Learned"
        }
    }

    public var systemImage: String {
        switch self {
        case .new: return "sparkles"
        case .inProgress: return "clock.arrow.circlepath"
        case .learned: return "checkmark.circle.fill"
        }
    }
}

/// A serialized progress snapshot record for backup and migration.
public struct ProgressRecord: Codable, Hashable, Sendable {
    public let rank: Int
    public let status: String
    public let updatedAt: Int64

    public init(rank: Int, status: String, updatedAt: Int64) {
        self.rank = rank
        self.status = status
        self.updatedAt = updatedAt
    }
}

/// Core domain model for a Chinese character (Hanzi).
public struct HanziCharacter: Identifiable, Codable, Hashable, Sendable {
    public var id: Int { frequencyRank }
    public let frequencyRank: Int
    public let character: String
    public let pinyin: String
    public let definition: String
    public let radical: String?
    public let radicalCode: String?
    public let strokeCount: Int?
    public let hskLevel: Int?
    public let lessonNumber: Int
    public let exampleZh: String?
    public let examplePy: String?
    public let exampleEn: String?
    
    public var status: StudyStatus
    public var updatedAt: Int64?
    public var wordAssociations: [WordAssociation]

    public init(
        frequencyRank: Int,
        character: String,
        pinyin: String,
        definition: String,
        radical: String? = nil,
        radicalCode: String? = nil,
        strokeCount: Int? = nil,
        hskLevel: Int? = nil,
        lessonNumber: Int,
        exampleZh: String? = nil,
        examplePy: String? = nil,
        exampleEn: String? = nil,
        status: StudyStatus = .new,
        updatedAt: Int64? = nil,
        wordAssociations: [WordAssociation] = []
    ) {
        self.frequencyRank = frequencyRank
        self.character = character
        self.pinyin = pinyin
        self.definition = definition
        self.radical = radical
        self.radicalCode = radicalCode
        self.strokeCount = strokeCount
        self.hskLevel = hskLevel
        self.lessonNumber = lessonNumber
        self.exampleZh = exampleZh
        self.examplePy = examplePy
        self.exampleEn = exampleEn
        self.status = status
        self.updatedAt = updatedAt
        self.wordAssociations = wordAssociations
    }

    /// Determines Mandarin tone number (1-5) from pinyin for visual styling.
    public var toneNumber: Int {
        let p = pinyin.lowercased()
        // Tone 1: ā, ē, ī, ō, ū, ǖ
        if p.contains("ā") || p.contains("ē") || p.contains("ī") || p.contains("ō") || p.contains("ū") || p.contains("ǖ") {
            return 1
        }
        // Tone 2: á, é, í, ó, ú, ǘ
        if p.contains("á") || p.contains("é") || p.contains("í") || p.contains("ó") || p.contains("ú") || p.contains("ǘ") {
            return 2
        }
        // Tone 3: ǎ, ě, ǐ, ǒ, ǔ, ǚ
        if p.contains("ǎ") || p.contains("ě") || p.contains("ǐ") || p.contains("ǒ") || p.contains("ǔ") || p.contains("ǚ") {
            return 3
        }
        // Tone 4: à, è, ì, ò, ù, ǜ
        if p.contains("à") || p.contains("è") || p.contains("ì") || p.contains("ò") || p.contains("ù") || p.contains("ǜ") {
            return 4
        }
        // Neutral tone
        return 5
    }

    /// Primary clean single-line English gloss
    public var cleanDefinition: String {
        definition.components(separatedBy: ";").first?.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? definition
    }
}

public typealias Character = HanziCharacter
