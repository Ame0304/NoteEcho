import SwiftUI

// MARK: - App Typography System
struct AppTypography {
    
    // MARK: - Font Sizes
    struct FontSize {
        static let largeTitle: CGFloat = 48
        static let title: CGFloat = 30
        static let headline: CGFloat = 16
        static let body: CGFloat = 14
        static let caption: CGFloat = 10
    }
    
    // MARK: - Font Weights
    struct FontWeight {
        static let light: Font.Weight = .light
        static let regular: Font.Weight = .regular
        static let medium: Font.Weight = .medium
        static let semibold: Font.Weight = .semibold
        static let bold: Font.Weight = .bold
    }
    
    // MARK: - Semantic Font Styles
    
    // Large Display Fonts
    static var largeTitle: Font {
        .system(size: FontSize.largeTitle, weight: FontWeight.regular, design: .rounded)
    }
    
    static var title: Font {
        .system(size: FontSize.title, weight: FontWeight.regular, design: .rounded)
    }
    
    static var titleSemibold: Font {
        .system(size: FontSize.title, weight: FontWeight.semibold, design: .rounded)
    }
    
    // Headlines and Emphasis
    static var headline: Font {
        .system(size: FontSize.headline, weight: FontWeight.medium, design: .rounded)
    }
    
    static var headlineBold: Font {
        .system(size: FontSize.headline, weight: FontWeight.bold, design: .rounded)
    }
    
    // Body Text
    static var body: Font {
        .system(size: FontSize.body, weight: FontWeight.regular, design: .rounded)
    }
    
    static var bodyMedium: Font {
        .system(size: FontSize.body, weight: FontWeight.medium, design: .rounded)
    }
    
    static var bodyBold: Font {
        .system(size: FontSize.body, weight: FontWeight.bold, design: .rounded)
    }
    
    // Small Text and Captions
    static var caption: Font {
        .system(size: FontSize.caption, weight: FontWeight.regular, design: .rounded)
    }
    
    static var captionMedium: Font {
        .system(size: FontSize.caption, weight: FontWeight.medium, design: .rounded)
    }
    
    static var captionSemibold: Font {
        .system(size: FontSize.caption, weight: FontWeight.semibold, design: .rounded)
    }
    
    // Special Cases
    static var timestamp: Font {
        .system(size: FontSize.caption, weight: FontWeight.regular, design: .monospaced)
    }
    
    // MARK: - SwiftUI Title Styles with Rounded Design
    static var title3Rounded: Font {
        .system(.title3, design: .rounded, weight: FontWeight.regular)
    }
    
    static var title3SemiboldRounded: Font {
        .system(.title3, design: .rounded, weight: FontWeight.semibold)
    }
    
    static var title2Rounded: Font {
        .system(.title2, design: .rounded, weight: FontWeight.regular)
    }
    
    static var bodyRounded: Font {
        .system(.body, design: .rounded, weight: FontWeight.regular)
    }
}

// MARK: - View Extension for Easy Typography Access
extension View {
    func appFont(_ font: Font) -> some View {
        self.font(font)
    }
}
