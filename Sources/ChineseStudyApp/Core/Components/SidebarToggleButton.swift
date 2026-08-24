import SwiftUI

public struct SidebarToggleButton: View {
    @EnvironmentObject var appState: AppState

    public init() {}

    public var body: some View {
        Button(action: {
            withAnimation {
                appState.isSidebarOpen.toggle()
            }
        }) {
            Image("menu", bundle: .module).resizable().renderingMode(.template).scaledToFit()
                .frame(width: 22, height: 22)
                .foregroundColor(.primary)
        }
    }
}
