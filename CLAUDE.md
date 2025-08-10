# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**NoteEcho** is a SwiftUI macOS application for managing and viewing book highlights. Users can search, filter by book, and sort highlights from their reading library.

## Development Commands

### Building and Running
- **Build**: `⌘+B` in Xcode or `xcodebuild -project NoteEcho.xcodeproj -scheme NoteEcho build`
- **Run**: `⌘+R` in Xcode or build and run the .app file
- **Clean**: `⌘+Shift+K` in Xcode or `xcodebuild clean`

### Testing
- **Run Unit Tests**: `⌘+U` in Xcode or `xcodebuild test -project NoteEcho.xcodeproj -scheme NoteEcho -destination 'platform=macOS'`
- **Run UI Tests**: Select NoteEchoUITests scheme and run, or use xcodebuild with appropriate destination
- **Test Framework**: Uses both Swift Testing (for unit tests) and XCTest (for UI tests)

## Architecture

### Data Layer - SwiftData Models
- **Book**: Represents a book with title, author, and assetId
- **Highlight**: Represents a highlighted passage with content, optional note, chapter, and creation date
- **Relationship**: One-to-many (Book → Highlights) with cascade delete
- **Storage**: SwiftData with ModelContainer configured in NoteEchoApp.swift

### View Hierarchy
```
NoteEchoApp (App entry point with ModelContainer)
└── ContentView (Main interface)
    ├── Search bar with focus states
    ├── Filter controls (book selector + sort toggle)
    └── Highlights display
        ├── Empty state (when no highlights match filters)
        └── ScrollView with LazyVStack of HighlightCard components
```

### Key Components
- **ContentView**: Main view with search, filtering, sorting, and highlight display logic
- **HighlightCard**: Reusable component for displaying individual highlights with book metadata
- **MockDataService**: Populates sample data on first launch (5 books with multiple highlights each)

### Data Flow
- SwiftData `@Query` automatically fetches and updates data
- `filteredHighlights` computed property handles search + book filtering + date sorting
- State variables (`selectedBook`, `sortByNewest`, `searchText`) drive UI updates
- Color theming based on book title hash for visual variety

## Development Guidelines

### Code Style
- **Comments**: Write clear and concise comments when writing code (user is new to Swift/Xcode)
- **SwiftUI**: Follow declarative patterns with computed properties for derived state
- **State Management**: Use `@State` for local UI state, `@Query` for SwiftData
- **Animations**: Smooth transitions with spring animations and asymmetric transitions

### Technical Patterns Used
- **SwiftData Relationships**: Bidirectional with `@Relationship(inverse:)` 
- **Mock Data**: Service pattern for development data population
- **Search Implementation**: Multi-field search (content, notes, book titles) with case-insensitive matching
- **Dynamic Theming**: Color generation based on book title hash
- **Focus Management**: `@FocusState` for search field interactions

### Testing Approach
- **Unit Tests**: Swift Testing framework in NoteEchoTests/
- **UI Tests**: XCTest framework in NoteEchoUITests/
- **Current State**: Basic test structure exists, needs implementation

## File Structure
- **NoteEcho/**: Main app source code
- **NoteEchoTests/**: Unit tests using Swift Testing
- **NoteEchoUITests/**: UI tests using XCTest
- **Assets.xcassets/**: App icons and asset catalog