import SwiftUI

public struct FlashcardView: View {
    public let character: HanziCharacter
    public let isFlipped: Bool

    public init(character: HanziCharacter, isFlipped: Bool) {
        self.character = character
        self.isFlipped = isFlipped
    }

    public var body: some View {
        Card(padding: 0) {
            ZStack {
                if isFlipped {
                    backView
                } else {
                    frontView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .rotation3DEffect(.degrees(isFlipped ? 180.0 : 0.0), axis: (x: 0.0, y: 1.0, z: 0.0))
    }

    private var frontView: some View {
        VStack {
            HStack {
                Text("#\(character.frequencyRank)")
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.textSecondary)
                    .padding(8)
                    .background(AppTheme.cardBorder)
                    .cornerRadius(8)
                Spacer()
                Text("Lesson \(character.lessonNumber)")
                    .font(.subheadline.bold())
                    .foregroundColor(AppTheme.textSecondary)
            }
            .padding()

            Spacer()

            Text(character.character)
                .font(.system(size: 120, weight: .bold))


            Spacer()
        }
    }

    private var backView: some View {
        VStack(spacing: 20) {
            HStack {
                Text(character.character)
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Image("volume-2", bundle: .module).resizable().renderingMode(.template).scaledToFit()
                    .foregroundColor(AppTheme.primary)
                    .frame(width: 22, height: 22)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)

            Spacer()

            VStack(spacing: 16) {
                Text(character.pinyin)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.primary)
    
                Text(character.definition)
                    .font(.title3)
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()

            Divider()
                .background(AppTheme.cardBorder)
                .padding(.horizontal, 24)

            HStack(spacing: 36) {
                if let radical = character.radical, !radical.isEmpty {
                    VStack(spacing: 4) {
                        Text("Radical")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Text(radical)
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }

                if let strokes = character.strokeCount {
                    VStack(spacing: 4) {
                        Text("Strokes")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("\(strokes)")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                
                if let hsk = character.hskLevel {
                    VStack(spacing: 4) {
                        Text("HSK")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("\(hsk)")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .rotation3DEffect(.degrees(180.0), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
}
