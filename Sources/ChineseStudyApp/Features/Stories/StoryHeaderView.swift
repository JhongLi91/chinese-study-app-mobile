import SwiftUI

public struct StoryHeaderView: View {
    let story: Story
    
    public init(story: Story) {
        self.story = story
    }
    
    public var body: some View {
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
    }
}
