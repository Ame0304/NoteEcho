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
                
                // Soft color blobs positioned primarily in lower half
                Group {
                    // Primary theme color blob - large, bottom right
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
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .position(
                            x: geometry.size.width * 0.8,
                            y: geometry.size.height * 0.85
                        )
                        .blur(radius: 40)
                    
                    // Soft blue blob - medium, bottom left
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.GradientColors.softBlue.opacity(theme.gradientOpacities.softBluePrimary),
                                    AppColors.GradientColors.softBlue.opacity(theme.gradientOpacities.softBlueSecondary),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .position(
                            x: geometry.size.width * 0.2,
                            y: geometry.size.height * 0.9
                        )
                        .blur(radius: 35)
                    
                    // Warm peach blob - small, center bottom
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
                        .frame(width: 200, height: 200)
                        .position(
                            x: geometry.size.width * 0.5,
                            y: geometry.size.height * 0.75
                        )
                        .blur(radius: 30)
                    
                    // Subtle purple blob - medium, right side
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppColors.GradientColors.subtlePurple.opacity(theme.gradientOpacities.subtlePurplePrimary),
                                    AppColors.GradientColors.subtlePurple.opacity(theme.gradientOpacities.subtlePurpleSecondary),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 120
                            )
                        )
                        .frame(width: 250, height: 250)
                        .position(
                            x: geometry.size.width * 0.95,
                            y: geometry.size.height * 0.65
                        )
                        .blur(radius: 32)
                }
            }
        }
    }
}