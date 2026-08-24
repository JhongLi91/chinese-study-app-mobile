import SwiftUI

public struct CharacterDetailView: View {
    let character: HanziCharacter

    public init(character: HanziCharacter) {
        self.character = character
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Character
                VStack(spacing: 8) {
                    Text(character.character)
                        .font(.system(size: 100, weight: .bold))

                    
                    Text(character.pinyin)
                        .font(.largeTitle)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Button {
                        AudioService.shared.speak(text: character.character, rate: AppState.shared.speechRate)
                    } label: {
                        Image(systemName: "speaker.fill")
                            .font(.title2)
                            .foregroundColor(AppTheme.statusInProgress)
                            .padding()
                            .background(AppTheme.cardBackground)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(AppTheme.cardBackground)
                
                // Definition Box
                VStack(alignment: .leading, spacing: 12) {
                    Text("Definition")
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(character.definition)
                        .font(.title3)
                        .foregroundColor(AppTheme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(AppTheme.cardBackground)
                .cornerRadius(12)
                .padding(.horizontal)

                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    StatBox(title: "Rank", value: "#\(character.frequencyRank)")
                    if let radical = character.radical {
                        StatBox(title: "Radical", value: radical)
                    }
                    if let strokes = character.strokeCount {
                        StatBox(title: "Strokes", value: "\(strokes)")
                    }
                    if let hsk = character.hskLevel {
                        StatBox(title: "HSK Level", value: "\(hsk)")
                    }
                    StatBox(title: "Lesson", value: "\(character.lessonNumber)")
                }
                .padding(.horizontal)
                
                // Word Associations (Compounds)
                if !character.wordAssociations.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Compound Words")
                            .font(.headline)
                            .foregroundColor(AppTheme.textSecondary)
                            .padding(.horizontal)
                        
                        ForEach(character.wordAssociations) { assoc in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Text(assoc.word)
                                        .font(.title2.bold())
                                        .foregroundColor(AppTheme.textPrimary)
                                    Spacer()
                                    Button {
                                        AudioService.shared.speak(text: assoc.word, rate: AppState.shared.speechRate)
                                    } label: {
                                        Image(systemName: "speaker.fill")
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }
                                
                                Text(assoc.pinyin)
                                    .font(.subheadline)
                                    .foregroundColor(AppTheme.statusInProgress)
                                
                                Text(assoc.meaning)
                                    .font(.body)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding()
                            .background(AppTheme.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                }
                
                Spacer(minLength: 40)
            }
        }
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
        .navigationTitle(character.character)
    }
}

private struct StatBox: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
            Text(value)
                .font(.headline)
                .foregroundColor(AppTheme.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppTheme.cardBackground)
        .cornerRadius(12)
    }
}
