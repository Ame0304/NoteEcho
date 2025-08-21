import Foundation
import SwiftData
import SQLite3

class AppleBooksDataService {
    
    // MARK: - Database Paths
    
    private static let annotationBasePath = NSHomeDirectory() + "/Library/Containers/com.apple.iBooksX/Data/Documents/AEAnnotation"
    private static let libraryBasePath = NSHomeDirectory() + "/Library/Containers/com.apple.iBooksX/Data/Documents/BKLibrary"
    
    // MARK: - Public Interface
    static func populateWithAppleBooksData(modelContext: ModelContext) {
        // Clear any existing data (mock or old real data) to ensure fresh Apple Books data
        do {
            let bookDescriptor = FetchDescriptor<Book>()
            let existingBooks = try modelContext.fetch(bookDescriptor)
            for book in existingBooks {
                modelContext.delete(book)
            }
            
            let highlightDescriptor = FetchDescriptor<Highlight>()
            let existingHighlights = try modelContext.fetch(highlightDescriptor)
            for highlight in existingHighlights {
                modelContext.delete(highlight)
            }
            
            try modelContext.save()
            print("🗑️ Cleared existing data to load fresh Apple Books highlights")
        } catch {
            print("⚠️ Warning: Could not clear existing data: \(error)")
        }
        
        // Try to load real Apple Books data
        do {
            let (books, highlights) = try loadAppleBooksData()
            
            // Insert books first
            for book in books {
                modelContext.insert(book)
            }
            
            // Then create and insert highlights, linking them to books
            for appleBooksHighlight in highlights {
                if let book = books.first(where: { $0.assetId == appleBooksHighlight.assetId }) {
                    let highlight = Highlight(
                        id: appleBooksHighlight.id,
                        content: appleBooksHighlight.content,
                        note: appleBooksHighlight.note,
                        chapter: appleBooksHighlight.chapter,
                        createdDate: appleBooksHighlight.createdDate
                    )
                    highlight.book = book
                    modelContext.insert(highlight)
                }
            }
            
            try modelContext.save()
            print("✅ Successfully loaded \(highlights.count) highlights from \(books.count) Apple Books")
            
        } catch {
            print("⚠️ Failed to load Apple Books data: \(error)")
            print("📱 App will continue with empty state. Check Apple Books database access permissions.")
            
            // App continues with empty state - user can manually add highlights or check permissions
            // Future enhancement: Could add inline minimal sample data here if needed
        }
    }
    
    // MARK: - Private Implementation
    private static func loadAppleBooksData() throws -> ([Book], [AppleBooksHighlight]) {
        let books = try loadBooksFromAppleBooks()
        let highlights = try loadHighlightsFromAppleBooks()
        return (books, highlights)
    }
    
    private static func loadBooksFromAppleBooks() throws -> [Book] {
        let dbPath = try findLibraryDatabase()
        var db: OpaquePointer?
        
        guard sqlite3_open(dbPath, &db) == SQLITE_OK else {
            throw AppleBooksError.databaseConnectionFailed
        }
        defer { sqlite3_close(db) }
        
        let query = """
            SELECT ZASSETID, ZTITLE, ZAUTHOR 
            FROM ZBKLIBRARYASSET 
            WHERE ZASSETID IS NOT NULL 
              AND ZTITLE IS NOT NULL 
              AND ZAUTHOR IS NOT NULL
            ORDER BY ZTITLE
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            throw AppleBooksError.queryPreparationFailed
        }
        defer { sqlite3_finalize(statement) }
        
        var books: [Book] = []
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let assetId = String(cString: sqlite3_column_text(statement, 0))
            let title = String(cString: sqlite3_column_text(statement, 1))
            let author = String(cString: sqlite3_column_text(statement, 2))
            
            let book = Book(title: title, author: author, assetId: assetId)
            books.append(book)
        }
        
        return books
    }
    
    private static func loadHighlightsFromAppleBooks() throws -> [AppleBooksHighlight] {
        let dbPath = try findAnnotationDatabase()
        var db: OpaquePointer?
        
        guard sqlite3_open(dbPath, &db) == SQLITE_OK else {
            throw AppleBooksError.databaseConnectionFailed
        }
        defer { sqlite3_close(db) }
        
        let query = """
            SELECT ZANNOTATIONASSETID, ZANNOTATIONSELECTEDTEXT, ZANNOTATIONNOTE, 
                   ZFUTUREPROOFING5, ZANNOTATIONCREATIONDATE, ZANNOTATIONUUID
            FROM ZAEANNOTATION 
            WHERE ZANNOTATIONDELETED = 0 
              AND ZANNOTATIONSELECTEDTEXT IS NOT NULL 
              AND ZANNOTATIONSELECTEDTEXT != ''
            ORDER BY ZANNOTATIONCREATIONDATE DESC
        """
        
        var statement: OpaquePointer?
        guard sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK else {
            throw AppleBooksError.queryPreparationFailed
        }
        defer { sqlite3_finalize(statement) }
        
        var highlights: [AppleBooksHighlight] = []
        
        while sqlite3_step(statement) == SQLITE_ROW {
            let assetId = String(cString: sqlite3_column_text(statement, 0))
            let content = String(cString: sqlite3_column_text(statement, 1))
            
            // Handle optional note
            let note: String? = sqlite3_column_text(statement, 2) != nil ? 
                String(cString: sqlite3_column_text(statement, 2)) : nil
            
            // Handle optional chapter
            let chapter: String? = sqlite3_column_text(statement, 3) != nil ? 
                String(cString: sqlite3_column_text(statement, 3)) : nil
            
            // Convert Core Data timestamp to Date
            let timestamp = sqlite3_column_double(statement, 4)
            let createdDate = Date(timeIntervalSinceReferenceDate: timestamp)
            
            // Use Apple Books UUID if available, otherwise generate one
            let id: String = sqlite3_column_text(statement, 5) != nil ? 
                String(cString: sqlite3_column_text(statement, 5)) : UUID().uuidString
            
            let highlight = AppleBooksHighlight(
                id: id,
                content: content,
                note: note,
                chapter: chapter,
                createdDate: createdDate,
                assetId: assetId
            )
            highlights.append(highlight)
        }
        
        return highlights
    }
    
    // MARK: - Database Path Discovery
    private static func findAnnotationDatabase() throws -> String {
        let annotationDir = URL(fileURLWithPath: annotationBasePath)
        
        guard FileManager.default.fileExists(atPath: annotationDir.path) else {
            throw AppleBooksError.annotationDirectoryNotFound
        }
        
        let contents = try FileManager.default.contentsOfDirectory(
            at: annotationDir,
            includingPropertiesForKeys: nil
        )
        
        // Look for SQLite database file
        for file in contents {
            if file.pathExtension == "sqlite" && file.lastPathComponent.contains("AEAnnotation") {
                return file.path
            }
        }
        
        throw AppleBooksError.annotationDatabaseNotFound
    }
    
    private static func findLibraryDatabase() throws -> String {
        let libraryDir = URL(fileURLWithPath: libraryBasePath)
        
        guard FileManager.default.fileExists(atPath: libraryDir.path) else {
            throw AppleBooksError.libraryDirectoryNotFound
        }
        
        let contents = try FileManager.default.contentsOfDirectory(
            at: libraryDir,
            includingPropertiesForKeys: nil
        )
        
        // Look for SQLite database file
        for file in contents {
            if file.pathExtension == "sqlite" && file.lastPathComponent.contains("BKLibrary") {
                return file.path
            }
        }
        
        throw AppleBooksError.libraryDatabaseNotFound
    }
}

// MARK: - Helper Classes
// Temporary class to hold Apple Books data before converting to SwiftData Highlight
private class AppleBooksHighlight {
    let id: String
    let content: String
    let note: String?
    let chapter: String?
    let createdDate: Date
    let assetId: String
    
    init(id: String, content: String, note: String?, chapter: String?, createdDate: Date, assetId: String) {
        self.id = id
        self.content = content
        self.note = note
        self.chapter = chapter
        self.createdDate = createdDate
        self.assetId = assetId
    }
}

// MARK: - Error Types
enum AppleBooksError: Error, LocalizedError {
    case annotationDirectoryNotFound
    case annotationDatabaseNotFound
    case libraryDirectoryNotFound
    case libraryDatabaseNotFound
    case databaseConnectionFailed
    case queryPreparationFailed
    
    var errorDescription: String? {
        switch self {
        case .annotationDirectoryNotFound:
            return "Apple Books annotation directory not found"
        case .annotationDatabaseNotFound:
            return "Apple Books annotation database not found"
        case .libraryDirectoryNotFound:
            return "Apple Books library directory not found"
        case .libraryDatabaseNotFound:
            return "Apple Books library database not found"
        case .databaseConnectionFailed:
            return "Failed to connect to Apple Books database"
        case .queryPreparationFailed:
            return "Failed to prepare database query"
        }
    }
}
