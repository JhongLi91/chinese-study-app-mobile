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
                Text("\(AppTab.lessons.emoji) \(AppTab.lessons.rawValue)")
            }
            .tag(AppTab.lessons)

            NavigationStack {
                FlashcardStudyView()
                    .navigationTitle("Review")
            }
            .tabItem {
                Text("\(AppTab.flashcards.emoji) \(AppTab.flashcards.rawValue)")
            }
            .tag(AppTab.flashcards)

            NavigationStack {
                StoryCatalogView()
                    .navigationTitle(AppTab.stories.rawValue)
            }
            .tabItem {
                Text("\(AppTab.stories.emoji) \(AppTab.stories.rawValue)")
            }
            .tag(AppTab.stories)

            NavigationStack {
                WordMatchGameView()
                    .navigationTitle(AppTab.match.rawValue)
            }
            .tabItem {
                Text("\(AppTab.match.emoji) \(AppTab.match.rawValue)")
            }
            .tag(AppTab.match)

            NavigationStack {
                DictionarySearchView()
                    .navigationTitle("Dictionary")
            }
            .tabItem {
                Text("\(AppTab.review.emoji) \(AppTab.review.rawValue)")
            }
            .tag(AppTab.review)

            NavigationStack {
                SettingsView()
                    .navigationTitle(AppTab.settings.rawValue)
            }
            .tabItem {
                Text("\(AppTab.settings.emoji) \(AppTab.settings.rawValue)")
            }
            .tag(AppTab.settings)
        }
    }
}
