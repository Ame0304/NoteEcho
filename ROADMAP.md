# NoteEcho Production & Feature Roadmap

## Current Status
- ✅ Apple Books SQLite integration working
- ✅ SF Pro Rounded typography system implemented
- ✅ Real highlights loading (79 highlights from 12 books)
- ⚠️ Sandboxing temporarily disabled for development
- ❌ Not ready for distribution to other users

## Phase 1: Production Foundation (Priority: High)
**Goal: Make app distributable to other users**

### 1. Finalize Apple Books Access Solution
- Keep current entitlement approach with `com.apple.security.temporary-exception.files.home-relative-path.read-only`
- Document that this prevents App Store distribution (acceptable trade-off)
- Create user onboarding flow explaining why the app needs special permissions
- Add error handling for cases where Apple Books data is unavailable

### 2. Direct Distribution Setup (Outside App Store)
- Configure Developer ID code signing for direct distribution
- Set up notarization for macOS Gatekeeper compatibility
- Create DMG installer with proper app packaging
- Set up distribution website or GitHub releases for downloads
- Test installation and security warnings on clean macOS systems

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

## Distribution Strategy

### Why Direct Distribution (Outside App Store)
**Trade-offs Accepted:**
- ✅ **Functionality**: Full access to Apple Books highlights via temporary exception entitlement
- ✅ **User Experience**: No complex permission flows or file selection
- ❌ **App Store Discovery**: No App Store searchability or automatic updates
- ❌ **User Trust**: Some users prefer App Store-vetted apps

**Distribution Approach:**
- GitHub Releases for versioned downloads
- Direct website downloads with clear installation instructions
- Developer ID code signing to minimize security warnings
- Notarization for Gatekeeper compatibility
- Clear documentation about why special permissions are needed

**Update Strategy:**
- Manual update notifications within app
- Direct download links to latest version
- Consider Sparkle framework for future auto-updates

### Target Audience
- Power users comfortable with direct app downloads
- Apple Books heavy users who want better highlight management
- Users willing to trade App Store convenience for specialized functionality

## Technical Implementation Details

### Apple Books Access Architecture
```swift
// Direct file access using temporary exception entitlement
// No user permission dialogs needed - works automatically
// Graceful fallback when Apple Books data unavailable
class AppleBooksDataService {
    func loadHighlights() -> [Highlight]
    func validateAppleBooksAccess() -> Bool
    func handleMissingDataGracefully()
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

## Risk Assessment & Trade-offs

### Accepted Trade-offs
- **No App Store Distribution**: Prevents App Store discovery but enables full Apple Books access
- **Manual Updates**: Users must download updates manually (can be improved with auto-updater later)
- **Reduced Initial Trust**: Some users prefer App Store-vetted apps

### High Risk Items
- Apple Books database format changes in future macOS versions
- macOS security changes affecting temporary exception entitlements
- iCloud sync behavior not accessible to third-party apps

### Medium Risk Items
- Code signing and notarization complexity for direct distribution
- UserNotifications permission handling
- Performance with very large highlight collections
- User adoption without App Store marketing

### Low Risk Items
- UI/UX improvements and polish
- Additional export formats
- Keyboard shortcuts and accessibility