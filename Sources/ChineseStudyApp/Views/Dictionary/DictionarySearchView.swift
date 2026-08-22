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
                    .foregroundColor(AppTheme.textSecondary)
                
                TextField("Search Hanzi, Pinyin, or English", text: $studyData.searchQuery)
                    .focused($isSearchFocused)
                    .disableAutocorrection(true)
                
                if !studyData.searchQuery.isEmpty {
                    Button {
                        studyData.searchQuery = ""
                        isSearchFocused = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .padding()
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .padding()

            // Filter Pills
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

            List(studyData.filteredCharacters) { char in
                NavigationLink(destination: CharacterDetailView(character: char)) {
                    CharacterRowView(character: char)
                }
            }
            .listStyle(.plain)
            .background(AppTheme.surfaceBackground)
        }
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showQuizModal = true
                } label: {
                    Image(systemName: "play.rectangle.on.rectangle")
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
                .background(isSelected ? AppTheme.statusInProgress : AppTheme.cardBorder)
                .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
                .cornerRadius(20)
        }
    }
}

private struct CharacterRowView: View {
    let character: HanziCharacter

    var body: some View {
        HStack(spacing: 16) {
            Text(character.character)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(AppTheme.color(forTone: character.toneNumber))
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
