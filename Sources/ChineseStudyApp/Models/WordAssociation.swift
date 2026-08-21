import Foundation

/// Model representing a compound word collocation containing a target Hanzi.
public struct WordAssociation: Identifiable, Codable, Hashable, Sendable {
    public let id: Int
    public let characterId: Int
    public let characterChar: String
    public let word: String
    public let pinyin: String
    public let meaning: String

    public init(
        id: Int,
        characterId: Int,
        characterChar: String,
        word: String,
        pinyin: String,
        meaning: String
    ) {
        self.id = id
        self.characterId = characterId
        self.characterChar = characterChar
        self.word = word
        self.pinyin = pinyin
        self.meaning = meaning
    }
}
