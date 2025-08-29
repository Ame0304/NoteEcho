import SwiftUI

// MARK: - Main Content Area Component
struct MainContentArea: View {
    let selectedContentType: ContentType
    @Binding var searchText: String
    @FocusState.Binding var isSearchFocused: Bool
    @Binding var sortByNewest: Bool
    let filteredHighlights: [Highlight]
    let allHighlights: [Highlight] // Added for daily echo selection
    @Environment(\.colorScheme) private var colorScheme
    
    // Override state for manual daily echo regeneration
    @State private var overrideHighlightId: String?
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    // Computed property for current daily echo highlight
    private var currentDailyHighlight: Highlight? {
        // If we have an override, try to find it in allHighlights
        if let overrideId = overrideHighlightId,
           let overrideHighlight = allHighlights.first(where: { $0.id == overrideId }) {
            return overrideHighlight
        }
        
        // Otherwise, use the daily selection
        return allHighlights.dailyRandomHighlight
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Daily Echo Section
            if let dailyHighlight = currentDailyHighlight {
                DailyEchoCard(highlight: dailyHighlight, onRegenerate: regenerateDailyEcho)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
            }
            
            // MARK: - Search and Sort Controls
            HStack(spacing: AppTheme.UIConstants.controlSpacing) {
                // Search bar (flexible width)
                SearchBar(
                    searchText: $searchText,
                    isSearchFocused: $isSearchFocused
                )
                
                // Sort button (fixed width)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        sortByNewest.toggle()
                    }
                } label: {
                    SortButtonLabel(sortByNewest: sortByNewest, theme: theme)
                        .controlBackground(theme: theme, colorScheme: colorScheme)
                }
                .buttonStyle(.plain)
                .pointingHandCursor()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            // MARK: - Content Display Area
            if filteredHighlights.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: selectedContentType.iconName)
                        .appFont(AppTypography.largeTitle)
                        .foregroundStyle(.secondary)
                    Text("No \(selectedContentType.displayName.lowercased()) found")
                        .appFont(AppTypography.title2Rounded)
                        .foregroundStyle(.secondary)
                    if !searchText.isEmpty {
                        Text("Try adjusting your search")
                            .appFont(AppTypography.bodyRounded)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Content list - display different layouts based on content type
                ScrollView {
                    if selectedContentType == .words {
                        // Grid layout for Words
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 190), spacing: 16)
                        ], spacing: 16) {
                            ForEach(filteredHighlights, id: \.id) { highlight in
                                WordCard(highlight: highlight)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                                        removal: .scale(scale: 0.9).combined(with: .opacity)
                                    ))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 20)
                    } else {
                        // List layout for Highlights
                        LazyVStack(spacing: 20) {
                            ForEach(filteredHighlights, id: \.id) { highlight in
                                HighlightCard(highlight: highlight)
                                    .padding(.horizontal)
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                                        removal: .scale(scale: 0.9).combined(with: .opacity)
                                    ))
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                }
                .animation(.spring(response: 0.6, dampingFraction: 0.8), value: filteredHighlights)
                .animation(.easeInOut(duration: 0.3), value: selectedContentType)
            }
        }
    }
    
    // MARK: - Regenerate Daily Echo
    private func regenerateDailyEcho() {
        // Get current highlight ID to exclude from new selection
        let currentId = currentDailyHighlight?.id
        
        // Get a new random highlight excluding the current one
        if let newHighlight = allHighlights.randomHighlightExcluding(currentId) {
            withAnimation(.easeInOut(duration: 0.3)) {
                overrideHighlightId = newHighlight.id
            }
        }
    }
}

// MARK: - Sort Button Label (extracted from FilterControls)
private struct SortButtonLabel: View {
    let sortByNewest: Bool
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: AppTheme.UIConstants.searchSpacing) {
            Image(systemName: sortByNewest ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .foregroundStyle(theme.themeColor)
                .appFont(AppTypography.captionMedium)
            
            Text(sortByNewest ? "Newest" : "Oldest")
                .appFont(AppTypography.captionMedium)
                .foregroundStyle(Color.primary)
        }
        .padding(.horizontal, AppTheme.UIConstants.controlPadding)
        .frame(height: AppTheme.UIConstants.controlHeight)
    }
}

