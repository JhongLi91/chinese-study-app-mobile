import SwiftUI

/// Main content root view displaying the sidebar and main navigation.
public struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    public init() {}

    public var body: some View {
        ZStack(alignment: .leading) {
            // Main content
            mainContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Dimmed background for sidebar
            if appState.isSidebarOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            appState.isSidebarOpen = false
                        }
                    }
            }

            // Sidebar
            if appState.isSidebarOpen {
                SidebarView()
                    .frame(width: 280)
                    .transition(.move(edge: .leading))
                    .zIndex(2)
            }
        }
    }
    
    @ViewBuilder
    private var mainContent: some View {
        NavigationStack {
            Group {
                switch appState.selectedTab {
                case .lessons:
                    LessonsGridView()
                        .navigationTitle(AppTab.lessons.rawValue)
                case .learned, .inProgress, .allHanzi:
                    DictionarySearchView()
                        .id("DictionarySearchTabs") // Single static identity
                        .navigationTitle(appState.selectedTab.rawValue)
                        .onAppear { updateFilterStatus(for: appState.selectedTab) }
                        .onChange(of: appState.selectedTab) { _ in
                            updateFilterStatus(for: appState.selectedTab)
                        }
                case .stories:
                    StoryCatalogView()
                        .navigationTitle(AppTab.stories.rawValue)
                case .match:
                    WordMatchGameView()
                        .navigationTitle(AppTab.match.rawValue)
                case .settings:
                    SettingsView()
                        .navigationTitle(AppTab.settings.rawValue)
                }
            }
        }
    }
    
    private func updateFilterStatus(for tab: AppTab) {
        switch tab {
        case .learned:
            StudyDataViewModel.shared.selectedFilterStatus = .learned
        case .inProgress:
            StudyDataViewModel.shared.selectedFilterStatus = .inProgress
        case .allHanzi:
            StudyDataViewModel.shared.selectedFilterStatus = nil
        default:
            break
        }
    }
}
