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
    
    // Computed property that filters books to only show those with highlights
    private var booksWithHighlights: [Book] {
        let filteredBooks = books.filter { !$0.highlights.isEmpty }
        
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
