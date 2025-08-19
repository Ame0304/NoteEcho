import SwiftUI
import SwiftData

struct HighlightCard: View {
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
        VStack(alignment: .leading, spacing: 0) {
            // Top row: Book title and date
            HStack(alignment: .top) {
                // Left-aligned book title
                if let book = highlight.book {
                    Text(book.title.uppercased())
                        .appFont(AppTypography.captionMedium)
                        .foregroundColor(accentColor)
                        .textCase(.uppercase)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Right-aligned date in monospaced font
                Text(highlight.createdDate, format: .dateTime.month(.abbreviated).day().year())
                    .appFont(AppTypography.timestamp)
                    .foregroundColor(theme.secondaryTextColor)
            }
            .padding(.bottom, 12)
            
            // Main content with vertical accent bar
            HStack(alignment: .top, spacing: 0) {
                // Vertical accent bar aligned with first line of text
                RoundedRectangle(cornerRadius: 1)
                    .fill(accentColor)
                    .frame(width: 3, height: 20)
                    .padding(.trailing, 12)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Main highlight text
                    Text(highlight.content)
                        .appFont(AppTypography.title3Rounded)
                        .foregroundColor(primaryTextColor)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                    
                    // Optional personal note section
                    if let note = highlight.note, !note.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Text("💭")
                                .appFont(AppTypography.body)
                                .padding(.top, 1)
                            
                            Text(note)
                                .appFont(AppTypography.bodyRounded)
                                .italic()
                                .foregroundColor(theme.secondaryTextColor)
                                .lineSpacing(3)
                                .multilineTextAlignment(.leading)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(theme.cardBackgroundColor)
                .overlay(
                    // Theme color border on hover, subtle border otherwise
                    RoundedRectangle(cornerRadius: 12)
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
            RoundedRectangle(cornerRadius: 12)
                .fill(lightThemeColor)
                .opacity(isPressed ? 0.3 : 0)
        )
    }
}

#Preview {
    @Previewable @State var sampleHighlight: Highlight = {
        let book = Book(title: "Atomic Habits", author: "James Clear", assetId: "test")
        let highlight = Highlight(
            content: "You do not rise to the level of your goals. You fall to the level of your systems.",
            note: "This is a key insight about habit formation and building better systems",
            chapter: "Chapter 1: The Surprising Power of Atomic Habits"
        )
        highlight.book = book
        return highlight
    }()
    
    VStack(spacing: 20) {
        // Light mode preview
        HighlightCard(highlight: sampleHighlight)
            .environment(\.colorScheme, .light)
        
        // Dark mode preview
        HighlightCard(highlight: sampleHighlight)
            .environment(\.colorScheme, .dark)
    }
    .padding()
    .frame(maxWidth: 400)
    .background(Color.gray.opacity(0.1))
}
