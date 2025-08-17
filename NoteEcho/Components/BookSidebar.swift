import SwiftUI
import SwiftData

// MARK: - Book Sidebar Component
struct BookSidebar: View {
    @Binding var selectedBook: Book?
    let books: [Book]
    @Environment(\.colorScheme) private var colorScheme
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Text("Books")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(theme.themeColor)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            // Book list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    // "All Books" option
                    BookListItem(
                        title: "All Books",
                        isSelected: selectedBook == nil,
                        theme: theme
                    ) {
                        selectedBook = nil
                    }
                    
                    // Individual books
                    ForEach(books, id: \.id) { book in
                        BookListItem(
                            title: book.title,
                            isSelected: selectedBook?.id == book.id,
                            theme: theme
                        ) {
                            selectedBook = book
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
            }
        }
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.UIConstants.controlCornerRadius)
                .fill(theme.cardBackgroundColor)
                .shadow(
                    color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.05),
                    radius: AppTheme.UIConstants.shadowRadius,
                    x: AppTheme.UIConstants.shadowOffset.width,
                    y: AppTheme.UIConstants.shadowOffset.height
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.UIConstants.controlCornerRadius)
                        .stroke(
                            sidebarBorderGradient,
                            lineWidth: colorScheme == .dark ? AppTheme.UIConstants.darkModeLineWidth : AppTheme.UIConstants.normalLineWidth
                        )
                )
        )
    }
    
    private var sidebarBorderGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [theme.themeColor.opacity(0.2), theme.themeColor.opacity(0.1), Color.clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

// MARK: - Book List Item
private struct BookListItem: View {
    let title: String
    let isSelected: Bool
    let theme: AppTheme
    let action: () -> Void
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(isSelected ? theme.themeColor :Color.primary)
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
    }
    
    private var itemBackgroundColor: Color {
        if isSelected {
            return theme.themeColor.opacity(0.10)
        } else if isHovered {
            return theme.themeColor.opacity(0.05)
        } else {
            return Color.clear
        }
    }
}
