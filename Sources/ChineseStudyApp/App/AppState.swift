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

/// Global application state managing navigation, stopwatch, and sound preferences.
@MainActor
public final class AppState: ObservableObject {
    public static let shared = AppState()

    @Published public var selectedTab: AppTab = .lessons
    @Published public var activeLessonNumber: Int = 1
    @Published public var isSoundEffectsEnabled: Bool = true
    @Published public var speechRate: Double = 1.0
    @Published public var autoPlayAudioOnFlip: Bool = false

    // Stopwatch State
    @Published public var stopwatchSeconds: Int = 0
    @Published public var isStopwatchRunning: Bool = false
    private var timerSubscription: AnyCancellable?

    public init() {
        startStopwatch()
    }

    public func startStopwatch() {
        guard !isStopwatchRunning else { return }
        isStopwatchRunning = true
        timerSubscription = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.isStopwatchRunning else { return }
                self.stopwatchSeconds += 1
            }
    }

    public func pauseStopwatch() {
        isStopwatchRunning = false
        timerSubscription?.cancel()
        timerSubscription = nil
    }

    public func resetStopwatch() {
        pauseStopwatch()
        stopwatchSeconds = 0
    }

    public var formattedStopwatchTime: String {
        let hours = stopwatchSeconds / 3600
        let minutes = (stopwatchSeconds % 3600) / 60
        let seconds = stopwatchSeconds % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    public func navigateToLessonFlashcards(lessonNumber: Int) {
        self.activeLessonNumber = lessonNumber
        self.selectedTab = .flashcards
    }
}
