import SwiftUI

// MARK: - App Theme Manager
struct AppTheme {
    let colorScheme: ColorScheme
    
    // MARK: - Color Properties
    var themeColor: Color {
        AppColors.themeColor(for: colorScheme)
    }
    
    var cardBackgroundColor: Color {
        AppColors.cardBackground(for: colorScheme)
    }
    
    var primaryBackgroundColor: Color {
        AppColors.primaryBackground(for: colorScheme)
    }
    
    var secondaryTextColor: Color {
        AppColors.secondaryText(for: colorScheme)
    }
    
    // MARK: - Gradient Blob Opacities
    var gradientOpacities: GradientOpacities {
        GradientOpacities(
            themeColorPrimary: colorScheme == .dark ? 0.45 : 0.25,
            themeColorSecondary: colorScheme == .dark ? 0.2 : 0.1,
            softBluePrimary: colorScheme == .dark ? 0.45 : 0.3,
            softBlueSecondary: colorScheme == .dark ? 0.2 : 0.1,
            warmPeachPrimary: colorScheme == .dark ? 0.35 : 0.15,
            warmPeachSecondary: colorScheme == .dark ? 0.2 : 0.1,
            subtlePurplePrimary: colorScheme == .dark ? 0.38 : 0.18,
            subtlePurpleSecondary: colorScheme == .dark ? 0.2 : 0.1
        )
    }
    
    // MARK: - UI Constants
    struct UIConstants {
        static let controlHeight: CGFloat = 36
        static let controlPadding: CGFloat = 12
        static let controlCornerRadius: CGFloat = 8
        static let searchSpacing: CGFloat = 8
        static let controlSpacing: CGFloat = 12
        
        static let shadowRadius: CGFloat = 6
        static let shadowOffset = CGSize(width: 0, height: 3)
        static let focusedLineWidth: CGFloat = 1.5
        static let normalLineWidth: CGFloat = 0.5
        static let darkModeLineWidth: CGFloat = 1
    }
}

// MARK: - Gradient Opacities Helper
struct GradientOpacities {
    let themeColorPrimary: Double
    let themeColorSecondary: Double
    let softBluePrimary: Double
    let softBlueSecondary: Double
    let warmPeachPrimary: Double
    let warmPeachSecondary: Double
    let subtlePurplePrimary: Double
    let subtlePurpleSecondary: Double
}

// MARK: - SwiftUI Environment Key
private struct AppThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme(colorScheme: .light)
}

extension EnvironmentValues {
    var appTheme: AppTheme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}

// MARK: - View Extension for Easy Theme Access
extension View {
    func withAppTheme(_ colorScheme: ColorScheme) -> some View {
        environment(\.appTheme, AppTheme(colorScheme: colorScheme))
    }
}
