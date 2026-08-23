import SwiftUI

public struct DictionarySearchView: View {
    @EnvironmentObject var studyData: StudyDataViewModel
    @FocusState private var isSearchFocused: Bool
    @State private var showQuizModal = false

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppTheme.mutedForeground)
                
                TextField("Search Hanzi, Pinyin, or English", text: $studyData.searchQuery)
                    .focused($isSearchFocused)
                    .autocorrectionDisabled(true)
                
                if !studyData.searchQuery.isEmpty {
                    Button {
                        studyData.searchQuery = ""
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.mutedForeground)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.background)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppTheme.border, lineWidth: 1)
            )
            .padding()

            // Filter Pills handled by Sidebar Navigation now
            /*
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    FilterPill(title: "All", isSelected: studyData.selectedFilterStatus == nil) {
                        studyData.selectedFilterStatus = nil
                    }
                    
                    ForEach(StudyStatus.allCases, id: \.self) { status in
                        FilterPill(title: status.title, isSelected: studyData.selectedFilterStatus == status) {
                            studyData.selectedFilterStatus = status
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 8)
            */

            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(studyData.filteredCharacters) { char in
                        NavigationLink(value: char.frequencyRank) {
                            CharacterRowView(character: char)
                                .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                            .padding(.leading, 16)
                    }
                }
                .padding(.bottom, 24)
            }
            .navigationDestination(for: Int.self) { rank in
                if let char = studyData.allCharacters.first(where: { $0.frequencyRank == rank }) {
                    CharacterDetailView(character: char)
                }
            }
            .background(AppTheme.background)
        }
        .background(AppTheme.background.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                ThemeToggle()
            }
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showQuizModal = true
                } label: {
                    Image(systemName: "play.circle.fill")
                }
                .disabled(studyData.filteredCharacters.isEmpty)
            }
        }
        .sheet(isPresented: $showQuizModal) {
            QuickQuizModalView(sourceCharacters: studyData.filteredCharacters)
        }
        .onDisappear {
            studyData.searchQuery = ""
        }
    }
}

private struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.primary : AppTheme.background)
                .foregroundColor(isSelected ? AppTheme.primaryForeground : AppTheme.foreground)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.clear : AppTheme.border, lineWidth: 1)
                )
        }
    }
}

private struct CharacterRowView: View {
    let character: HanziCharacter

    var body: some View {
        HStack(spacing: 16) {
            Text(character.character)
                .font(.system(size: 32, weight: .bold))

                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(character.pinyin)
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: character.status.systemImage)
                        .foregroundColor(statusColor)
                }
                
                Text(character.cleanDefinition)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var statusColor: Color {
        switch character.status {
        case .new: return AppTheme.statusNew
        case .inProgress: return AppTheme.statusInProgress
        case .learned: return AppTheme.statusLearned
        }
    }
}
