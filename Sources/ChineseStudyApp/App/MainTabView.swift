import SwiftUI

/// Main content root view displaying the sidebar and main navigation.
public struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    @State private var isSidebarOpen = false

    public init() {}

    public var body: some View {
        ZStack(alignment: .leading) {
            // Main content
            mainContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Dimmed background for sidebar
            if isSidebarOpen {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isSidebarOpen = false
                        }
                    }
            }

            // Sidebar
            if isSidebarOpen {
                SidebarView(isSidebarOpen: $isSidebarOpen)
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
                case .learned:
                    DictionarySearchView()
                        .navigationTitle(AppTab.learned.rawValue)
                        .onAppear { StudyDataViewModel.shared.selectedFilterStatus = .learned }
                case .inProgress:
                    DictionarySearchView()
                        .navigationTitle(AppTab.inProgress.rawValue)
                        .onAppear { StudyDataViewModel.shared.selectedFilterStatus = .inProgress }
                case .allHanzi:
                    DictionarySearchView()
                        .navigationTitle(AppTab.allHanzi.rawValue)
                        .onAppear { StudyDataViewModel.shared.selectedFilterStatus = nil }
                case .flashcards:
                    FlashcardStudyView()
                        .navigationTitle("Review")
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
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: {
                        withAnimation {
                            isSidebarOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}
