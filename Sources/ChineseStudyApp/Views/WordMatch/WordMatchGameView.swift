import SwiftUI

public struct WordMatchGameView: View {
    @StateObject private var gameViewModel = WordMatchViewModel.shared
    @EnvironmentObject var appState: AppState

    public init() {}

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    }

    public var body: some View {
        VStack {
            // Header stats
            HStack {
                VStack(alignment: .leading) {
                    Text("Lesson \(appState.activeLessonNumber)")
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondary)
                    Text("Word Match")
                        .font(.title2.bold())
                        .foregroundColor(AppTheme.textPrimary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(gameViewModel.streak >= 3 ? AppTheme.statusInProgress : AppTheme.cardBorder)
                        Text("\(gameViewModel.streak)")
                            .font(.title3.bold())
                            .foregroundColor(gameViewModel.streak >= 3 ? AppTheme.statusInProgress : AppTheme.textPrimary)
                    }
                }
            }
            .padding()

            if gameViewModel.isGameComplete {
                Spacer()
                
                VStack(spacing: 24) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 80))
                        .foregroundColor(AppTheme.statusInProgress)
                    
                    Text("Round Complete!")
                        .font(.largeTitle.bold())
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Text("You matched all \(gameViewModel.totalPairs) pairs in \(gameViewModel.attempts / 2) attempts.")
                        .font(.title3)
                        .foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button {
                        gameViewModel.startNewGame(lessonNumber: appState.activeLessonNumber)
                    } label: {
                        Text("Play Again")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(AppTheme.statusLearned)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                
                Spacer()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(gameViewModel.cards) { card in
                            MatchCardTile(card: card) {
                                gameViewModel.selectCard(card)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
        .onAppear {
            if gameViewModel.cards.isEmpty {
                gameViewModel.startNewGame(lessonNumber: appState.activeLessonNumber)
            }
        }
        .onChange(of: appState.activeLessonNumber) { newLesson in
            gameViewModel.startNewGame(lessonNumber: newLesson)
        }
    }
}
