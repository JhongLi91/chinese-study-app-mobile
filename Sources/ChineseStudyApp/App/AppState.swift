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

    public var systemImage: String {
        switch self {
        case .lessons: return "book.closed.fill"
        case .flashcards: return "rectangle.stack.fill"
        case .stories: return "text.book.closed.fill"
        case .match: return "gamecontroller.fill"
        case .review: return "list.bullet.rectangle.portrait.fill"
        case .settings: return "gearshape.fill"
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
    
    @AppStorage("isDarkMode") public var isDarkMode: Bool = true

    public init() {}

    public func navigateToLessonFlashcards(lessonNumber: Int) {
        self.activeLessonNumber = lessonNumber
        self.selectedTab = .flashcards
    }
}
