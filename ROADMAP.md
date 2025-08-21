# NoteEcho Production & Feature Roadmap

## Current Status
- ✅ Apple Books SQLite integration working
- ✅ SF Pro Rounded typography system implemented
- ✅ Real highlights loading (79 highlights from 12 books)
- ⚠️ Sandboxing temporarily disabled for development
- ❌ Not ready for distribution to other users

## Phase 1: Production Foundation (Priority: High)
**Goal: Make app distributable to other users**

### 1. Re-enable Sandboxing with User Permission
- Re-enable `com.apple.security.app-sandbox` in entitlements
- Implement NSOpenPanel for user to select Apple Books folder
- Add security-scoped bookmarks for persistent access
- Create user onboarding flow explaining permissions needed

### 2. Code Signing & Distribution Setup
- Configure Developer ID code signing
- Set up notarization for macOS Gatekeeper compatibility
- Create DMG installer with proper app packaging
- Test on clean macOS systems without development environment

### 3. Bug Fix: Books Without Highlights
- Filter books that have zero highlights in BookSidebar
- Update query or add computed property to exclude empty books
- Ensure Daily Echo works with filtered book list
- Test edge cases (all books filtered out)

## Phase 2: Core Features (Priority: High)
**Goal: Add essential user experience features**

### 4. Daily Echo Notifications
- Add UserNotifications framework integration
- Create settings UI for notification time selection
- Implement daily scheduled notifications with highlight content
- Handle notification permissions and user preferences
- Test notification reliability across system restarts

### 5. Auto Data Updates
- Implement file system monitoring for Apple Books database changes
- Add manual refresh option in UI (menu item or button)
- Background data fetching when app becomes active
- Handle data sync conflicts gracefully
- Show loading states during data refresh

## Phase 3: Advanced Features (Priority: Medium)
**Goal: Enhance user functionality and cross-platform experience**

### 6. Cross-Device Highlight Sync Investigation
- Research Apple Books iCloud sync behavior
- Test if iPad highlights appear in Mac databases automatically
- Investigate alternative database locations or sync methods
- Test with multiple devices (iPad, iPhone, Mac)
- Document findings and implement if feasible

### 7. Highlight Management Features
- Add delete highlight functionality with confirmation dialog
- Implement highlight editing (notes, tags, collections)
- Add highlight export options (markdown, plain text, PDF)
- Create highlight organization features (favorites, custom collections)
- Add search within highlight content and notes

## Phase 4: Polish & Advanced Features (Priority: Low)
**Goal: Professional app experience**

### 8. Enhanced User Experience
- Add app preferences/settings window
- Implement data backup/restore functionality
- Add highlight statistics and insights (reading patterns, most highlighted books)
- Create keyboard shortcuts for common actions
- Add dark mode refinements and accessibility features

### 9. Performance & Reliability
- Optimize database queries for large highlight collections (1000+ highlights)
- Add error recovery and data validation
- Implement crash reporting and analytics
- Add comprehensive unit test coverage
- Memory optimization for large datasets

## Technical Implementation Details

### Sandboxing Solution Architecture
```swift
// Use NSOpenPanel to let user select Apple Books container folder
// Store security-scoped bookmark data in UserDefaults
// Implement permission validation on app launch
class PermissionManager {
    func requestAppleBooksAccess() -> URL?
    func validateStoredPermissions() -> Bool
    func storeSecurityScopedBookmark(for url: URL)
}
```

### Notification Architecture
```swift
// UserNotifications framework for local notifications
// Settings stored in UserDefaults with time picker UI
// Generate notification content from daily highlight
class NotificationManager {
    func scheduleDaily(at time: Date)
    func generateHighlightNotification() -> UNNotificationContent
}
```

### Cross-Device Research Areas
- Test on iPad + Mac with same Apple ID
- Check if database files sync via iCloud Documents
- Investigate CloudKit integration possibilities
- Monitor database file modification times
- Test network-based sync alternatives

### Data Management Strategy
- Add write operations to AppleBooksDataService (for user modifications)
- Implement data validation and conflict resolution
- Consider hybrid approach: read Apple Books, write to separate user store
- Maintain data integrity between Apple Books and user modifications

## Success Metrics

### Phase 1 Success Criteria
- [ ] App runs on fresh Mac without development environment
- [ ] Users can access their Apple Books highlights within 30 seconds of first launch
- [ ] No security warnings during installation
- [ ] Books without highlights don't appear in sidebar
- [ ] App passes macOS security requirements for distribution

### Phase 2 Success Criteria
- [ ] Daily notifications work reliably across system restarts
- [ ] Data refreshes automatically when new highlights added in Apple Books
- [ ] Notification time can be customized by user
- [ ] App remains responsive during data operations

### Phase 3 Success Criteria
- [ ] iPad highlights appear in Mac app (if technically feasible)
- [ ] Users can manage their highlight collection effectively
- [ ] Export functionality works with large highlight collections
- [ ] Feature discovery is intuitive for new users

## Timeline Estimates
- **Phase 1 (Production Ready)**: 2-3 weeks
- **Phase 2 (Core Features)**: 2-3 weeks  
- **Phase 3 (Advanced Features)**: 3-4 weeks
- **Phase 4 (Polish)**: 2-3 weeks

**Total: 9-13 weeks for complete roadmap**

## Risk Assessment

### High Risk Items
- Apple Books database format changes in future macOS versions
- Sandboxing limitations preventing reliable database access
- iCloud sync behavior not accessible to third-party apps

### Medium Risk Items
- Code signing and notarization complexity
- UserNotifications permission handling
- Performance with very large highlight collections

### Low Risk Items
- UI/UX improvements and polish
- Additional export formats
- Keyboard shortcuts and accessibility