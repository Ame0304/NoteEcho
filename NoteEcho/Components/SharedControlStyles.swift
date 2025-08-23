import SwiftUI

// MARK: - Shared Control Background
struct ControlBackgroundModifier: ViewModifier {
    let theme: AppTheme
    let colorScheme: ColorScheme
    let isHovered: Bool
    let cornerRadius: CGFloat
    
    init(theme: AppTheme, colorScheme: ColorScheme, isHovered: Bool = false, cornerRadius: CGFloat = AppTheme.UIConstants.controlCornerRadius) {
        self.theme = theme
        self.colorScheme = colorScheme
        self.isHovered = isHovered
        self.cornerRadius = cornerRadius
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(theme.cardBackgroundColor)
                    .shadow(
                        color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1),
                        radius: AppTheme.UIConstants.shadowRadius,
                        x: AppTheme.UIConstants.shadowOffset.width,
                        y: AppTheme.UIConstants.shadowOffset.height
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                controlBorderGradient,
                                lineWidth: borderLineWidth
                            )
                    )
            )
    }
    
    private var controlBorderGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: isHovered 
                    ? [theme.themeColor.opacity(0.5), theme.themeColor.opacity(0.3), theme.themeColor.opacity(0.1)]
                    : [theme.themeColor.opacity(0.3), theme.themeColor.opacity(0.1), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: isHovered
                    ? [theme.themeColor.opacity(0.3), theme.themeColor.opacity(0.1)]
                    : [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private var borderLineWidth: CGFloat {
        isHovered 
            ? AppTheme.UIConstants.focusedLineWidth 
            : (colorScheme == .dark ? AppTheme.UIConstants.darkModeLineWidth : AppTheme.UIConstants.normalLineWidth)
    }
}

// MARK: - View Extension
extension View {
    func controlBackground(theme: AppTheme, colorScheme: ColorScheme, isHovered: Bool = false, cornerRadius: CGFloat = AppTheme.UIConstants.controlCornerRadius) -> some View {
        self.modifier(ControlBackgroundModifier(theme: theme, colorScheme: colorScheme, isHovered: isHovered, cornerRadius: cornerRadius))
    }
}