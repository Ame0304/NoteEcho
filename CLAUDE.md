# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

**NoteEcho** is a SwiftUI macOS application for managing and viewing book highlights. Users can explore their reading library through two distinct content categories: **Words** (short snippets) and **Highlights** (longer passages), with dedicated search, filtering, and sorting capabilities.

## Development Commands

### Building and Running
- **Build**: `⌘+B` in Xcode 
- **Run**: `⌘+R` in Xcode
- **Test**: `⌘+U` in Xcode (Swift Testing + XCTest)

## Key Architecture

### Data Models (SwiftData)
- **Book**: Title, author, assetId
- **Highlight**: Content, note, chapter, date, book relationship
- **NotificationSettings**: Daily notification preferences
- **ContentType**: Enum for Words vs Highlights categorization

### Main Components
- **ContentView**: Main interface with sidebar and content area
- **ContentSidebar**: Navigation with Words/Highlights sections and book filtering
- **WordCard/HighlightCard**: Content-specific display components
- **DailyEchoCard**: Featured daily highlight
- **SettingsView**: Notification preferences

### Data Flow
- Imports real Apple Books highlights from SQLite databases
- Automatic content categorization with language detection:
  - English: ≤4 words = Words
  - Chinese: ≤12 characters = Words
- SwiftData for persistence and queries
- UserNotifications for daily highlight reminders

## File Structure
- **NoteEcho/**: Main source
  - **Views/**: Core UI components
  - **Models/**: Data models and services
  - **Theme/**: Design system
- **Tests/**: Swift Testing + XCTest

## Development Notes
- Uses SF Pro Rounded typography
- Green theme (#10B981) with light/dark mode support
- Apple Books database access (sandboxing disabled for development)
- Manual save pattern for settings to avoid auto-save conflicts
