import SwiftUI

public struct CharacterInspectorSheet: View {
    let characterText: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var studyData: StudyDataViewModel

    public init(characterText: String) {
        self.characterText = characterText
    }

    public var body: some View {
        NavigationStack {
            VStack {
                if let char = studyData.allCharacters.first(where: { $0.character == characterText }) {
                    VStack(spacing: 24) {
                        Text(char.character)
                            .font(.system(size: 80, weight: .bold))
                            .foregroundColor(AppTheme.color(forTone: char.toneNumber))

                        VStack(spacing: 8) {
                            Text(char.pinyin)
                                .font(.title)
                                .foregroundColor(AppTheme.color(forTone: char.toneNumber))
                            Text(char.definition)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                        }

                        HStack(spacing: 24) {
                            VStack {
                                Text("Rank")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                                Text("#\(char.frequencyRank)")
                                    .font(.headline)
                            }
                            if let hsk = char.hskLevel {
                                VStack {
                                    Text("HSK")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                    Text("\(hsk)")
                                        .font(.headline)
                                }
                            }
                        }

                        // Status Toggles
                        HStack(spacing: 16) {
                            StatusButton(title: "New", icon: "sparkles", color: AppTheme.statusNew, isSelected: char.status == .new) {
                                studyData.updateStatus(for: char, to: .new)
                            }
                            StatusButton(title: "Review", icon: "clock.arrow.circlepath", color: AppTheme.statusInProgress, isSelected: char.status == .inProgress) {
                                studyData.updateStatus(for: char, to: .inProgress)
                            }
                            StatusButton(title: "Learned", icon: "checkmark.circle.fill", color: AppTheme.statusLearned, isSelected: char.status == .learned) {
                                studyData.updateStatus(for: char, to: .learned)
                            }
                        }
                        .padding(.top)

                        Spacer()
                    }
                    .padding()
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 64))
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Character not found in curriculum.")
                            .font(.headline)
                        Text(characterText)
                            .font(.largeTitle)
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.surfaceBackground.ignoresSafeArea())
            .navigationTitle("Inspect")
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

private struct StatusButton: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? color.opacity(0.2) : AppTheme.cardBorder)
            .foregroundColor(isSelected ? color : AppTheme.textSecondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? color : Color.clear, lineWidth: 2)
            )
        }
    }
}
