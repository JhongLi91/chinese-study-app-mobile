import SwiftUI

public struct QuizSetupView: View {
    let sourceCharacters: [HanziCharacter]
    @Binding var selectedCount: Int
    let onStart: () -> Void
    
    let countOptions = [10, 20, 50]
    
    public var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 80))
                .foregroundColor(AppTheme.statusInProgress)
            
            VStack(spacing: 8) {
                Text("Ready for a quick review?")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                Text("Available pool: \(sourceCharacters.count) characters")
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            if sourceCharacters.isEmpty {
                Text("No characters available to quiz.")
                    .foregroundColor(AppTheme.tone1)
                    .padding()
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Select Quiz Length:")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    HStack(spacing: 16) {
                        ForEach(countOptions, id: \.self) { count in
                            ModernButton(
                                title: "\(count)",
                                variant: selectedCount == count ? .default : .outline
                            ) {
                                selectedCount = count
                            }
                        }
                    }
                    
                    ModernButton(
                        title: "All (\(sourceCharacters.count))",
                        variant: selectedCount == sourceCharacters.count ? .default : .outline
                    ) {
                        selectedCount = sourceCharacters.count
                    }
                }
                .padding()
                
                ModernButton(title: "Start Quiz", systemImage: "play.fill", variant: .default, size: .lg) {
                    onStart()
                }
                .padding(.horizontal)
            }
            Spacer()
        }
        .padding(.top, 40)
    }
}
