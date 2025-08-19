import SwiftUI

// MARK: - Search Bar Component
struct SearchBar: View {
    @Binding var searchText: String
    @FocusState.Binding var isSearchFocused: Bool
    @Environment(\.colorScheme) private var colorScheme
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack(spacing: AppTheme.UIConstants.searchSpacing) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(isSearchFocused ? theme.themeColor : theme.themeColor.opacity(0.7))
                .appFont(AppTypography.captionMedium)
            
            TextField("Search highlights...", text: $searchText)
                .textFieldStyle(.plain)
                .appFont(AppTypography.captionMedium)
                .focused($isSearchFocused)
            
            // Clear button when there's text
            if !searchText.isEmpty {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.secondaryTextColor)
                        .appFont(AppTypography.captionMedium)
                }
                .buttonStyle(.plain)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, AppTheme.UIConstants.controlPadding)
        .frame(height: AppTheme.UIConstants.controlHeight)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.UIConstants.controlCornerRadius)
                .fill(theme.cardBackgroundColor)
                .shadow(
                    color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1),
                    radius: AppTheme.UIConstants.shadowRadius,
                    x: AppTheme.UIConstants.shadowOffset.width,
                    y: AppTheme.UIConstants.shadowOffset.height
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.UIConstants.controlCornerRadius)
                        .stroke(
                            searchBorderGradient,
                            lineWidth: searchBorderLineWidth
                        )
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
    }
    
    // MARK: - Helper Properties
    private var searchBorderGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: isSearchFocused 
                    ? [theme.themeColor.opacity(0.5), theme.themeColor.opacity(0.3), theme.themeColor.opacity(0.1)]
                    : [theme.themeColor.opacity(0.3), theme.themeColor.opacity(0.1), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: isSearchFocused
                    ? [theme.themeColor.opacity(0.3), theme.themeColor.opacity(0.1)]
                    : [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private var searchBorderLineWidth: CGFloat {
        isSearchFocused 
            ? AppTheme.UIConstants.focusedLineWidth 
            : (colorScheme == .dark ? AppTheme.UIConstants.darkModeLineWidth : AppTheme.UIConstants.normalLineWidth)
    }
}