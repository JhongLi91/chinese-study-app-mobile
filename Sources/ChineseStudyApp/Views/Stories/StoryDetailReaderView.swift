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
            VStack(alignment: .leading, spacing: 32) {
                // Header
                VStack(alignment: .center, spacing: 8) {
                    Text(story.titleZh)
                        .font(.largeTitle.bold())
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text(story.titlePy)
                        .font(.title3)
                        .foregroundColor(AppTheme.textSecondary)
                    
                    Text(story.titleEn)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)

                // Paragraphs
                ForEach(story.paragraphs) { paragraph in
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(paragraph.sentences.enumerated()), id: \.element.id) { index, sentence in
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

private struct SentenceView: View {
    let sentence: StorySentence
    let index: Int
    let isActive: Bool
    let onCharacterTap: (String) -> Void
    
    @StateObject private var storyViewModel = StoryViewModel.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Because SwiftUI wrapping is limited, we use a simple horizontal scroll 
            // for characters to allow tapping individually while preserving layout.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    let chars = Array(sentence.zh).map { String($0) }
                    let pinyins = sentence.py.components(separatedBy: .whitespaces)
                    
                    ForEach(0..<chars.count, id: \.self) { i in
                        VStack(spacing: 2) {
                            if storyViewModel.pinyinMode == .ruby {
                                Text(i < pinyins.count ? pinyins[i] : " ")
                                    .font(.system(size: 10))
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            
                            Text(chars[i])
                                .font(.title2)
                                .foregroundColor(isActive ? AppTheme.statusInProgress : AppTheme.textPrimary)
                        }
                        .onTapGesture {
                            onCharacterTap(chars[i])
                        }
                    }
                }
            }
            
            if storyViewModel.pinyinMode == .inline {
                Text(sentence.py)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
            }
        }
        .padding(8)
        .background(isActive ? AppTheme.statusInProgress.opacity(0.1) : Color.clear)
        .cornerRadius(8)
        .onTapGesture {
            storyViewModel.playSentenceAudio(sentence: sentence, index: index)
        }
    }
}
