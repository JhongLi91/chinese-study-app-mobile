import SwiftUI

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var studyData: StudyDataViewModel
    @Binding var isSidebarOpen: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("学 中文")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Spacer()
                Button(action: {
                    withAnimation {
                        isSidebarOpen = false
                    }
                }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            .padding(.top, 50)
            .padding(.horizontal)
            
            Divider()
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // STUDY PAGES
                    VStack(alignment: .leading, spacing: 5) {
                        Text("STUDY PAGES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.leading, 10)
                            .padding(.bottom, 5)
                            
                        ForEach([AppTab.lessons, .learned, .inProgress, .allHanzi], id: \.self) { tab in
                            tabButton(for: tab)
                        }
                    }
                    
                    // PRACTICE & GAMES
                    VStack(alignment: .leading, spacing: 5) {
                        Text("PRACTICE & GAMES")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.leading, 10)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            
                        ForEach([AppTab.stories, .match], id: \.self) { tab in
                            tabButton(for: tab)
                        }
                    }
                    
                    // SETTINGS
                    VStack(alignment: .leading, spacing: 5) {
                        Text("SYSTEM")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.leading, 10)
                            .padding(.top, 10)
                            .padding(.bottom, 5)
                            
                        tabButton(for: AppTab.settings)
                    }
                }
                .padding(.horizontal)
                
                // OVERALL MASTERY
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("OVERALL MASTERY")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f%%", studyData.overallLearnedPercentage * 100))
                            .font(.caption.bold())
                            .foregroundColor(.blue)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 8)
                            
                            let learnedWidth = geometry.size.width * CGFloat(studyData.totalLearnedCount) / 3000.0
                            let inProgressWidth = geometry.size.width * CGFloat(studyData.totalInProgressCount) / 3000.0
                            
                            HStack(spacing: 0) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.statusLearned)
                                    .frame(width: learnedWidth, height: 8)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(AppTheme.statusInProgress)
                                    .frame(width: inProgressWidth, height: 8)
                            }
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("\(studyData.totalLearnedCount) Learned")
                        }
                        .foregroundColor(AppTheme.statusLearned)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                            Text("\(studyData.totalInProgressCount) In-Prog")
                        }
                        .foregroundColor(AppTheme.statusInProgress)
                    }
                    .font(.caption.bold())
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 20)
                .padding(.bottom, 40)
                
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
    }
    
    private func tabButton(for tab: AppTab) -> some View {
        Button(action: {
            appState.selectedTab = tab
            withAnimation {
                isSidebarOpen = false
            }
        }) {
            HStack(spacing: 15) {
                Image(systemName: tab.emoji)
                    .font(.title3)
                Text(tab.rawValue)
                    .font(.headline)
                Spacer()
                badge(for: tab)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .background(appState.selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear)
            .cornerRadius(10)
            .foregroundColor(appState.selectedTab == tab ? .accentColor : .primary)
        }
    }
    
    @ViewBuilder
    private func badge(for tab: AppTab) -> some View {
        switch tab {
        case .lessons:
            Text("\(studyData.lessons.count)")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(12)
        case .learned:
            Text("\(studyData.totalLearnedCount)")
                .font(.caption.bold())
                .foregroundColor(AppTheme.statusLearned)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.statusLearned.opacity(0.2))
                .cornerRadius(12)
        case .inProgress:
            Text("\(studyData.totalInProgressCount)")
                .font(.caption.bold())
                .foregroundColor(AppTheme.statusInProgress)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.statusInProgress.opacity(0.2))
                .cornerRadius(12)
        case .allHanzi:
            Text("\(studyData.allCharacters.count)")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(12)
        case .stories:
            Text("HSK 3+")
                .font(.caption.bold())
                .foregroundColor(.blue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.2))
                .cornerRadius(12)
        case .match:
            Text("Game")
                .font(.caption.bold())
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.2))
                .cornerRadius(12)
        default:
            EmptyView()
        }
    }
}
