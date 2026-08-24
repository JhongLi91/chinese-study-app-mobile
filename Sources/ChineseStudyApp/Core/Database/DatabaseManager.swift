import Foundation
import SkipSQLCore
import SkipSQL

/// Thread-safe SQLite database manager for Chinese Study Mobile.
/// Handles character queries, learning status mutations, word associations, stories, and study sessions.
public final class DatabaseManager: @unchecked Sendable {
    public static let shared = DatabaseManager()

    let lock = NSLock()
    var context: SQLContext?
    public private(set) var dbPath: URL?

    public init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            let fileManager = FileManager.default
            let appSupportDir = URL.applicationSupportDirectory

            if !fileManager.fileExists(atPath: appSupportDir.path) {
                try? fileManager.createDirectory(at: appSupportDir, withIntermediateDirectories: true)
            }

            let destinationURL = appSupportDir.appendingPathComponent("hanzi_db.sqlite")
            self.dbPath = destinationURL

            // Copy pre-seeded database if it doesn't exist in app support
            if !fileManager.fileExists(atPath: destinationURL.path) {
                if let bundleURL = Bundle.module.url(forResource: "hanzi_db", withExtension: "sqlite") {
                    do {
                        let data = try Data(contentsOf: bundleURL)
                        try data.write(to: destinationURL)
                    } catch {
                        print("Failed to copy database: \(error)")
                    }
                } else {
                    print("Could not find hanzi_db.sqlite in bundle.")
                }
            }

            let ctx = try SQLContext(
                path: destinationURL.path,
                flags: [SQLContext.OpenFlags.create, SQLContext.OpenFlags.readWrite],
                configuration: SQLiteConfiguration.platform
            )
            self.context = ctx
            ensureSchema()
        } catch {
            print("Database initialization error: \(error)")
        }
    }

    private func ensureSchema() {
        guard let ctx = context else { return }
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS characters (
            frequency_rank INTEGER PRIMARY KEY,
            character TEXT NOT NULL,
            pinyin TEXT NOT NULL,
            definition TEXT NOT NULL,
            radical TEXT,
            radical_code TEXT,
            stroke_count INTEGER,
            hsk_level INTEGER,
            lesson_number INTEGER NOT NULL,
            example_zh TEXT,
            example_py TEXT,
            example_en TEXT
        );
        """)
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS progress (
            character_id INTEGER PRIMARY KEY,
            status TEXT NOT NULL CHECK(status IN ('new', 'in-progress', 'learned')),
            updated_at INTEGER NOT NULL,
            FOREIGN KEY (character_id) REFERENCES characters(frequency_rank) ON DELETE CASCADE
        );
        """)
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS word_associations (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            character_id INTEGER NOT NULL,
            character_char TEXT NOT NULL,
            word TEXT NOT NULL,
            pinyin TEXT NOT NULL,
            meaning TEXT NOT NULL,
            FOREIGN KEY (character_id) REFERENCES characters(frequency_rank)
        );
        """)
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS stories (
            id TEXT PRIMARY KEY,
            title_zh TEXT NOT NULL,
            title_py TEXT NOT NULL,
            title_en TEXT NOT NULL,
            level TEXT NOT NULL,
            source TEXT NOT NULL,
            lesson_target TEXT NOT NULL,
            description TEXT NOT NULL,
            data_json TEXT NOT NULL
        );
        """)
        try? ctx.exec(sql: """
        CREATE TABLE IF NOT EXISTS study_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_type TEXT NOT NULL,
            start_time INTEGER NOT NULL,
            duration_seconds INTEGER NOT NULL,
            cards_reviewed INTEGER NOT NULL,
            created_at INTEGER NOT NULL
        );
        """)
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_characters_lesson ON characters(lesson_number);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_characters_char ON characters(character);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_characters_hsk ON characters(hsk_level);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_progress_status ON progress(status);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_word_assoc_char_id ON word_associations(character_id);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_word_assoc_word ON word_associations(word);")
        try? ctx.exec(sql: "CREATE INDEX IF NOT EXISTS idx_sessions_created_at ON study_sessions(created_at);")
    }





}
