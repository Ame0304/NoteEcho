import SwiftUI
import SwiftData

struct ContentView: View {
    // SwiftData environment
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    // Notification manager
    @EnvironmentObject private var notificationManager: NotificationManager
    
    // SwiftData queries - optimized with sorting at database level
    @Query(sort: \Book.title, order: .forward) private var books: [Book]
    @Query(sort: \Highlight.createdDate, order: .reverse) private var allHighlights: [Highlight]
    
    // State variables - these hold the current UI state and trigger view updates when changed
    @State private var selectedBook: Book?     // Currently selected book for filtering (nil = all books)
    @State private var sortByNewest = true     // Sort direction: true = newest first, false = oldest first
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var isRefreshing = false
    
    // Computed property that filters books to only show those with highlights
    private var booksWithHighlights: [Book] {
        let filteredBooks = HighlightFilterService.booksWithHighlights(from: books)
        
        // If currently selected book has no highlights, deselect it
        if let selectedBook = selectedBook, !filteredBooks.contains(where: { $0.id == selectedBook.id }) {
            DispatchQueue.main.async {
                self.selectedBook = nil
            }
        }
        
        return filteredBooks
    }
    
    // Computed property that filters and sorts highlights based on current UI state
    // This automatically recalculates whenever any of the state variables change
    private var filteredHighlights: [Highlight] {
        return HighlightFilterService.filteredHighlights(
            from: allHighlights,
            selectedBook: selectedBook,
            searchText: searchText,
            sortByNewest: sortByNewest
        )
    }
    
    // MARK: - Refresh Data
    private func refreshData() {
        isRefreshing = true
        
        Task.detached { [modelContext] in
            AppleBooksDataService.populateWithAppleBooksData(modelContext: modelContext)
            
            await MainActor.run {
                isRefreshing = false
            }
        }
    }

    var body: some View {
        ZStack {
            // Blurred gradient background
            BlurredGradientBackground()
            
            NavigationStack {
                HSplitView {
                    // MARK: - Book Sidebar
                    BookSidebar(
                        selectedBook: $selectedBook,
                        books: booksWithHighlights
                    )
                    
                    // MARK: - Main Content Area
                    MainContentArea(
                        searchText: $searchText,
                        isSearchFocused: $isSearchFocused,
                        sortByNewest: $sortByNewest,
                        filteredHighlights: filteredHighlights,
                        allHighlights: allHighlights
                    )
                }
                .navigationTitle("NoteEcho")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: refreshData) {
                            if isRefreshing {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                        }
                        .disabled(isRefreshing)
                        .pointingHandCursor()
                    }
                }
                .onAppear {
                    // Populate with Apple Books data when the view first appears
                    AppleBooksDataService.populateWithAppleBooksData(modelContext: modelContext)
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Book.self, Highlight.self], inMemory: true)
}
