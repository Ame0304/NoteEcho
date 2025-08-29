import Foundation

// MARK: - Content Type Enumeration
enum ContentType: CaseIterable, Identifiable {
    case words
    case highlights
    
    var id: Self { self }
    
    var displayName: String {
        switch self {
        case .words:
            return "Words"
        case .highlights:
            return "Highlights"
        }
    }
    
    var iconName: String {
        switch self {
        case .words:
            return "textformat"
        case .highlights:
            return "highlighter"
        }
    }
}