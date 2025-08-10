import SwiftUI

struct HighlightCard: View {
    let highlight: Highlight
    
    // Generate a color based on book title for visual variety
    private var accentColor: Color {
        guard let book = highlight.book else { return .blue }
        let colors: [Color] = [.blue, .purple, .pink, .orange, .green, .cyan, .indigo]
        let hash = abs(book.title.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Highlight content - enhanced with better typography and accent
            HStack(alignment: .top, spacing: 0) {
                // Colorful accent bar on the left
                RoundedRectangle(cornerRadius: 2)
                    .fill(accentColor)
                    .frame(width: 4)
                    .padding(.trailing, 12)
                
                Text(highlight.content)
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .lineSpacing(2)
                    .foregroundStyle(.primary)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
            }
            
            // Personal note section - enhanced with modern styling
            if let note = highlight.note, !note.isEmpty {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow)
                        .font(.system(size: 14, weight: .medium))
                        .padding(.top, 2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Personal Note")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        
                        Text(note)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(.secondary)
                            .italic()
                            .lineSpacing(1)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.yellow.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.yellow.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Book and metadata information - enhanced with colors and better layout
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Book info with colorful icon
                    HStack(spacing: 6) {
                        Image(systemName: "book.closed.fill")
                            .foregroundStyle(accentColor)
                            .font(.system(size: 12, weight: .medium))
                        
                        if let book = highlight.book {
                            Text(book.title)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.primary)
                            
                            Text("by \(book.author)")
                                .font(.system(size: 13, weight: .regular))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Date with icon
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 11))
                        
                        Text(highlight.createdDate, style: .date)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Chapter info if available
                if let chapter = highlight.chapter, !chapter.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "text.book.closed")
                            .foregroundStyle(accentColor.opacity(0.7))
                            .font(.system(size: 11, weight: .medium))
                        
                        Text(chapter)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.gray.opacity(0.3), lineWidth: 0.5)
                )
        )
        .overlay(
            // Subtle gradient overlay for depth
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(0.02), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

#Preview {
    let book = Book(title: "Atomic Habits", author: "James Clear", assetId: "test")
    let highlight = Highlight(
        content: "You do not rise to the level of your goals. You fall to the level of your systems.",
        note: "This is a key insight about habit formation",
        chapter: "Chapter 1: The Surprising Power of Atomic Habits"
    )
    highlight.book = book
    
    return HighlightCard(highlight: highlight)
        .padding()
        .frame(maxWidth: 400)
}
