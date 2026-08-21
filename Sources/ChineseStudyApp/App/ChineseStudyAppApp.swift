import Foundation
import OSLog
import SwiftUI

/// A logger for the ChineseStudyApp module.
public let logger: Logger = Logger(subsystem: "com.jhli.chinesestudy", category: "ChineseStudyApp")

/// The shared top-level view for the app, loaded from the platform-specific App delegates.
public struct ChineseStudyAppRootView: View {
    @StateObject private var appState = AppState.shared
    @StateObject private var studyData = StudyDataViewModel.shared

    public init() {}

    public var body: some View {
        MainTabView()
            .environmentObject(appState)
            .environmentObject(studyData)
            .task {
                logger.info("ChineseStudyApp launched successfully.")
            }
    }
}

/// Global application delegate functions for lifecycle events.
public final class ChineseStudyAppAppDelegate: Sendable {
    public static let shared = ChineseStudyAppAppDelegate()

    private init() {}

    public func onInit() {
        logger.debug("App initialized")
    }

    public func onLaunch() {
        logger.debug("App launched")
    }

    public func onResume() {
        logger.debug("App resumed")
    }

    public func onPause() {
        logger.debug("App paused")
    }

    public func onStop() {
        logger.debug("App stopped")
    }

    public func onDestroy() {
        logger.debug("App destroyed")
    }

    public func onLowMemory() {
        logger.debug("Low memory warning received")
    }
}
