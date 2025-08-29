import Foundation

// MARK: - Highlight Filtering Service
struct HighlightFilterService {
    
    /// Categorizes highlights into Words and Highlights based on content length
    static func categorizeHighlights(from highlights: [Highlight]) -> (words: [Highlight], highlights: [Highlight]) {
        let words = highlights.filter { highlight in
            let wordCount = highlight.content.split(separator: " ").count
            let charCount = highlight.content.trimmingCharacters(in: .whitespacesAndNewlines).count
            return wordCount < 4 && charCount < 6  // Less than 4 words AND less than 6 characters
        }
        
        let regularHighlights = highlights.filter { highlight in
            let wordCount = highlight.content.split(separator: " ").count
            let charCount = highlight.content.trimmingCharacters(in: .whitespacesAndNewlines).count
            return wordCount >= 4 || charCount >= 6  // 4+ words OR 6+ characters
        }
        
        return (words: words, highlights: regularHighlights)
    }
    
    /// Filters highlights by content type and other criteria
    static func filteredContent(
        from highlights: [Highlight],
        contentType: ContentType,
        selectedBook: Book?,
        searchText: String,
        sortByNewest: Bool
    ) -> [Highlight] {
        let (words, regularHighlights) = categorizeHighlights(from: highlights)
        let contentToFilter = contentType == .words ? words : regularHighlights
        
        return contentToFilter
            .filterByBook(selectedBook)
            .filterBySearchText(searchText)
            .sortByDate(newest: sortByNewest)
    }
    
    /// Legacy method for backwards compatibility - returns only regular highlights
    static func filteredHighlights(
        from highlights: [Highlight],
        selectedBook: Book?,
        searchText: String,
        sortByNewest: Bool
    ) -> [Highlight] {
        return filteredContent(
            from: highlights,
            contentType: .highlights,
            selectedBook: selectedBook,
            searchText: searchText,
            sortByNewest: sortByNewest
        )
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
    
    
    func sortByDate(newest: Bool) -> [Highlight] {
        return self.sorted { 
            newest ? $0.createdDate > $1.createdDate : $0.createdDate < $1.createdDate
        }
    }
}