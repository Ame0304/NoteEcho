import Foundation

// MARK: - Highlight Filtering Service
struct HighlightFilterService {
    
    // MARK: - Language Detection Helpers
    
    /// Detects if text is primarily Chinese based on CJK character ratio
    private static func isPrimarilyChinese(_ text: String) -> Bool {
        let chineseCount = chineseCharacterCount(text)
        let totalCount = text.count
        
        // Consider text Chinese if >30% of characters are CJK
        guard totalCount > 0 else { return false }
        return Double(chineseCount) / Double(totalCount) > 0.3
    }
    
    /// Counts Chinese/CJK characters in text
    private static func chineseCharacterCount(_ text: String) -> Int {
        return text.reduce(0) { count, char in
            let scalar = char.unicodeScalars.first?.value ?? 0
            // CJK Unicode ranges:
            // 0x4E00-0x9FFF: CJK Unified Ideographs (most common Chinese characters)
            // 0x3400-0x4DBF: CJK Extension A
            // 0x20000-0x2A6DF: CJK Extension B
            // 0xF900-0xFAFF: CJK Compatibility Ideographs
            if (scalar >= 0x4E00 && scalar <= 0x9FFF) ||
               (scalar >= 0x3400 && scalar <= 0x4DBF) ||
               (scalar >= 0x20000 && scalar <= 0x2A6DF) ||
               (scalar >= 0xF900 && scalar <= 0xFAFF) {
                return count + 1
            }
            return count
        }
    }
    
    /// Categorizes highlights into Words and Highlights based on content length with language-specific logic
    static func categorizeHighlights(from highlights: [Highlight]) -> (words: [Highlight], highlights: [Highlight]) {
        let words = highlights.filter { highlight in
            let content = highlight.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if isPrimarilyChinese(content) {
                // For Chinese text: use character count (characters are more information-dense)
                let chineseCharCount = chineseCharacterCount(content)
                return chineseCharCount <= 12  // 12 Chinese characters or fewer = Words
            } else {
                // For English/Latin text: use word count based on spaces
                let wordCount = content.split(separator: " ").count
                return wordCount <= 4  // 4 words or fewer = Words
            }
        }
        
        let regularHighlights = highlights.filter { highlight in
            let content = highlight.content.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if isPrimarilyChinese(content) {
                // For Chinese text: use character count
                let chineseCharCount = chineseCharacterCount(content)
                return chineseCharCount > 12  // More than 12 Chinese characters = Highlights
            } else {
                // For English/Latin text: use word count based on spaces
                let wordCount = content.split(separator: " ").count
                return wordCount > 4  // More than 4 words = Highlights
            }
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