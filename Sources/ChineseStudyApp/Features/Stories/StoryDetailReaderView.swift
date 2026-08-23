import SwiftUI

public struct StoryDetailReaderView: View {
    public let story: Story
    @StateObject private var storyViewModel = StoryViewModel.shared
    @State private var inspectedCharacter: String?

    public init(story: Story) {
        self.story = story
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 32) {
                // Header
                StoryHeaderView(story: story)

                // Paragraphs
                ForEach(story.paragraphs) { paragraph in
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(0..<paragraph.sentences.count, id: \.self) { index in
                            let sentence = paragraph.sentences[index]
                            SentenceView(
                                sentence: sentence,
                                index: index,
                                isActive: storyViewModel.activeSentenceIndex == index,
                                onCharacterTap: { char in
                                    inspectedCharacter = char
                                }
                            )
                        }

                        if storyViewModel.showEnglishTranslation {
                            Text(paragraph.en)
                                .font(.body)
                                .foregroundColor(AppTheme.textSecondary)
                                .padding(.top, 8)
                        }
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .cornerRadius(16)
                }

                // Quiz Action
                if !story.questions.isEmpty {
                    NavigationLink {
                        StoryQuizView(story: story)
                    } label: {
                        HStack {
                            Image(systemName: "checklist")
                            Text("Take Quiz")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.statusLearned)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .padding(.top, 16)
                }
            }
            .padding()
        }
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Toggle("Show Translation", isOn: $storyViewModel.showEnglishTranslation)
                    
                    Picker("Pinyin Mode", selection: $storyViewModel.pinyinMode) {
                        ForEach(PinyinMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            storyViewModel.selectStory(story)
        }
        .onDisappear {
            storyViewModel.stopAudio()
        }
        .sheet(item: Binding<String?>(
            get: { inspectedCharacter },
            set: { inspectedCharacter = $0 }
        ).mapToIdentifiable()) { char in
            CharacterInspectorSheet(characterText: char.value)
        }
    }
}

extension Binding where Value == String? {
    func mapToIdentifiable() -> Binding<StringWrapper?> {
        Binding<StringWrapper?>(
            get: {
                if let str = self.wrappedValue {
                    return StringWrapper(value: str)
                }
                return nil
            },
            set: { newValue in
                self.wrappedValue = newValue?.value
            }
        )
    }
}

struct StringWrapper: Identifiable {
    let id = UUID()
    let value: String
}
