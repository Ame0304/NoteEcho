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
        .controlBackground(theme: theme, colorScheme: colorScheme, isHovered: isSearchFocused)
        .animation(.easeInOut(duration: 0.2), value: isSearchFocused)
        .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
    }
    
}