import Foundation

// MARK: - Highlight Filtering Service
struct HighlightFilterService {
    
    /// Filters and sorts highlights based on provided criteria
    static func filteredHighlights(
        from highlights: [Highlight],
        selectedBook: Book?,
        searchText: String,
        sortByNewest: Bool
    ) -> [Highlight] {
        return highlights
            .filterByBook(selectedBook)
            .filterBySearchText(searchText)
            .filterByMinimumWordCount()
            .sortByDate(newest: sortByNewest)
    }
    
    /// Filters books to only show those with highlights
    static func booksWithHighlights(from books: [Book]) -> [Book] {
        return books.filter { !$0.highlights.isEmpty }
    }
}

// MARK: - Array Extensions for Highlight Filtering
private extension Array where Element == Highlight {
    
    func filterByBook(_ selectedBook: Book?) -> [Highlight] {
        guard let selectedBook = selectedBook else { return self }
        return self.filter { $0.book?.id == selectedBook.id }
    }
    
    func filterBySearchText(_ searchText: String) -> [Highlight] {
        guard !searchText.isEmpty else { return self }
        return self.filter { highlight in
            highlight.content.localizedCaseInsensitiveContains(searchText) ||
            highlight.note?.localizedCaseInsensitiveContains(searchText) == true ||
            highlight.book?.title.localizedCaseInsensitiveContains(searchText) == true
        }
    }
    
    func filterByMinimumWordCount() -> [Highlight] {
        return self.filter { highlight in
            let wordCount = highlight.content.split(separator: " ").count
            let charCount = highlight.content.trimmingCharacters(in: .whitespacesAndNewlines).count
            return wordCount >= 3 || charCount >= 6  // 3+ words OR 6+ characters for Chinese
        }
    }
    
    func sortByDate(newest: Bool) -> [Highlight] {
        return self.sorted { 
            newest ? $0.createdDate > $1.createdDate : $0.createdDate < $1.createdDate
        }
    }
}