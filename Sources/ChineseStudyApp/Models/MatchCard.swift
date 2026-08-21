import Foundation

/// Item type for a word match pairing tile (Hanzi glyph or English definition / pinyin).
public enum MatchItemType: String, Codable, Sendable {
    case character = "character"
    case definition = "definition"
    case word = "word"
}

/// A tile in the interactive Word Match mini-game.
public struct MatchCard: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let pairId: Int
    public let displayText: String
    public let subText: String?
    public let type: MatchItemType
    public var isSelected: Bool
    public var isMatched: Bool
    public var isWrong: Bool

    public init(
        id: String = UUID().uuidString,
        pairId: Int,
        displayText: String,
        subText: String? = nil,
        type: MatchItemType,
        isSelected: Bool = false,
        isMatched: Bool = false,
        isWrong: Bool = false
    ) {
        self.id = id
        self.pairId = pairId
        self.displayText = displayText
        self.subText = subText
        self.type = type
        self.isSelected = isSelected
        self.isMatched = isMatched
        self.isWrong = isWrong
    }
}
