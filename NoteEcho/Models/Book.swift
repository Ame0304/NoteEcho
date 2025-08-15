import Foundation
import SwiftData

@Model
final class Book {
    var id: String
    var title: String
    var author: String
    var assetId: String
    
    @Relationship(deleteRule: .cascade) var highlights: [Highlight] = []
    
    init(id: String = UUID().uuidString, title: String, author: String, assetId: String) {
        self.id = id
        self.title = title
        self.author = author
        self.assetId = assetId
    }
}