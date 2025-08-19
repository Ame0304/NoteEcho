import SwiftUI

// MARK: - Blurred Gradient Background Component
struct BlurredGradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base background
                theme.primaryBackgroundColor
                    .ignoresSafeArea()
                
                // Soft color blobs distributed across full window area
                Group {
                    // Primary theme color blob - large, left side mid-height
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    theme.themeColor.opacity(theme.gradientOpacities.themeColorPrimary), 
                                    theme.themeColor.opacity(theme.gradientOpacities.themeColorSecondary), 
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 225
                            )
                        )
                        .frame(width: 450, height: 450)
                        .position(
                            x: geometry.size.width * 0.15,
                            y: geometry.size.height * 0.4
                        )
                        .blur(radius: 45)
                    
                    // Soft blue blob - large, right side lower-mid
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.GradientColors.softBlue.opacity(theme.gradientOpacities.softBluePrimary),
                                    AppColors.GradientColors.softBlue.opacity(theme.gradientOpacities.softBlueSecondary),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 50,
                                endRadius: 225
                            )
                        )
                        .frame(width: 450, height: 450)
                        .position(
                            x: geometry.size.width * 0.85,
                            y: geometry.size.height * 0.7
                        )
                        .blur(radius: 45)
                    
                    // Warm peach blob - accent, center upper-mid
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.GradientColors.warmPeach.opacity(theme.gradientOpacities.warmPeachPrimary),
                                    AppColors.GradientColors.warmPeach.opacity(theme.gradientOpacities.warmPeachSecondary),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 100
                            )
                        )
                        .frame(width: 300, height: 300)
                        .position(
                            x: geometry.size.width * 0.5,
                            y: geometry.size.height * 0.3
                        )
                        .blur(radius: 35)
                    
                }
            }
        }
    }
}
