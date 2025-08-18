# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Philosophy

### Core Beliefs

- **Incremental progress over big bangs** - Small changes that compile and pass tests
- **Learning from existing code** - Study and plan before implementing
- **Pragmatic over dogmatic** - Adapt to project reality
- **Clear intent over clever code** - Be boring and obvious

## Project Integration

### Learning the Codebase

- Find 3 similar features/components
- Identify common patterns and conventions
- Use same libraries/utilities when possible
- Follow existing test patterns

### Tooling

- Use project's existing build system
- Use project's test framework
- Use project's formatter/linter settings
- Don't introduce new tools without strong justification

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
└── ContentView (Main interface with HSplitView)
    ├── BookSidebar (Fixed 200px width)
    │   ├── "Books" header
    │   ├── "All Books" option
    │   └── Scrollable book list with selection states
    └── MainContentArea (Flexible width)
        ├── Daily Echo section (DailyEchoCard with random daily highlight)
        ├── Search and sort controls row: SearchBar + SortButton
        └── Highlights display
            ├── Empty state (when no highlights match filters)
            └── ScrollView with LazyVStack of HighlightCard components
```

### Key Components
- **ContentView**: Main coordinator with HSplitView layout and state management
- **BookSidebar**: Dedicated sidebar for book selection with hover and selection states
- **MainContentArea**: Contains Daily Echo section, search/sort controls, and highlights display area
- **DailyEchoCard**: Featured component displaying a random daily highlight with enhanced styling, unified card design, and regenerate button with smooth rotation animations
- **HighlightCard**: Reusable component for displaying individual highlights with book metadata and interactive animations
- **MockDataService**: Populates sample data on first launch (5 books with multiple highlights each)

### UI Design System
- **Theme Colors**: Unified color palette with light/dark mode support
  - Primary theme: Green (#10B981 light, softer tint for dark)
  - Card backgrounds: White/dark mode appropriate (#FFFFFF/#1C1C1E)
  - Secondary text: Adaptive gray tones for contrast
- **Control Styling**: Consistent 36px height, 8px border radius, 12px padding
- **Shadows & Borders**: Subtle shadows in light mode, gradient borders in dark mode
- **Interactive States**: Hover effects, focus states, and smooth animations

### Data Flow
- SwiftData `@Query` automatically fetches and updates data in ContentView
- `filteredHighlights` computed property handles search + book filtering + date sorting
- `allHighlights` passed to MainContentArea for Daily Echo random selection
- State variables (`selectedBook`, `sortByNewest`, `searchText`) managed in ContentView and passed as bindings
- BookSidebar receives book selection state and updates it via binding
- MainContentArea receives both filtered highlights and all highlights for daily selection
- Daily Echo uses date-based seeding to show consistent random highlight throughout the day with manual regenerate option
- Unified theming system ensures consistent visual appearance across components

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
- **Two-Column Layout**: HSplitView with fixed sidebar (200px) and flexible main content area
- **Component Architecture**: Modular components with clear separation of concerns
- **Daily Random Selection**: Date-based seeding for consistent daily highlight selection using Array extension with regenerate override capability
- **Unified Card Design**: Content extraction pattern to avoid nested styling while maintaining functionality
- **State Management**: Centralized state in ContentView with binding propagation to child components
- **Unified Design System**: Consistent theming across all UI components with shared color variables
- **Focus Management**: `@FocusState` for search field interactions
- **Responsive Layout**: Adaptive UI that works with flexible and fixed-width controls
- **Animation Patterns**: Smooth easing curves for rotations, asymmetric transitions, and polished interactive feedback

### UI Implementation Notes
- **Sidebar Design**: Fixed-width (200px) with scrollable content, hover states, and selection indicators
- **Daily Echo Layout**: Featured section at top with unified card design, enhanced styling, and theme color consistency
- **Main Content Layout**: Daily Echo above search/sort controls for prominent positioning and user attention
- **Component Composition**: Clean separation between BookSidebar and MainContentArea for maintainability
- **Unified Styling**: Content extraction pattern prevents nested card effects while preserving component behavior
- **Frame Management**: Separate `.frame()` calls for width/height to ensure proper SwiftUI rendering
- **Background Layers**: Backgrounds applied at component level, not content level, for full-area coverage
- **Color Accessibility**: All colors tested for contrast in both light and dark modes
- **Interactive States**: Consistent hover, selection, and focus feedback across all interactive elements

### Testing Approach
- **Unit Tests**: Swift Testing framework in NoteEchoTests/
- **UI Tests**: XCTest framework in NoteEchoUITests/
- **Current State**: Basic test structure exists, needs implementation

## File Structure
- **NoteEcho/**: Main app source code
  - **Views/**: Core view components (ContentView, HighlightCard, DailyEchoCard)
  - **Components/**: Reusable UI components (BookSidebar, MainContentArea, SearchBar)
  - **Extensions/**: Swift extensions (Array+DailySelection for daily random logic)
  - **Models/**: SwiftData models (Book, Highlight, MockDataService)
  - **Theme/**: Design system (AppTheme, Colors, BlurredGradientBackground)
- **NoteEchoTests/**: Unit tests using Swift Testing
- **NoteEchoUITests/**: UI tests using XCTest
- **Assets.xcassets/**: App icons and asset catalog
