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

    // MARK: - UI Surfaces & Shadcn Zinc Palette
    
    // Light Mode (Zinc)
    private static let bgLight = Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0) // #ffffff
    private static let fgLight = Color(red: 9.0/255.0, green: 9.0/255.0, blue: 11.0/255.0) // #09090b
    private static let cardLight = Color(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0) // #ffffff
    private static let borderLight = Color(red: 228.0/255.0, green: 228.0/255.0, blue: 231.0/255.0) // #e4e4e7
    private static let mutedLight = Color(red: 244.0/255.0, green: 244.0/255.0, blue: 245.0/255.0) // #f4f4f5
    private static let mutedFgLight = Color(red: 113.0/255.0, green: 113.0/255.0, blue: 122.0/255.0) // #71717a
    private static let primaryLight = Color(red: 24.0/255.0, green: 24.0/255.0, blue: 27.0/255.0) // #18181b
    private static let primaryFgLight = Color(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0) // #fafafa

    // Dark Mode (Zinc)
    private static let bgDark = Color(red: 9.0/255.0, green: 9.0/255.0, blue: 11.0/255.0) // #09090b
    private static let fgDark = Color(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0) // #fafafa
    private static let cardDark = Color(red: 9.0/255.0, green: 9.0/255.0, blue: 11.0/255.0) // #09090b
    private static let borderDark = Color(red: 39.0/255.0, green: 39.0/255.0, blue: 42.0/255.0) // #27272a
    private static let mutedDark = Color(red: 39.0/255.0, green: 39.0/255.0, blue: 42.0/255.0) // #27272a
    private static let mutedFgDark = Color(red: 161.0/255.0, green: 161.0/255.0, blue: 170.0/255.0) // #a1a1aa
    private static let primaryDark = Color(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0) // #fafafa
    private static let primaryFgDark = Color(red: 24.0/255.0, green: 24.0/255.0, blue: 27.0/255.0) // #18181b

    private static var isDark: Bool {
        AppState.shared.isDarkMode
    }

    public static var background: Color { isDark ? bgDark : bgLight }
    public static var surfaceBackground: Color { isDark ? bgDark : bgLight } // Legacy alias
    public static var foreground: Color { isDark ? fgDark : fgLight }
    public static var textPrimary: Color { isDark ? fgDark : fgLight } // Legacy alias
    
    public static var card: Color { isDark ? cardDark : cardLight }
    public static var cardBackground: Color { isDark ? cardDark : cardLight } // Legacy alias
    
    public static var border: Color { isDark ? borderDark : borderLight }
    public static var cardBorder: Color { isDark ? borderDark : borderLight } // Legacy alias
    
    public static var muted: Color { isDark ? mutedDark : mutedLight }
    public static var mutedForeground: Color { isDark ? mutedFgDark : mutedFgLight }
    public static var textSecondary: Color { isDark ? mutedFgDark : mutedFgLight } // Legacy alias
    
    public static var primary: Color { isDark ? primaryDark : primaryLight }
    public static var primaryForeground: Color { isDark ? primaryFgDark : primaryFgLight }
}
