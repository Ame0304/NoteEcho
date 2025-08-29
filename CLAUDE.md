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

**NoteEcho** is a SwiftUI macOS application for managing and viewing book highlights. Users can explore their reading library through two distinct content categories: **Words** (short snippets under 4 words and 6 characters) and **Highlights** (longer passages), with dedicated search, filtering, and sorting capabilities for each type.

## Development Commands

### Building and Running
- **Build**: `⌘+B` in Xcode or `xcodebuild -project NoteEcho.xcodeproj -scheme NoteEcho build`
- **Run**: `⌘+R` in Xcode or build and run the .app file
- **Clean**: `⌘+Shift+K` in Xcode or `xcodebuild clean`

### Testing
- **Run Unit Tests**: `⌘+U` in Xcode or `xcodebuild test -project NoteEcho.xcodeproj -scheme NoteEcho -destination 'platform=macOS'`
- **Run UI Tests**: Select NoteEchoUITests scheme and run, or use xcodebuild with appropriate destination
- **Test Framework**: Uses both Swift Testing (for unit tests) and XCTest (for UI tests)

### Distribution (Production Ready)
- **Setup Distribution**: `./Scripts/setup-distribution.sh` (creates all necessary scripts)
- **Build Release**: `./Scripts/build-release.sh` (creates optimized app for distribution)
- **Create DMG**: `./Scripts/create-dmg.sh` (packages app into distributable DMG)
- **Notarize** (Optional): `./Scripts/notarize.sh` (Apple notarization for enhanced security)
- **Full Guide**: See [DISTRIBUTION.md](DISTRIBUTION.md) for complete instructions

## Architecture

### Data Layer - SwiftData Models
- **Book**: Represents a book with title, author, and assetId
- **Highlight**: Represents a highlighted passage with content, optional note, chapter, and creation date
- **NotificationSettings**: Stores user preferences for daily highlight notifications (time, enabled state)
- **ContentType**: Enum distinguishing between Words (.words) and Highlights (.highlights) content categories
- **Relationship**: One-to-many (Book → Highlights) with cascade delete
- **Storage**: SwiftData with ModelContainer configured in NoteEchoApp.swift
- **Data Source**: Real Apple Books highlights imported from SQLite databases
- **Categorization**: HighlightFilterService automatically categorizes content based on length (words <4 words AND <6 chars, highlights for everything else)

### View Hierarchy
```
NoteEchoApp (App entry point with ModelContainer + NotificationManager)
├── ContentView (Main interface with HSplitView and dual content type support)
│   ├── ContentSidebar (Fixed 200px width - dual section navigation)
│   │   ├── Words Section
│   │   │   └── "All Words" option with textformat icon
│   │   └── Highlights Section  
│   │       ├── "All Highlights" option with highlighter icon
│   │       └── Book-based filtering (when Highlights selected)
│   └── MainContentArea (Flexible width with content-aware display)
│       ├── Daily Echo section (DailyEchoCard with random highlight from all content)
│       ├── Search and sort controls row: SearchBar + SortButton (works across both content types)
│       └── Content display (adapts based on selectedContentType)
│           ├── WordCard components (compact design for short content)
│           ├── HighlightCard components (full design for longer content)
│           └── Content-aware empty states
└── SettingsView (Separate Settings window)
    ├── Notification toggle and time picker
    ├── Permission status display
    └── Next notification information
```

### Key Components
- **ContentView**: Main coordinator with HSplitView layout, dual content type state management, and centralized filtering
- **ContentSidebar**: Dual-section navigation sidebar with Words/Highlights categorization and dynamic book filtering
- **MainContentArea**: Content-aware display area with adaptive card rendering based on selected content type
- **WordCard**: Compact component optimized for short content with horizontal layout and minimal padding
- **HighlightCard**: Full-featured component for longer content with vertical layout and comprehensive metadata display
- **DailyEchoCard**: Featured component displaying a random daily highlight from all content with enhanced styling and regenerate functionality
- **SettingsView**: Dedicated settings window with streamlined notification preferences and manual save system
- **HighlightFilterService**: Core filtering service with content categorization logic and type-aware filtering methods
- **NotificationManager**: Handles daily highlight notifications using UserNotifications framework with customizable scheduling
- **AppleBooksDataService**: Imports real highlights from Apple Books SQLite databases with fallback error handling

### UI Design System
- **Theme Colors**: Unified color palette with light/dark mode support
  - Primary theme: Green (#10B981 light, softer tint for dark)
  - Card backgrounds: White/dark mode appropriate (#FFFFFF/#1C1C1E)
  - Secondary text: Adaptive gray tones for contrast
- **Control Styling**: Consistent 36px height, 8px border radius, 12px padding
- **Shadows & Borders**: Subtle shadows in light mode, gradient borders in dark mode
- **Interactive States**: Hover effects, focus states, and smooth animations

### Data Flow
- **Data Import**: AppleBooksDataService loads real highlights from Apple Books SQLite databases on app launch
- **SwiftData Integration**: `@Query` automatically fetches and updates imported data in ContentView
- **Content Categorization**: HighlightFilterService automatically categorizes all content into Words (<4 words AND <6 chars) and Highlights (everything else) using `categorizeHighlights()`
- **Type-Aware Filtering**: `filteredContent()` method applies book, search, and sort filters based on selected content type
- **Daily Echo**: `allHighlights` passed to MainContentArea for Daily Echo random selection across all content types
- **Notifications**: NotificationManager schedules daily highlights using user preferences from NotificationSettings
- **Settings Management**: NotificationSettings persisted in SwiftData with automatic UI updates
- **State Management**: Variables (`selectedContentType`, `selectedBook`, `sortByNewest`, `searchText`) managed in ContentView and passed as bindings
- **Component Communication**: ContentSidebar receives both content type and book selection state, updates via bindings
- **Adaptive Display**: MainContentArea renders WordCard or HighlightCard components based on selectedContentType
- **Random Selection**: Daily Echo uses date-based seeding to show consistent random highlight with manual regenerate
- **Visual Consistency**: Unified theming system ensures consistent appearance across both content types and card designs

## Development Guidelines

### Code Style
- **Comments**: Write clear and concise comments when writing code (user is new to Swift/Xcode)
- **SwiftUI**: Follow declarative patterns with computed properties for derived state
- **State Management**: Use `@State` for local UI state, `@Query` for SwiftData
- **Animations**: Smooth transitions with spring animations and asymmetric transitions

### Technical Patterns Used
- **SwiftData Relationships**: Bidirectional with `@Relationship(inverse:)` 
- **SQLite Integration**: Direct access to Apple Books databases with SQLite3 framework
- **Data Service Pattern**: AppleBooksDataService handles database access, data transformation, and error handling
- **Notification System**: UserNotifications framework with customizable daily scheduling and permission handling
- **Settings Persistence**: NotificationSettings SwiftData model with automatic UI synchronization
- **Window Management**: Multiple SwiftUI windows (main app + settings) with proper environment object sharing
- **Search Implementation**: Multi-field search (content, notes, book titles) with case-insensitive matching
- **Content Filtering**: Minimum word count filtering excludes highlights with fewer than 3 words or 6 characters (supports both Western and Chinese text)
- **Shared UI Components**: SharedControlStyles provides consistent styling across all controls with theme support
- **Two-Column Layout**: HSplitView with fixed sidebar (200px) and flexible main content area
- **Component Architecture**: Modular components with clear separation of concerns
- **Daily Random Selection**: Date-based seeding for consistent daily highlight selection using Array extension with regenerate override capability
- **Unified Card Design**: Content extraction pattern to avoid nested styling while maintaining functionality
- **State Management**: Centralized state in ContentView with binding propagation to child components
- **Typography System**: SF Pro Rounded with centralized AppTypography for consistent, friendly font styling
- **Focus Management**: `@FocusState` for search field interactions
- **Responsive Layout**: Adaptive UI that works with flexible and fixed-width controls
- **Animation Patterns**: Smooth easing curves for rotations, asymmetric transitions, hover border effects, and polished interactive feedback

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
- **Hover Effects**: HighlightCard displays green theme color border on hover with smooth .easeInOut animations, maintaining visual consistency with DailyEchoCard styling
- **Settings UI Pattern**: Manual save approach with smart change detection eliminates auto-save conflicts and provides clear user control over when to commit notification time changes

### Testing Approach
- **Unit Tests**: Swift Testing framework in NoteEchoTests/
- **UI Tests**: XCTest framework in NoteEchoUITests/
- **Current State**: Basic test structure exists, needs implementation

## File Structure
- **NoteEcho/**: Main app source code
  - **Views/**: Core view components (ContentView, HighlightCard, WordCard, DailyEchoCard, SettingsView)
  - **Components/**: Reusable UI components (ContentSidebar, MainContentArea, SearchBar)
  - **Extensions/**: Swift extensions (Array+DailySelection for daily random logic)
  - **Models/**: SwiftData models (Book, Highlight, NotificationSettings, ContentType), filtering services (HighlightFilterService), NotificationManager, and AppleBooksDataService
  - **Theme/**: Design system (AppTheme, AppTypography, Colors, BlurredGradientBackground)
- **NoteEchoTests/**: Unit tests using Swift Testing
- **NoteEchoUITests/**: UI tests using XCTest
- **Assets.xcassets/**: App icons and asset catalog with custom icon in multiple resolutions

## Development Notes

### Apple Books Integration
- **Database Access**: Reads from `~/Library/Containers/com.apple.iBooksX/Data/Documents/`
- **Required Tables**: ZAEANNOTATION (highlights) and ZBKLIBRARYASSET (books)
- **Sandboxing**: Currently disabled for development; plan to re-enable with NSOpenPanel for user permission
- **Data Mapping**: Apple Books fields mapped to NoteEcho models with proper date conversion
- **Error Handling**: Graceful fallback when Apple Books database unavailable

### Notification System
- **Framework**: UserNotifications for daily highlight reminders
- **Scheduling**: Manual save time picker with smart change detection to prevent auto-save conflicts
- **Content**: Dynamic notification content using daily random highlight selection
- **Permissions**: Streamlined permission handling integrated into main notification toggle
- **Settings**: Dedicated Settings window accessible via menu bar (⌘,) with user-controlled save workflow

### Typography System
- **Font**: SF Pro Rounded for friendly, modern appearance
- **Centralized**: AppTypography.swift provides semantic font styles
- **Consistent**: All components use unified typography system
- **Accessible**: Proper contrast and sizing across light/dark modes

### Words & Highlights Categorization
- **Automatic Categorization**: All content automatically split into Words (short snippets) and Highlights (longer passages)
- **Words Criteria**: Content with fewer than 4 words AND fewer than 6 characters
- **Highlights Criteria**: Content with 4+ words OR 6+ characters (everything not classified as Words)
- **Dual Navigation**: ContentSidebar provides separate sections for each content type
- **Adaptive Cards**: WordCard (compact horizontal layout) vs HighlightCard (full vertical layout)
- **Unified Search**: Search and sort functionality works across both content types
- **Book Filtering**: Available for Highlights section, Words section shows all short content
- **Content Preservation**: No content is filtered out - everything is categorized and accessible
- **Performance**: Efficient categorization using HighlightFilterService with database-level operations

### App Icon Configuration
- **Asset Catalog**: Uses standard Xcode AppIcon.appiconset with individual PNG files for all required macOS sizes
- **Icon Sizes**: 16x16, 32x32, 128x128, 256x256, 512x512 at both 1x and 2x resolutions (10 total files)
- **Format**: PNG files extracted from .icns source using `iconutil -c iconset` command
- **macOS Integration**: Proper Contents.json configuration ensures rounded corners and system integration
- **Source**: Original app-icon-source.png available in project root for future updates
