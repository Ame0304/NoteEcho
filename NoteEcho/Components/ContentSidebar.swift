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
        VStack(alignment: .leading, spacing: 0) {
            // MARK: - Words Navigation Item
            ContentListItem(
                title: "Words",
                icon: "textformat",
                isSelected: selectedContentType == .words,
                theme: theme
            ) {
                selectedContentType = .words
                selectedBook = nil  // Reset book selection when switching to Words
            }
            .padding(.bottom, 12)
            
            // MARK: - All Highlights Navigation Item
            ContentListItem(
                title: "All Highlights",
                icon: "highlighter",
                isSelected: selectedContentType == .highlights && selectedBook == nil,
                theme: theme
            ) {
                selectedContentType = .highlights
                selectedBook = nil
            }
            .padding(.bottom, 8)
            
            // MARK: - Books List (Always Visible)
            if !books.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
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
                    .padding(.horizontal, 4)
                }
                .frame(maxHeight: 300)
            }
            
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 16)
        .frame(width: 250)
        .controlBackground(theme: theme, colorScheme: colorScheme)
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
                    .appFont(AppTypography.body)
                    .foregroundStyle(isSelected ? Color.white : theme.secondaryTextColor)
                    .frame(width: 16)
                
                Text(title)
                    .appFont(AppTypography.bodyMedium)
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
