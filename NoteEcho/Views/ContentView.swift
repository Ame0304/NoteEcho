import SwiftUI
import SwiftData

struct ContentView: View {
    // SwiftData environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    // SwiftData queries
    @Query private var books: [Book]
    @Query private var allHighlights: [Highlight]
    
    // State variables - these hold the current UI state and trigger view updates when changed
    @State private var selectedBook: Book?     // Currently selected book for filtering (nil = all books)
    @State private var sortByNewest = true     // Sort direction: true = newest first, false = oldest first
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    
    // Computed property that filters and sorts highlights based on current UI state
    // This automatically recalculates whenever any of the state variables change
    private var filteredHighlights: [Highlight] {
        var highlights = allHighlights
        
        // Step 1: Filter by selected book (if any)
        if let selectedBook = selectedBook {
            // $0.book?.id - Gets the ID of the book that this highlight belongs to
            highlights = highlights.filter { $0.book?.id == selectedBook.id }
        }
        
        // Step 2: Filter by search text (searches in content, notes, and book titles)
        if !searchText.isEmpty {
            highlights = highlights.filter { highlight in
                highlight.content.localizedCaseInsensitiveContains(searchText) ||
                highlight.note?.localizedCaseInsensitiveContains(searchText) == true ||
                highlight.book?.title.localizedCaseInsensitiveContains(searchText) == true
            }
        }
        
        // Step 3: Sort by creation date
        return highlights.sorted { 
            sortByNewest ? $0.createdDate > $1.createdDate : $0.createdDate < $1.createdDate
        }
    }

    var body: some View {
        ZStack {
            // Blurred gradient background
            BlurredGradientBackground()
            
            NavigationStack {
                VStack(spacing: 0) {
                    // MARK: - Filter and Sort Controls
                    VStack(spacing: 16) {
                        // Search bar component
                        SearchBar(
                            searchText: $searchText,
                            isSearchFocused: $isSearchFocused
                        )
                        
                        // Filter and sort controls
                        FilterControls(
                            selectedBook: $selectedBook,
                            sortByNewest: $sortByNewest,
                            books: books
                        )
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                
                // MARK: - Highlights Display Area
                // Show either the highlights list or an empty state message
                if filteredHighlights.isEmpty {
                    // Empty state - shown when no highlights match the current filters
                    VStack(spacing: 16) {
                        Image(systemName: "highlighter")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("No highlights found")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                        // Show different message if user is searching vs. no highlights at all
                        if !searchText.isEmpty {
                            Text("Try adjusting your search")
                                .font(.body)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)  // Center the empty state
                } else {
                    // Highlights list - scrollable list of highlight cards
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
            .navigationTitle("NoteEcho")
            .onAppear {
                // Populate with sample data when the view first appears
                // This only runs once since MockDataService checks if data already exists
                MockDataService.populateWithSampleData(modelContext: modelContext)
            }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Book.self, Highlight.self], inMemory: true)
}
