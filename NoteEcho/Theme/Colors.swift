import SwiftUI

// MARK: - App Colors
struct AppColors {
    // MARK: - Theme Colors
    static func themeColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark 
            ? Color(red: 52/255, green: 211/255, blue: 153/255) // Softer green tint for dark mode
            : Color(red: 16/255, green: 185/255, blue: 129/255) // #10B981 for light mode
    }
    
    // MARK: - Background Colors
    static func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 28/255, green: 28/255, blue: 30/255) // #1C1C1E for dark mode
            : Color(red: 1, green: 1, blue: 1) // #FFFFFF for light mode
    }
    
    static func primaryBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.black : Color.white
    }
    
    // MARK: - Text Colors
    static func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(red: 156/255, green: 163/255, blue: 175/255) // #9CA3AF for dark mode
            : Color(red: 107/255, green: 114/255, blue: 128/255) // #6B7280 for light mode
    }
    
    // MARK: - Gradient Colors for Background
    struct GradientColors {
        static let softBlue = Color(red: 147/255, green: 197/255, blue: 253/255)
        static let warmPeach = Color(red: 254/255, green: 202/255, blue: 202/255)
        static let subtlePurple = Color(red: 196/255, green: 181/255, blue: 253/255)
    }
}

// MARK: - SwiftUI Environment Extensions
extension EnvironmentValues {
    var appColors: AppColors.Type {
        AppColors.self
    }
}
