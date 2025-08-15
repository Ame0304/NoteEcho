import SwiftUI
import SwiftData

// MARK: - Filter Controls Component
struct FilterControls: View {
    @Binding var selectedBook: Book?
    @Binding var sortByNewest: Bool
    let books: [Book]
    @Environment(\.colorScheme) private var colorScheme
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.UIConstants.controlSpacing) {
            // Book filter dropdown menu (takes flexible space)
            Menu {
                Button("All Books") {
                    selectedBook = nil  // Setting to nil shows all books
                }
                Divider()
                // Create a button for each book
                ForEach(books, id: \.id) { book in
                    Button(book.title) {
                        selectedBook = book  // Filter to this specific book
                    }
                }
            } label: {
                BookFilterLabel(selectedBook: selectedBook, theme: theme)
                    .background(
                        ControlBackground(theme: theme, colorScheme: colorScheme)
                    )
            }
            .buttonStyle(.plain)
            
            Spacer()
            
            // Sort direction toggle button
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    sortByNewest.toggle()  // Flip between newest/oldest first
                }
            } label: {
                SortButtonLabel(sortByNewest: sortByNewest, theme: theme)
                    .background(
                        ControlBackground(theme: theme, colorScheme: colorScheme)
                    )
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Book Filter Label
private struct BookFilterLabel: View {
    let selectedBook: Book?
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: AppTheme.UIConstants.searchSpacing) {
            Image(systemName: selectedBook != nil ? "book.closed.fill" : "book.closed")
                .foregroundStyle(theme.themeColor)
                .font(.system(size: 12, weight: .medium))
            
            Text(selectedBook?.title ?? "All Books")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.primary)
            
            Image(systemName: "chevron.down")
                .foregroundStyle(theme.themeColor)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(.horizontal, AppTheme.UIConstants.controlPadding)
        .frame(maxWidth: .infinity)
        .frame(height: AppTheme.UIConstants.controlHeight)
    }
}

// MARK: - Sort Button Label
private struct SortButtonLabel: View {
    let sortByNewest: Bool
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: AppTheme.UIConstants.searchSpacing) {
            Image(systemName: sortByNewest ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundStyle(theme.themeColor)
                .font(.system(size: 12, weight: .medium))
            
            Text(sortByNewest ? "Newest" : "Oldest")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.primary)
        }
        .padding(.horizontal, AppTheme.UIConstants.controlPadding)
        .frame(height: AppTheme.UIConstants.controlHeight)
    }
}

// MARK: - Shared Control Background
private struct ControlBackground: View {
    let theme: AppTheme
    let colorScheme: ColorScheme
    
    var body: some View {
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
                        controlBorderGradient,
                        lineWidth: colorScheme == .dark ? AppTheme.UIConstants.darkModeLineWidth : AppTheme.UIConstants.normalLineWidth
                    )
            )
    }
    
    private var controlBorderGradient: LinearGradient {
        if colorScheme == .dark {
            return LinearGradient(
                colors: [theme.themeColor.opacity(0.3), theme.themeColor.opacity(0.1), Color.clear],
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