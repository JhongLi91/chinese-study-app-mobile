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
        case .lessons: return "book"
        case .flashcards: return "square.stack.3d.up"
        case .stories: return "doc.text"
        case .match: return "gamecontroller"
        case .review: return "magnifyingglass"
        case .settings: return "gear"
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
