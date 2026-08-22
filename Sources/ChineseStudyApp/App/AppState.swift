import Foundation
import SwiftUI
import Combine

/// Main navigation tabs available in the application.
public enum AppTab: String, CaseIterable, Identifiable, Sendable {
    case lessons = "Lessons"
    case flashcards = "Flashcards"
    case stories = "Stories"
    case match = "Match"
    case review = "Vocab"
    case settings = "Settings"

    public var id: String { rawValue }

    public var emoji: String {
        switch self {
        case .lessons: return "📚"
        case .flashcards: return "🗂️"
        case .stories: return "📖"
        case .match: return "🎮"
        case .review: return "🔍"
        case .settings: return "⚙️"
        }
    }
}

/// Global application state managing tab navigation and audio preferences.
@MainActor
public final class AppState: ObservableObject {
    public static let shared = AppState()

    @Published public var selectedTab: AppTab = .lessons
    @Published public var activeLessonNumber: Int = 1
    @Published public var isSoundEffectsEnabled: Bool = true
    @Published public var speechRate: Double = 1.0
    @Published public var autoPlayAudioOnFlip: Bool = false
    
    @Published public var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    public init() {
        if UserDefaults.standard.object(forKey: "isDarkMode") != nil {
            self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        } else {
            self.isDarkMode = true
            UserDefaults.standard.set(true, forKey: "isDarkMode")
        }
    }

    public func navigateToLessonFlashcards(lessonNumber: Int) {
        self.activeLessonNumber = lessonNumber
        self.selectedTab = .flashcards
    }
}
