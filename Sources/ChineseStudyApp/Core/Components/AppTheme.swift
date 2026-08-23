import SwiftUI

/// Standard color palette and styling definitions for Chinese Study Mobile.
@MainActor
public struct AppTheme {

    // MARK: - Mandarin Tone Colors (Tones 1 - 5)

    /// Tone 1: High flat tone (ā, ē, ī, ō, ū, ǖ) - Vibrant Coral/Red
    public static let tone1 = Color(red: 239.0 / 255.0, green: 68.0 / 255.0, blue: 68.0 / 255.0)

    /// Tone 2: Rising tone (á, é, í, ó, ú, ǘ) - Vibrant Amber/Orange
    public static let tone2 = Color(red: 245.0 / 255.0, green: 158.0 / 255.0, blue: 11.0 / 255.0)

    /// Tone 3: Dipping / Low falling-rising tone (ǎ, ě, ǐ, ǒ, ǔ, ǚ) - Emerald Green
    public static let tone3 = Color(red: 16.0 / 255.0, green: 185.0 / 255.0, blue: 129.0 / 255.0)

    /// Tone 4: Falling tone (à, è, ì, ò, ù, ǜ) - Sky/Cyan Blue
    public static let tone4 = Color(red: 59.0 / 255.0, green: 130.0 / 255.0, blue: 246.0 / 255.0)

    /// Tone 5: Neutral tone - Cool Slate/Gray
    public static let tone5 = Color(red: 107.0 / 255.0, green: 114.0 / 255.0, blue: 128.0 / 255.0)

    /// Returns the tone accent color for a given tone number (1..5).
    public static func color(forTone tone: Int) -> Color {
        switch tone {
        case 1: return tone1
        case 2: return tone2
        case 3: return tone3
        case 4: return tone4
        default: return tone5
        }
    }

    // MARK: - Study Status Colors

    /// Learned Status (Mastered) - Bright Emerald Green
    public static let statusLearned = Color(red: 34.0 / 255.0, green: 197.0 / 255.0, blue: 94.0 / 255.0)

    /// In-Progress Status (Reviewing) - Warm Amber
    public static let statusInProgress = Color(red: 245.0 / 255.0, green: 158.0 / 255.0, blue: 11.0 / 255.0)

    /// New Status (Unstudied) - Indigo/Blue
    public static let statusNew = Color(red: 99.0 / 255.0, green: 102.0 / 255.0, blue: 241.0 / 255.0)

    /// Returns the status accent color for a given StudyStatus enum.
    public static func color(forStatus status: StudyStatus) -> Color {
        switch status {
        case .learned: return statusLearned
        case .inProgress: return statusInProgress
        case .new: return statusNew
        }
    }

    // MARK: - UI Surfaces & Badges
    
    /// Resolved dark-mode colors. Each color pair is pre-defined so the only
    /// per-access cost is the single Bool branch – no cross-actor hop.
    private static let cardBackgroundDark = Color(red: 30.0 / 255.0, green: 41.0 / 255.0, blue: 59.0 / 255.0)
    private static let cardBackgroundLight = Color(red: 255.0 / 255.0, green: 255.0 / 255.0, blue: 255.0 / 255.0)
    private static let cardBorderDark = Color(red: 51.0 / 255.0, green: 65.0 / 255.0, blue: 85.0 / 255.0)
    private static let cardBorderLight = Color(red: 226.0 / 255.0, green: 232.0 / 255.0, blue: 240.0 / 255.0)
    private static let surfaceBackgroundDark = Color(red: 15.0 / 255.0, green: 23.0 / 255.0, blue: 42.0 / 255.0)
    private static let surfaceBackgroundLight = Color(red: 248.0 / 255.0, green: 250.0 / 255.0, blue: 252.0 / 255.0)
    private static let textSecondaryDark = Color(red: 148.0 / 255.0, green: 163.0 / 255.0, blue: 184.0 / 255.0)
    private static let textSecondaryLight = Color(red: 100.0 / 255.0, green: 116.0 / 255.0, blue: 139.0 / 255.0)
    private static let textPrimaryDark = Color.white
    private static let textPrimaryLight = Color(red: 15.0 / 255.0, green: 23.0 / 255.0, blue: 42.0 / 255.0)

    private static var isDark: Bool {
        AppState.shared.isDarkMode
    }

    /// Card background container fill
    public static var cardBackground: Color {
        isDark ? cardBackgroundDark : cardBackgroundLight
    }
    
    public static var cardBorder: Color {
        isDark ? cardBorderDark : cardBorderLight
    }
    
    public static var surfaceBackground: Color {
        isDark ? surfaceBackgroundDark : surfaceBackgroundLight
    }
    
    public static var textPrimary: Color {
        isDark ? textPrimaryDark : textPrimaryLight
    }
    
    public static var textSecondary: Color {
        isDark ? textSecondaryDark : textSecondaryLight
    }
}
