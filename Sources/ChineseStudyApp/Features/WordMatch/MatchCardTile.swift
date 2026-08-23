import SwiftUI

public struct MatchCardTile: View {
    public let card: MatchCard
    public let action: () -> Void

    public init(card: MatchCard, action: @escaping () -> Void) {
        self.card = card
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: card.isSelected ? 3.0 : 1.0)
                
                VStack(spacing: 4) {
                    if card.type == .character {
                        Text(card.displayText)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    } else {
                        Text(card.displayText)
                            .font(.headline)
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.5)
                            .lineLimit(2)
                    }
                    
                    if let subText = card.subText, card.type == .character {
                        Text(subText)
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(8)
            }
            .aspectRatio(1.0, contentMode: .fit)
            // Add a shaking effect if wrong
            .offset(x: card.isWrong ? 5.0 : 0.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.2), value: card.isWrong)
            .opacity(card.isMatched ? 0.0 : 1.0)
            .animation(.easeInOut(duration: 0.3), value: card.isMatched)
        }
        .buttonStyle(.plain)
        .disabled(card.isMatched)
    }
    
    private var backgroundColor: Color {
        if card.isWrong {
            return AppTheme.tone1.opacity(0.2) // Red for wrong
        } else if card.isSelected {
            return AppTheme.statusInProgress.opacity(0.3) // Amber for selected
        } else {
            return AppTheme.cardBackground
        }
    }
    
    private var borderColor: Color {
        if card.isWrong {
            return AppTheme.tone1
        } else if card.isSelected {
            return AppTheme.statusInProgress
        } else {
            return AppTheme.cardBorder
        }
    }
    
    private var textColor: Color {
        if card.isWrong {
            return AppTheme.tone1
        } else if card.isSelected {
            return AppTheme.textPrimary
        } else {
            return AppTheme.textPrimary
        }
    }
}
