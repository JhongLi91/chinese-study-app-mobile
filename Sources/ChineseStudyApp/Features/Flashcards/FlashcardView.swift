import SwiftUI

public struct FlashcardView: View {
    public let character: HanziCharacter
    public let isFlipped: Bool

    public init(character: HanziCharacter, isFlipped: Bool) {
        self.character = character
        self.isFlipped = isFlipped
    }

    public var body: some View {
        ZStack {
            if isFlipped {
                backView
            } else {
                frontView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.cardBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(AppTheme.cardBorder, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
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
                .foregroundColor(AppTheme.color(forTone: character.toneNumber))

            Spacer()
        }
    }

    private var backView: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()
                // You can add play button or icon here
            }
            .padding()

            VStack(spacing: 8) {
                Text(character.pinyin)
                    .font(.largeTitle.bold())
                    .foregroundColor(AppTheme.color(forTone: character.toneNumber))
                
                Text(character.definition)
                    .font(.title2)
                    .foregroundColor(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }

            Divider().background(AppTheme.cardBorder)

            HStack(spacing: 24) {
                if let radical = character.radical {
                    VStack {
                        Text("Radical")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Text(radical)
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }

                if let strokes = character.strokeCount {
                    VStack {
                        Text("Strokes")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("\(strokes)")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
                
                if let hsk = character.hskLevel {
                    VStack {
                        Text("HSK")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("\(hsk)")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }

            Spacer()
        }
        .rotation3DEffect(.degrees(180.0), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
}
