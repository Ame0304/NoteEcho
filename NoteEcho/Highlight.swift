import Foundation
import SwiftData

@Model
final class Highlight {
    var id: String
    var content: String
    var note: String?
    var chapter: String?
    var createdDate: Date
    
    @Relationship(inverse: \Book.highlights) var book: Book?
    
    init(id: String = UUID().uuidString, content: String, note: String? = nil, chapter: String? = nil, createdDate: Date = Date()) {
        self.id = id
        self.content = content
        self.note = note
        self.chapter = chapter
        self.createdDate = createdDate
    }
}