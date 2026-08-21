import SwiftUI

/// Main content root view displaying the tab view.
public struct ContentView: View {
    @EnvironmentObject var appState: AppState

    public init() {}

    public var body: some View {
        TabView(selection: $appState.selectedTab) {
            Text("Lessons View (120 Lessons)")
                .tabItem {
                    Label(AppTab.lessons.rawValue, systemImage: AppTab.lessons.systemImage)
                }
                .tag(AppTab.lessons)

            Text("Flashcards View")
                .tabItem {
                    Label(AppTab.flashcards.rawValue, systemImage: AppTab.flashcards.systemImage)
                }
                .tag(AppTab.flashcards)

            Text("Stories View")
                .tabItem {
                    Label(AppTab.stories.rawValue, systemImage: AppTab.stories.systemImage)
                }
                .tag(AppTab.stories)

            Text("Match Game View")
                .tabItem {
                    Label(AppTab.match.rawValue, systemImage: AppTab.match.systemImage)
                }
                .tag(AppTab.match)

            Text("Vocabulary View")
                .tabItem {
                    Label(AppTab.review.rawValue, systemImage: AppTab.review.systemImage)
                }
                .tag(AppTab.review)

            Text("Settings View")
                .tabItem {
                    Label(AppTab.settings.rawValue, systemImage: AppTab.settings.systemImage)
                }
                .tag(AppTab.settings)
        }
    }
}
