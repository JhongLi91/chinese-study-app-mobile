import SwiftUI

public struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var studyData: StudyDataViewModel
    @State private var showResetConfirmation = false

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Audio Settings
                Card {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Audio Preferences")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.textPrimary)
                        
                        Toggle("Enable Sound Effects & Haptics", isOn: $appState.isSoundEffectsEnabled)
                            .tint(AppTheme.primary)
                        
                        Toggle("Auto-Play Pronunciation on Flip", isOn: $appState.autoPlayAudioOnFlip)
                            .tint(AppTheme.primary)
                        
                        VStack(alignment: .leading) {
                            Text("Mandarin TTS Speech Rate")
                                .foregroundColor(AppTheme.textPrimary)
                            
                            HStack {
                                Image(systemName: "minus")
                                    .foregroundColor(AppTheme.textSecondary)
                                Slider(value: $appState.speechRate, in: 0.5...1.5, step: 0.25)
                                    .tint(AppTheme.primary)
                                Image(systemName: "plus")
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                        }
                    }
                }
                
                // Backup & Restore module
                DatabaseBackupView()
                
                // Danger Zone
                Card {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Danger Zone")
                            .font(.title3.bold())
                            .foregroundColor(AppTheme.tone1) // Red
                        
                        Text("This will permanently delete all your learning progress and reset all 3,000 characters to 'New' status.")
                            .font(.subheadline)
                            .foregroundColor(AppTheme.textSecondary)
                        
                        ModernButton(title: "Reset All Progress", variant: .destructive, size: .lg) {
                            showResetConfirmation = true
                        }
                    }
                }
                
                // About Section
                VStack(alignment: .center, spacing: 8) {
                    Text("Chinese Study App")
                        .font(.headline)
                        .foregroundColor(AppTheme.textPrimary)
                    Text("Skip.tools Dual-Platform Engine v1.0")
                        .font(.caption)
                        .foregroundColor(AppTheme.textSecondary)
                }
                .padding(.top, 16)
                
            }
            .padding()
        }
        .background(AppTheme.surfaceBackground.ignoresSafeArea())
        .alert("Reset All Progress?", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                studyData.resetAllProgress()
            }
        } message: {
            Text("Are you absolutely sure? This action cannot be undone unless you have a backup file.")
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                ThemeToggle()
            }
        }
    }
}
