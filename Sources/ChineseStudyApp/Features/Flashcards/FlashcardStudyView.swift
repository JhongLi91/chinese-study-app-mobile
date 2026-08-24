import SwiftUI

public struct FlashcardStudyView: View {
    @EnvironmentObject var studyData: StudyDataViewModel
    @State private var offset: CGSize = .zero
    @State private var showExampleSheet = false

    public init() {}

    public var body: some View {
        VStack(spacing: 20) {
            if let card = studyData.currentCard {
                Spacer()

                FlashcardView(character: card, isFlipped: studyData.isCardFlipped)
                    .frame(maxWidth: 340, maxHeight: 460)
                    .offset(x: offset.width, y: offset.height * 0.2)
                    .rotationEffect(.degrees(Double(offset.width / 20)))
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                offset = gesture.translation
                            }
                            .onEnded { _ in
                                handleSwipe()
                            }
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            studyData.flipCard()
                        }
                    }

                Spacer()

                // Bottom Action Bar
                HStack(spacing: 32) {
                    Button {
                        withAnimation {
                            studyData.markCurrentCardInProgress()
                        }
                    } label: {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.statusInProgress)
                            .frame(width: 64, height: 64)
                            .background(AppTheme.cardBackground)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    Button {
                        showExampleSheet = true
                    } label: {
                        Image(systemName: "doc.text")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                            .frame(width: 56, height: 56)
                            .background(AppTheme.cardBackground)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }

                    Button {
                        withAnimation {
                            studyData.markCurrentCardLearned()
                        }
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(AppTheme.statusLearned)
                            .frame(width: 64, height: 64)
                            .background(AppTheme.cardBackground)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                }

                CardScrubberView()
                    .padding(.bottom, 20)

            } else {
                VStack(spacing: 16) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 64))
                        .foregroundColor(AppTheme.statusLearned)
                    Text("Lesson Complete!")
                        .font(.title.bold())
                        .foregroundColor(AppTheme.textPrimary)
                    Text("You've reached the end of this lesson's queue.")
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(.horizontal)
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
        .sheet(isPresented: $showExampleSheet) {
            if let card = studyData.currentCard {
                ExampleSentenceSheet(character: card)
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ThemeToggle()
            }
        }
    }

    private func handleSwipe() {
        if offset.width > 120 {
            // Swiped Right -> Learned
            withAnimation(.easeOut(duration: 0.2)) {
                offset.width = 500
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                studyData.markCurrentCardLearned()
                offset = .zero
            }
        } else if offset.width < -120 {
            // Swiped Left -> In-Progress
            withAnimation(.easeOut(duration: 0.2)) {
                offset.width = -500
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                studyData.markCurrentCardInProgress()
                offset = .zero
            }
        } else {
            // Snap back
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                offset = .zero
            }
        }
    }
}
