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

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .lessons: return "book"
        case .learned: return "check-circle"
        case .inProgress: return "clock"
        case .allHanzi: return "list"
        case .stories: return "book"
        case .match: return "gamepad-2"
        case .settings: return "settings"
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
    @Published public var isSidebarOpen: Bool = false
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

}
