import SwiftUI
import SwiftData

struct DailyEchoCard: View {
    let highlight: Highlight?
    let onRegenerate: (() -> Void)?
    
    // Theme system integration
    @Environment(\.colorScheme) private var colorScheme
    
    // State for interactions (moved from HighlightCard)
    @State private var isHovered = false
    @State private var isPressed = false
    @State private var isRegenerateButtonHovered = false
    @State private var regenerateRotation: Double = 0
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    private var lightThemeColor: Color {
        theme.themeColor.opacity(0.15)
    }
    
    private var primaryTextColor: Color {
        Color.primary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let highlight = highlight {
                // Daily Echo Header
                HStack(spacing: 8) {
                    Image(systemName: "star.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(theme.themeColor)
                    
                    Text("DAILY ECHO")
                        .font(.system(size: 14, weight: .bold, design: .default))
                        .foregroundColor(theme.themeColor)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    // Regenerate button
                    if let onRegenerate = onRegenerate {
                        Button(action: {
                            // Add click rotation animation with smooth easeOut
                            withAnimation(.easeOut(duration: 0.4)) {
                                regenerateRotation += 360
                            }
                            onRegenerate()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(isRegenerateButtonHovered ? theme.themeColor : theme.themeColor.opacity(0.8))
                                .background(
                                    Circle()
                                        .fill(theme.themeColor.opacity(isRegenerateButtonHovered ? 0.1 : 0))
                                        .frame(width: 24, height: 24)
                                )
                                .rotationEffect(.degrees(isRegenerateButtonHovered ? 180 : 0))
                                .animation(.easeInOut(duration: 0.25), value: isRegenerateButtonHovered)
                                .rotationEffect(.degrees(regenerateRotation))
                                .animation(.easeOut(duration: 0.4), value: regenerateRotation)
                        }
                        .buttonStyle(.plain)
                        .help("Get a new random highlight")
                        .onHover { hovering in
                            isRegenerateButtonHovered = hovering
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
                
                // Extracted HighlightCard Content (without background styling)
                VStack(alignment: .leading, spacing: 0) {
                    // Top row: Book title and date (from HighlightCard)
                    HStack(alignment: .top) {
                        // Left-aligned book title
                        if let book = highlight.book {
                            Text(book.title.uppercased())
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(theme.themeColor) // Use theme color consistently
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
                    
                    // Main content with vertical accent bar (from HighlightCard)
                    HStack(alignment: .top, spacing: 0) {
                        // Vertical accent bar aligned with first line of text
                        RoundedRectangle(cornerRadius: 1)
                            .fill(theme.themeColor) // Use theme color consistently
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
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
            } else {
                // Empty state for when no highlights are available
                VStack(spacing: 16) {
                    // Daily Echo Header (even in empty state)
                    HStack(spacing: 8) {
                        Image(systemName: "star.circle.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(theme.themeColor)
                        
                        Text("DAILY ECHO")
                            .font(.system(size: 14, weight: .bold, design: .default))
                            .foregroundColor(theme.themeColor)
                            .textCase(.uppercase)
                        
                        Spacer()
                        
                        // Regenerate button (disabled in empty state)
                        if let onRegenerate = onRegenerate {
                            Button(action: onRegenerate) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(theme.themeColor.opacity(0.3))
                                    .background(
                                        Circle()
                                            .fill(Color.clear)
                                            .frame(width: 24, height: 24)
                                    )
                            }
                            .buttonStyle(.plain)
                            .disabled(true)
                            .help("No highlights available")
                        }
                    }
                    .padding(.bottom, 8)
                    
                    // Empty state content
                    VStack(spacing: 12) {
                        Image(systemName: "star.circle")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                        
                        Text("No highlights available for today's echo")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
                .padding(20)
            }
        }
        .background(
            // Unified background styling for entire Daily Echo card
            RoundedRectangle(cornerRadius: 16)
                .fill(theme.cardBackgroundColor)
                .shadow(
                    color: colorScheme == .dark ? Color.clear : Color.black.opacity(0.15),
                    radius: isHovered ? 16 : 12,
                    x: 0,
                    y: isHovered ? 8 : 6
                )
                .overlay(
                    // Enhanced border with theme color
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: colorScheme == .dark 
                                    ? [theme.themeColor.opacity(0.4), theme.themeColor.opacity(0.2), Color.clear]
                                    : [theme.themeColor.opacity(0.3), theme.themeColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: colorScheme == .dark ? 1.5 : 1
                        )
                )
                .overlay(
                    // Subtle inner glow effect
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            RadialGradient(
                                colors: [theme.themeColor.opacity(0.06), Color.clear],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .opacity(colorScheme == .dark ? 1 : 0.5)
                )
        )
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovered)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            // Brief highlight animation on click (from HighlightCard)
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
            // Flash overlay for click animation (from HighlightCard)
            RoundedRectangle(cornerRadius: 16)
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
        // Light mode preview with highlight
        DailyEchoCard(highlight: sampleHighlight, onRegenerate: { print("Regenerate tapped") })
            .environment(\.colorScheme, .light)
        
        // Dark mode preview with highlight
        DailyEchoCard(highlight: sampleHighlight, onRegenerate: { print("Regenerate tapped") })
            .environment(\.colorScheme, .dark)
        
        // Empty state preview
        DailyEchoCard(highlight: nil, onRegenerate: { print("Regenerate tapped") })
            .environment(\.colorScheme, .light)
    }
    .padding()
    .frame(maxWidth: 500)
    .background(Color.gray.opacity(0.1))
}