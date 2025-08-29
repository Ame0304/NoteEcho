import SwiftUI

// MARK: - Content Sidebar Component
struct ContentSidebar: View {
    @Binding var selectedContentType: ContentType
    @Binding var selectedBook: Book?
    let books: [Book]
    @Environment(\.colorScheme) private var colorScheme
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: - Words Section
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Words", icon: "textformat", theme: theme)
                
                ContentListItem(
                    title: "All Words",
                    icon: "textformat",
                    isSelected: selectedContentType == .words,
                    theme: theme
                ) {
                    selectedContentType = .words
                    selectedBook = nil  // Reset book selection when switching to Words
                }
            }
            
            // MARK: - Highlights Section  
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(title: "Highlights", icon: "highlighter", theme: theme)
                
                VStack(alignment: .leading, spacing: 2) {
                    // "All Highlights" option
                    ContentListItem(
                        title: "All Highlights",
                        icon: "highlighter",
                        isSelected: selectedContentType == .highlights && selectedBook == nil,
                        theme: theme
                    ) {
                        selectedContentType = .highlights
                        selectedBook = nil
                    }
                    
                    // Individual books (only shown when Highlights is selected)
                    if selectedContentType == .highlights {
                        ForEach(books, id: \.id) { book in
                            ContentListItem(
                                title: book.title,
                                icon: "book",
                                isSelected: selectedContentType == .highlights && selectedBook?.id == book.id,
                                theme: theme
                            ) {
                                selectedContentType = .highlights
                                selectedBook = book
                            }
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
        .frame(width: 200)
        .controlBackground(theme: theme, colorScheme: colorScheme)
    }
}

// MARK: - Section Header
private struct SectionHeader: View {
    let title: String
    let icon: String
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .appFont(AppTypography.captionMedium)
                .foregroundStyle(theme.themeColor)
            
            Text(title)
                .appFont(AppTypography.bodyBold)
                .foregroundStyle(theme.themeColor)
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }
}

// MARK: - Content List Item
private struct ContentListItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .appFont(AppTypography.caption)
                    .foregroundStyle(isSelected ? Color.white : theme.secondaryTextColor)
                    .frame(width: 14)
                
                Text(title)
                    .appFont(AppTypography.captionMedium)
                    .foregroundStyle(isSelected ? Color.white : Color.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: AppTheme.UIConstants.controlHeight)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(itemBackgroundColor)
            )
            .animation(.easeInOut(duration: 0.15), value: isSelected)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .pointingHandCursor()
    }
    
    private var itemBackgroundColor: Color {
        if isSelected {
            return theme.themeColor.opacity(0.8)
        } else if isHovered {
            return theme.themeColor.opacity(0.15)
        } else {
            return Color.clear
        }
    }
}
