import SwiftUI

public struct QuizSetupView: View {
    let sourceCharacters: [HanziCharacter]
    @Binding var selectedCount: Int
    let onStart: () -> Void
    
    let countOptions = [10, 20, 50]
    
    public var body: some View {
        VStack(spacing: 32) {
            Image(systemName: "questionmark.square.dashed")
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
                            Button {
                                selectedCount = count
                            } label: {
                                Text("\(count)")
                                    .font(.title3.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(selectedCount == count ? AppTheme.statusInProgress : AppTheme.cardBackground)
                                    .foregroundColor(selectedCount == count ? .white : AppTheme.textPrimary)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(selectedCount == count ? Color.clear : AppTheme.cardBorder, lineWidth: 2)
                                    )
                            }
                        }
                    }
                    
                    Button {
                        selectedCount = sourceCharacters.count
                    } label: {
                        Text("All (\(sourceCharacters.count))")
                            .font(.title3.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(selectedCount == sourceCharacters.count ? AppTheme.statusInProgress : AppTheme.cardBackground)
                            .foregroundColor(selectedCount == sourceCharacters.count ? .white : AppTheme.textPrimary)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedCount == sourceCharacters.count ? Color.clear : AppTheme.cardBorder, lineWidth: 2)
                            )
                    }
                }
                .padding()
                
                Button {
                    onStart()
                } label: {
                    Text("Start Quiz")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.statusLearned)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                }
            }
            Spacer()
        }
        .padding(.top, 40)
    }
}
