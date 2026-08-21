import SwiftUI

/// Main content root view displaying the tab view.
public struct MainTabView: View {
    @EnvironmentObject var appState: AppState

    public init() {}

    public var body: some View {
        TabView(selection: $appState.selectedTab) {
            NavigationStack {
                LessonsGridView()
                    .navigationTitle(AppTab.lessons.rawValue)
            }
            .tabItem {
                Label(AppTab.lessons.rawValue, systemImage: AppTab.lessons.systemImage)
            }
            .tag(AppTab.lessons)

            NavigationStack {
                Text("Flashcards View")
                    .navigationTitle(AppTab.flashcards.rawValue)
            }
            .tabItem {
                Label(AppTab.flashcards.rawValue, systemImage: AppTab.flashcards.systemImage)
            }
            .tag(AppTab.flashcards)

            NavigationStack {
                Text("Stories View")
                    .navigationTitle(AppTab.stories.rawValue)
            }
            .tabItem {
                Label(AppTab.stories.rawValue, systemImage: AppTab.stories.systemImage)
            }
            .tag(AppTab.stories)

            NavigationStack {
                Text("Match Game View")
                    .navigationTitle(AppTab.match.rawValue)
            }
            .tabItem {
                Label(AppTab.match.rawValue, systemImage: AppTab.match.systemImage)
            }
            .tag(AppTab.match)

            NavigationStack {
                Text("Vocabulary View")
                    .navigationTitle(AppTab.review.rawValue)
            }
            .tabItem {
                Label(AppTab.review.rawValue, systemImage: AppTab.review.systemImage)
            }
            .tag(AppTab.review)

            NavigationStack {
                Text("Settings View")
                    .navigationTitle(AppTab.settings.rawValue)
            }
            .tabItem {
                Label(AppTab.settings.rawValue, systemImage: AppTab.settings.systemImage)
            }
            .tag(AppTab.settings)
        }
    }
}
