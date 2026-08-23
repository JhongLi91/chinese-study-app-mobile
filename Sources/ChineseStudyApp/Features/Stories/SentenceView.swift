import SwiftUI

public struct SentenceView: View {
    let sentence: StorySentence
    let index: Int
    let isActive: Bool
    let onCharacterTap: (String) -> Void
    
    @StateObject private var storyViewModel = StoryViewModel.shared

    public init(sentence: StorySentence, index: Int, isActive: Bool, onCharacterTap: @escaping (String) -> Void) {
        self.sentence = sentence
        self.index = index
        self.isActive = isActive
        self.onCharacterTap = onCharacterTap
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Because SwiftUI wrapping is limited, we use a simple horizontal scroll 
            // for characters to allow tapping individually while preserving layout.
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 2) {
                    let chars = sentence.zh.map { String($0) }
                    let pinyins = sentence.py.split(separator: " ").map { String($0) }
                    
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
