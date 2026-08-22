import SwiftUI
import UniformTypeIdentifiers

public struct DatabaseBackupView: View {
    @StateObject private var backupService = BackupService.shared
    @EnvironmentObject var studyData: StudyDataViewModel
    
    @State private var exportURL: URL? = nil
    @State private var isShowingExporter = false
    @State private var isShowingImporter = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var isExporting = false

    public init() {}

    public var body: some View {
        VStack(spacing: 24) {
            Text("Data Backup & Restore")
                .font(.title2.bold())
                .foregroundColor(AppTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Export your learning progress to a portable JSON file to back it up or migrate to another device. You can restore your progress anytime.")
                .font(.body)
                .foregroundColor(AppTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                // Export Button
                if isExporting {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if let url = exportURL {
                    ShareLink(item: url) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Backup File")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.statusInProgress)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                } else {
                    Button {
                        generateBackup()
                    } label: {
                        HStack {
                            Image(systemName: "doc.zipper")
                            Text("Generate JSON Backup")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.statusInProgress)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                
                // Import Button
                Button {
                    isShowingImporter = true
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.down")
                        Text("Restore from Backup")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.cardBackground)
                    .foregroundColor(AppTheme.textPrimary)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.cardBorder, lineWidth: 1)
                    )
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .fileImporter(
            isPresented: $isShowingImporter,
            allowedContentTypes: [UTType.json, UTType.plainText],
            allowsMultipleSelection: false
        ) { result in
            do {
                guard let selectedFile: URL = try result.get().first else { return }
                // Request access to read the file
                if selectedFile.startAccessingSecurityScopedResource() {
                    defer { selectedFile.stopAccessingSecurityScopedResource() }
                    let restoredCount = try backupService.restoreBackup(from: selectedFile)
                    studyData.loadData() // Refresh in-memory state
                    alertMessage = "Successfully restored progress for \(restoredCount) characters."
                    showAlert = true
                } else {
                    alertMessage = "Failed to access selected file."
                    showAlert = true
                }
            } catch {
                alertMessage = "Restore failed: \(error.localizedDescription)"
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Backup Restore"),
                message: Text(alertMessage),
                dismissButton: Alert.Button.default(Text("OK"))
            )
        }
    }
    
    private func generateBackup() {
        isExporting = true
        Task {
            do {
                let (_, fileURL) = try backupService.exportBackup()
                await MainActor.run {
                    self.exportURL = fileURL
                    self.isExporting = false
                }
            } catch {
                await MainActor.run {
                    self.alertMessage = "Export failed: \(error.localizedDescription)"
                    self.showAlert = true
                    self.isExporting = false
                }
            }
        }
    }
}
