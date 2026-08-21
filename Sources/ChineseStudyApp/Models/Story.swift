import Foundation

/// Sentence model for graded reading with pronunciation and English translation.
public struct StorySentence: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let zh: String
    public let py: String
    public let en: String

    public init(id: String, zh: String, py: String, en: String) {
        self.id = id
        self.zh = zh
        self.py = py
        self.en = en
    }
}

/// Paragraph model composed of sentence units and full paragraph translation.
public struct StoryParagraph: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let zh: String
    public let py: String
    public let en: String
    public let sentences: [StorySentence]

    public init(id: String, zh: String, py: String, en: String, sentences: [StorySentence] = []) {
        self.id = id
        self.zh = zh
        self.py = py
        self.en = en
        self.sentences = sentences
    }
}

/// Comprehension quiz question for reading verification.
public struct StoryQuizQuestion: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let question: String
    public let options: [String]
    public let correctAnswer: Int
    public let explanation: String

    public init(id: String, question: String, options: [String], correctAnswer: Int, explanation: String) {
        self.id = id
        self.question = question
        self.options = options
        self.correctAnswer = correctAnswer
        self.explanation = explanation
    }
}

/// Top-level story model for graded reading lessons.
public struct Story: Identifiable, Codable, Hashable, Sendable {
    public let id: String
    public let titleZh: String
    public let titlePy: String
    public let titleEn: String
    public let level: String
    public let source: String
    public let lessonTarget: String
    public let description: String
    public let paragraphs: [StoryParagraph]
    public let questions: [StoryQuizQuestion]

    public init(
        id: String,
        titleZh: String,
        titlePy: String,
        titleEn: String,
        level: String,
        source: String,
        lessonTarget: String,
        description: String,
        paragraphs: [StoryParagraph] = [],
        questions: [StoryQuizQuestion] = []
    ) {
        self.id = id
        self.titleZh = titleZh
        self.titlePy = titlePy
        self.titleEn = titleEn
        self.level = level
        self.source = source
        self.lessonTarget = lessonTarget
        self.description = description
        self.paragraphs = paragraphs
        self.questions = questions
    }
}
