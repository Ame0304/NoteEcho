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
    
    var body: some View {
        HStack(spacing: 12) {
            // Vertical accent bar
            RoundedRectangle(cornerRadius: 1)
                .fill(accentColor)
                .frame(width: 3, height: 24)
            
            // Main content area
            VStack(alignment: .leading, spacing: 4) {
                // Content and metadata in one line
                HStack(alignment: .top, spacing: 8) {
                    // Word content
                    Text(highlight.content)
                        .appFont(AppTypography.bodyRounded)
                        .foregroundColor(primaryTextColor)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    // Book title and date
                    VStack(alignment: .trailing, spacing: 2) {
                        if let book = highlight.book {
                            Text(book.title.uppercased())
                                .appFont(AppTypography.caption)
                                .foregroundColor(accentColor)
                                .textCase(.uppercase)
                                .lineLimit(1)
                        }
                        
                        Text(highlight.createdDate, format: .dateTime.month(.abbreviated).day())
                            .appFont(AppTypography.caption)
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    .multilineTextAlignment(.trailing)
                }
                
                // Optional personal note (compact)
                if let note = highlight.note, !note.isEmpty {
                    HStack(alignment: .top, spacing: 6) {
                        Text("💭")
                            .appFont(AppTypography.caption)
                        
                        Text(note)
                            .appFont(AppTypography.caption)
                            .italic()
                            .foregroundColor(theme.secondaryTextColor)
                            .lineLimit(1)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.cardBackgroundColor)
                .overlay(
                    // Theme color border on hover, subtle border otherwise
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isHovered
                                ? LinearGradient(
                                    colors: colorScheme == .dark 
                                        ? [theme.themeColor.opacity(0.4), theme.themeColor.opacity(0.2), Color.clear]
                                        : [theme.themeColor.opacity(0.3), theme.themeColor.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: colorScheme == .dark
                                        ? [Color.gray.opacity(0.2), Color.gray.opacity(0.1)]
                                        : [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                            lineWidth: isHovered ? (colorScheme == .dark ? 1.5 : 1) : (colorScheme == .dark ? 1 : 0.5)
                        )
                        .animation(.easeInOut(duration: 0.25), value: isHovered)
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
    @Previewable @State var sampleWordHighlight: Highlight = {
        let book = Book(title: "Atomic Habits", author: "James Clear", assetId: "test")
        let highlight = Highlight(
            content: "Perfection",
            note: "This word resonates",
            chapter: "Chapter 1"
        )
        highlight.book = book
        return highlight
    }()
    
    @Previewable @State var sampleShortHighlight: Highlight = {
        let book = Book(title: "The Psychology of Money", author: "Morgan Housel", assetId: "test2")
        let highlight = Highlight(
            content: "Be reasonable",
            note: nil,
            chapter: "Chapter 5"
        )
        highlight.book = book
        return highlight
    }()
    
    VStack(spacing: 12) {
        // Light mode previews
        WordCard(highlight: sampleWordHighlight)
            .environment(\.colorScheme, .light)
        
        WordCard(highlight: sampleShortHighlight)
            .environment(\.colorScheme, .light)
        
        // Dark mode previews
        WordCard(highlight: sampleWordHighlight)
            .environment(\.colorScheme, .dark)
        
        WordCard(highlight: sampleShortHighlight)
            .environment(\.colorScheme, .dark)
    }
    .padding()
    .frame(maxWidth: 400)
    .background(Color.gray.opacity(0.1))
}