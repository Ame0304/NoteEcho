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
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(accentColor)
                        .textCase(.uppercase)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Right-aligned date in monospaced font
                Text(highlight.createdDate, format: .dateTime.month(.abbreviated).day().year())
                    .font(.system(size: 12, weight: .regular, design: .monospaced))
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
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(primaryTextColor)
                        .lineSpacing(6)
                        .multilineTextAlignment(.leading)
                    
                    // Optional personal note section
                    if let note = highlight.note, !note.isEmpty {
                        HStack(alignment: .top, spacing: 8) {
                            Text("💭")
                                .font(.system(size: 14))
                                .padding(.top, 1)
                            
                            Text(note)
                                .font(.body)
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
                .shadow(
                    color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.1),
                    radius: isHovered ? 12 : 6,
                    x: 0,
                    y: isHovered ? 6 : 3
                )
                .overlay(
                    // Subtle inner glow for dark mode, border for light mode
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            colorScheme == .dark
                                ? LinearGradient(
                                    colors: [accentColor.opacity(0.3), accentColor.opacity(0.1), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                            lineWidth: colorScheme == .dark ? 1 : 0.5
                        )
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
