import SwiftUI

public struct ThemeToggle: View {
    @EnvironmentObject var appState: AppState

    public init() {}

    public var body: some View {
        Button {
            withAnimation {
                appState.isDarkMode.toggle()
            }
        } label: {
            Image(systemName: appState.isDarkMode ? "moon.fill" : "sun.max.fill")
                .foregroundColor(AppTheme.textPrimary)
                .padding(8)
                .background(AppTheme.cardBackground)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
    }
}
