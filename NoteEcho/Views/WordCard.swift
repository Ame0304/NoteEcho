import SwiftUI

struct WordCard: View {
    let highlight: Highlight
    
    // State for interactions
    @State private var isHovered = false
    @State private var isPressed = false
    
    // Theme system integration
    @Environment(\.colorScheme) private var colorScheme
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    private var lightThemeColor: Color {
        theme.themeColor.opacity(0.1)
    }
    
    private var primaryTextColor: Color {
        Color.primary // Automatically adapts to light/dark mode
    }
    
    // Generate accent color based on book title for variety
    private var accentColor: Color {
        guard let book = highlight.book else { return theme.themeColor }
        let colors: [Color] = [theme.themeColor, .blue, .purple, .orange, .cyan, .indigo]
        let hash = abs(book.title.hashValue)
        return colors[hash % colors.count]
    }
    
    // Helper to truncate book title for grid display
    private func truncatedBookTitle(_ title: String) -> String {
        if title.count <= 15 {
            return title
        }
        return String(title.prefix(12)) + "..."
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Top metadata - date on right
            HStack {
                Spacer()
                
                Text(highlight.createdDate, format: .dateTime.month(.abbreviated).day())
                    .appFont(AppTypography.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }
            
            // Spacer to center main content
            Spacer()
            
            // Main word content - prominently displayed and centered
            VStack(spacing: 8) {
                Text(highlight.content)
                    .appFont(AppTypography.titleSemibold)
                    .foregroundColor(isHovered ? accentColor : primaryTextColor)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Optional personal note (compact, centered)
                if let note = highlight.note, !note.isEmpty {
                    HStack(alignment: .top, spacing: 4) {
                        Text("💭")
                            .appFont(AppTypography.caption)
                        
                        Text(note)
                            .appFont(AppTypography.caption)
                            .italic()
                            .foregroundColor(theme.secondaryTextColor)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            
            // Bottom spacer to push book title down
            Spacer()
            
            // Bottom metadata - book title on right
            HStack {
                Spacer()
                
                if let book = highlight.book {
                    Text(truncatedBookTitle(book.title))
                        .appFont(AppTypography.caption)
                        .foregroundColor(accentColor)
                        .lineLimit(1)
                        .textCase(.uppercase)
                }
            }
        }
        .padding(16)
        .frame(width: 190, alignment: .center)
        .frame(minHeight: 130)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(theme.cardBackgroundColor)
                .overlay(
                    // Top accent border for book-like appearance
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            isHovered
                                ? LinearGradient(
                                    colors: [accentColor.opacity(0.6), accentColor.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: colorScheme == .dark
                                        ? [Color.gray.opacity(0.3), Color.gray.opacity(0.1)]
                                        : [Color.gray.opacity(0.15), Color.gray.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                            lineWidth: isHovered ? 2 : 1
                        )
                        .animation(.easeInOut(duration: 0.25), value: isHovered)
                )
                .overlay(
                    // Top accent stripe for book spine effect
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0.2), Color.clear],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                        .frame(height: 20)
                        .clipped(),
                    alignment: .top
                )
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            // Brief highlight animation on click
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
        }
        .overlay(
            // Flash overlay for click animation
            RoundedRectangle(cornerRadius: 8)
                .fill(lightThemeColor)
                .opacity(isPressed ? 0.3 : 0)
        )
    }
}

#Preview {
    @Previewable @State var sampleHighlights: [Highlight] = {
        let book1 = Book(title: "Atomic Habits", author: "James Clear", assetId: "test1")
        let book2 = Book(title: "The Psychology of Money", author: "Morgan Housel", assetId: "test2")
        let book3 = Book(title: "Deep Work", author: "Cal Newport", assetId: "test3")
        
        let highlights = [
            Highlight(content: "Focus", note: "Key concept", chapter: "Chapter 1"),
            Highlight(content: "Be reasonable", note: nil, chapter: "Chapter 5"),
            Highlight(content: "Excellence", note: "Important", chapter: "Chapter 3"),
            Highlight(content: "Simplify", note: nil, chapter: "Chapter 2"),
            Highlight(content: "Growth mindset", note: "Essential", chapter: "Chapter 4"),
            Highlight(content: "Patience", note: "Virtue", chapter: "Chapter 6")
        ]
        
        highlights[0].book = book1
        highlights[1].book = book2
        highlights[2].book = book3
        highlights[3].book = book1
        highlights[4].book = book2
        highlights[5].book = book3
        
        return highlights
    }()
    
    // Grid preview showcasing multiple cards
    LazyVGrid(columns: [
        GridItem(.adaptive(minimum: 190), spacing: 16)
    ], spacing: 16) {
        ForEach(sampleHighlights, id: \.id) { highlight in
            WordCard(highlight: highlight)
        }
    }
    .padding()
    .frame(maxWidth: 800)
    .background(Color.gray.opacity(0.1))
}