import Foundation
import SwiftUI
import Combine

/// Main navigation tabs available in the application.
public enum AppTab: String, CaseIterable, Identifiable, Sendable {
    case lessons = "Lessons Curriculum"
    case learned = "Learned Words"
    case inProgress = "In-Progress Words"
    case allHanzi = "All 3,000 Hanzi"
    
    case stories = "Story Reader"
    case match = "Word Match"
    case settings = "Settings"
    case flashcards = "Flashcards"

    public var id: String { rawValue }

    public var emoji: String {
        switch self {
        case .lessons: return "book"
        case .learned: return "checkmark.circle"
        case .inProgress: return "clock"
        case .allHanzi: return "square.stack.3d.up"
        case .stories: return "text.book.closed"
        case .match: return "bolt"
        case .settings: return "gearshape"
        case .flashcards: return "folder"
        }
    }
    
    public var isStudyPage: Bool {
        switch self {
        case .lessons, .learned, .inProgress, .allHanzi: return true
        default: return false
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
