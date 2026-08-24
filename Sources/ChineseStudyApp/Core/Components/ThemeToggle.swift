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
            Image(appState.isDarkMode ? "moon" : "sun", bundle: .module)
                .resizable().renderingMode(.template).scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(AppTheme.textPrimary)
                .padding(8)
                .background(AppTheme.cardBackground)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
    }
}
