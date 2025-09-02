# NoteEcho

A macOS app for exploring and organizing your book highlights from Apple Books.

## Features

### Smart Content Categorization
- **Words**: Short snippets (≤4 words in English, ≤12 characters in Chinese)
- **Highlights**: Longer passages that exceed the word/character thresholds
- Automatic language detection and intelligent categorization

### Organized Navigation
- Dual-section sidebar for Words and Highlights
- Book-based filtering for highlights
- Search across content, notes, and book titles
- Sort by newest or oldest

### Daily Echo
- Featured daily highlight from your entire collection
- Consistent daily selection with manual regenerate option
- Prominent display to rediscover forgotten insights

### Notifications
- Optional daily highlight reminders
- Customizable notification time
- Dynamic content using your actual highlights

## Requirements

- macOS (SwiftUI app)
- Apple Books with existing highlights
- Xcode for development

## Installation

### For Development
1. Clone this repository
2. Open `NoteEcho.xcodeproj` in Xcode
3. Build and run with `⌘+R`

### For Distribution
The app includes distribution scripts:
- `./Scripts/build-release.sh` - Create optimized build
- `./Scripts/create-dmg.sh` - Package into DMG
- See full distribution guide in the project

## How It Works

NoteEcho reads your existing highlights directly from Apple Books' SQLite databases. Your highlights are automatically categorized into Words and Highlights based on length, with smart language detection for English and Chinese content.

No data leaves your device - everything is processed and stored locally using SwiftData.

## Development

Built with:
- **SwiftUI** for the interface
- **SwiftData** for local storage
- **SQLite** integration for Apple Books data
- **UserNotifications** for daily reminders

### Key Components
- Two-column layout with resizable sidebar
- Content-aware card designs (WordCard vs HighlightCard)
- Unified theming system with light/dark mode support
- Language-aware text processing

### Testing
- Unit tests: Swift Testing framework
- UI tests: XCTest framework
- Run tests with `⌘+U` in Xcode

## Design

- **Typography**: SF Pro Rounded for a friendly, modern feel
- **Theme**: Green accent (#10B981) with adaptive colors
- **Layout**: Clean two-column design with hover states and smooth animations

## Privacy

NoteEcho accesses your Apple Books highlights locally. No data is transmitted or stored externally. The app operates entirely offline with your existing highlight data.

## License

[Add your chosen license here]

## Contributing

[Add contribution guidelines if desired]