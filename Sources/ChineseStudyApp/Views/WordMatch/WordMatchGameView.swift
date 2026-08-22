import SwiftUI

public struct WordMatchGameView: View {
    @StateObject private var gameViewModel = WordMatchViewModel.shared
    @EnvironmentObject var appState: AppState

    @State private var selectedTab: Int = 0
    
    // Custom Range state
    @State private var rangeStart: String = "1"
    @State private var rangeEnd: String = "100"
    
    // Studied Words state
    @State private var includeLearned: Bool = true
    @State private var includeInProgress: Bool = true

    public init() {}

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 2)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Mode Selector
            Picker("Game Mode", selection: $selectedTab) {
                Text("Lesson").tag(0)
                Text("Custom Range").tag(1)
                Text("Studied Words").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(AppTheme.surfaceBackground)
            
            // Contextual Controls based on mode
            VStack {
                if selectedTab == 0 {
                    Text("Current Lesson: \(appState.activeLessonNumber)")
                        .font(.headline)
                        .foregroundColor(AppTheme.textSecondary)
                } else if selectedTab == 1 {
                    HStack {
                        Text("From Rank:")
                        TextField("Start", text: $rangeStart)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                        
                        Text("To:")
                        TextField("End", text: $rangeEnd)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 60)
                    }
                    .font(.subheadline)
                } else if selectedTab == 2 {
                    HStack(spacing: 16) {
                        Toggle("Learned", isOn: $includeLearned)
                            .font(.caption)
                        Toggle("In-Progress", isOn: $includeInProgress)
                            .font(.caption)
                    }
                }
                
                Button("Update Game Board") {
                    startSelectedGameMode()
                }
                .font(.caption.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(AppTheme.statusInProgress)
                .foregroundColor(.white)
                .cornerRadius(8)
                .padding(.top, 8)
            }
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .background(AppTheme.surfaceBackground)

            // Header stats
            HStack {
                Text("Word Match")
                    .font(.title2.bold())
                    .foregroundColor(AppTheme.textPrimary)
                
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
            .padding(.horizontal)
            .padding(.top, 8)

            if gameViewModel.cards.isEmpty {
                Spacer()
                Text("Not enough words to match in this selection.")
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
            } else if gameViewModel.isGameComplete {
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
                        startSelectedGameMode()
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
                startSelectedGameMode()
            }
        }
        .onChange(of: appState.activeLessonNumber) { newLesson in
            if selectedTab == 0 {
                gameViewModel.startNewGame(mode: .lesson(newLesson))
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                ThemeToggle()
            }
        }
    }
    
    private func startSelectedGameMode() {
        switch selectedTab {
        case 0:
            gameViewModel.startNewGame(mode: .lesson(appState.activeLessonNumber))
        case 1:
            let start = Int(rangeStart) ?? 1
            let end = Int(rangeEnd) ?? 100
            gameViewModel.startNewGame(mode: .customRange(start: start, end: end))
        case 2:
            gameViewModel.startNewGame(mode: .studiedWords(includeLearned: includeLearned, includeInProgress: includeInProgress))
        default:
            break
        }
    }
}
