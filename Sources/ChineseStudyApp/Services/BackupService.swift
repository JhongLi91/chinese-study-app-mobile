import Foundation
import SwiftUI

/// Container model for a exported JSON learning progress snapshot.
public struct BackupContainer: Codable, Sendable {
    public let version: Int
    public let app: String
    public let exportDate: String
    public let timestamp: Int64
    public let recordCount: Int
    public let records: [ProgressRecord]

    public init(
        version: Int = 1,
        app: String = "ChineseStudyMobile",
        records: [ProgressRecord]
    ) {
        self.version = version
        self.app = app
        self.timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let formatter = ISO8601DateFormatter()
        self.exportDate = formatter.string(from: Date())
        self.recordCount = records.count
        self.records = records
    }
}

/// Service handling JSON backup creation, export, and migration restoration.
@MainActor
public final class BackupService: ObservableObject {
    public static let shared = BackupService()
    private let repository: ProgressRepositoryProtocol

    public init(repository: ProgressRepositoryProtocol = ProgressRepository.shared) {
        self.repository = repository
    }

    /// Exports all character learning progress as a JSON data payload and temporary shareable file.
    public func exportBackup() throws -> (jsonString: String, fileURL: URL) {
        let records = repository.exportProgress()
        let container = BackupContainer(records: records)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(container)

        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "BackupService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to encode UTF-8 backup"])
        }

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "chinese_study_backup_\(Int(Date().timeIntervalSince1970)).json"
        let fileURL = tempDir.appendingPathComponent(fileName)

        try data.write(to: fileURL)
        return (jsonString, fileURL)
    }

    /// Restores learning progress from raw JSON data.
    public func restoreBackup(from data: Data) throws -> Int {
        let decoder = JSONDecoder()
        let container = try decoder.decode(BackupContainer.self, from: data)
        let restoredCount = repository.restoreProgress(records: container.records)
        return restoredCount
    }

    /// Restores learning progress from a local JSON backup file URL.
    public func restoreBackup(from fileURL: URL) throws -> Int {
        let data = try Data(contentsOf: fileURL)
        return try restoreBackup(from: data)
    }
}
