import SwiftUI

public struct ExampleSentenceSheet: View {
    let character: HanziCharacter
    @Environment(\.dismiss) var dismiss

    public init(character: HanziCharacter) {
        self.character = character
    }

    public var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                if let exampleZh = character.exampleZh,
                   let examplePy = character.examplePy,
                   let exampleEn = character.exampleEn {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Example Sentence")
                            .font(.headline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        Text(exampleZh)
                            .font(.title2.bold())
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Text(examplePy)
                            .font(.title3)

                        
                        Text(exampleEn)
                            .font(.body)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(16)
                    
                    Button {
                        AudioService.shared.speak(text: exampleZh, rate: AppState.shared.speechRate)
                    } label: {
                        HStack {
                            Image(systemName: "speaker.fill")
                            Text("Play Audio")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.statusNew)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    Text("No example sentence available.")
                        .foregroundColor(AppTheme.textSecondary)
                }

                Spacer()
            }
            .padding()
            .background(AppTheme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Examples: \(character.character)")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
