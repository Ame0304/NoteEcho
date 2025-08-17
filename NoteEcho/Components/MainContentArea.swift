import SwiftUI

// MARK: - Main Content Area Component
struct MainContentArea: View {
    @Binding var searchText: String
    @FocusState.Binding var isSearchFocused: Bool
    @Binding var sortByNewest: Bool
    let filteredHighlights: [Highlight]
    let allHighlights: [Highlight] // Added for daily echo selection
    @Environment(\.colorScheme) private var colorScheme
    
    private var theme: AppTheme {
        AppTheme(colorScheme: colorScheme)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Daily Echo Section
            if let dailyHighlight = allHighlights.dailyRandomHighlight {
                DailyEchoCard(highlight: dailyHighlight)
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
                        .background(
                            ControlBackground(theme: theme, colorScheme: colorScheme)
                        )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            // MARK: - Highlights Display Area
            if filteredHighlights.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Image(systemName: "highlighter")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                    Text("No highlights found")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    if !searchText.isEmpty {
                        Text("Try adjusting your search")
                            .font(.body)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Highlights list
                ScrollView {
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
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: filteredHighlights)
                    .padding(.top, 8)
                    .padding(.bottom, 20)
                }
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
                .font(.system(size: 12, weight: .medium))
            
            Text(sortByNewest ? "Newest" : "Oldest")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.primary)
        }
        .padding(.horizontal, AppTheme.UIConstants.controlPadding)
        .frame(height: AppTheme.UIConstants.controlHeight)
    }
}

// MARK: - Shared Control Background (extracted from FilterControls)
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
