# NoteEcho Distribution Guide

This guide walks you through building and distributing NoteEcho for sharing with friends outside the App Store.

## Quick Start

1. **Set up distribution tools:**
   ```bash
   ./Scripts/setup-distribution.sh
   ```

2. **Build release version:**
   ```bash
   ./Scripts/build-release.sh
   ```

3. **Create DMG for distribution:**
   ```bash
   ./Scripts/create-dmg.sh
   ```

4. **Share the DMG:**
   - Upload `build/NoteEcho.dmg` to file sharing service
   - Send to friends via email/messaging
   - Post on GitHub Releases

## Distribution Scripts

### `setup-distribution.sh`
- Checks for Developer ID certificates
- Creates all necessary build scripts
- Sets up directory structure

### `build-release.sh`
- Creates a Release build archive
- Handles code signing automatically
- Exports the final `.app` file

### `create-dmg.sh`
- Packages the app into a distributable DMG
- Includes Applications folder shortcut
- Creates compressed DMG for sharing

### `notarize.sh` (Optional)
- Notarizes DMG with Apple for enhanced security
- Requires Apple Developer Program membership
- Reduces security warnings for users

## Code Signing Configuration

### For Development (Current Setup)
- Uses automatic code signing
- Works for local testing and sharing with friends
- Users may see security warnings on first launch

### For Production Distribution (Future)
1. **Get Developer ID Certificate:**
   - Visit [Apple Developer Portal](https://developer.apple.com/account/resources/certificates/list)
   - Create "Developer ID Application" certificate
   - Download and install in Keychain

2. **Update Export Options:**
   - Add your Team ID to `Scripts/ExportOptions.plist`
   - Update notarization script with your Apple ID

3. **Configure Automatic Signing:**
   - Set Development Team in Xcode project settings
   - Enable "Developer ID" code signing

## File Structure

```
build/
├── NoteEcho.xcarchive     # Xcode archive
├── NoteEcho.app           # Standalone app
└── NoteEcho.dmg           # Distribution package
```

## Security & Trust

### Without Developer ID Certificate
- App runs fine on your machine
- Friends will see "unidentified developer" warning
- Users must right-click → Open to bypass warning

### With Developer ID Certificate
- App signed with Apple-verified identity
- Reduced security warnings
- Professional distribution experience

### With Notarization
- Apple validates app for malware
- Minimal security warnings
- Best user experience

## Troubleshooting

### Build Fails
1. Clean build folder: `rm -rf build/`
2. Clean Xcode caches: `xcodebuild clean`
3. Check certificate expiration
4. Verify Xcode is up to date

### Code Signing Issues
1. Check available certificates:
   ```bash
   security find-identity -v -p codesigning
   ```
2. Reset signing to automatic in project settings
3. Clear derived data in Xcode

### DMG Creation Fails
1. Ensure app was built successfully
2. Check available disk space
3. Verify hdiutil is available

### Users Can't Open App
1. **First time:** Right-click app → Open → Open
2. **Still blocked:** System Preferences → Security → Allow
3. **Persistent issues:** App needs notarization

## Best Practices

### Before Distribution
- [ ] Test app on clean Mac (different user account)
- [ ] Verify all features work without development environment
- [ ] Check app launches and loads Apple Books data
- [ ] Test notifications and settings

### For Production
- [ ] Get Apple Developer ID certificate
- [ ] Set up notarization workflow
- [ ] Create proper version numbering
- [ ] Add update mechanism (Sparkle framework)
- [ ] Create user documentation

### Distribution Channels
- **GitHub Releases**: Version-controlled distribution
- **Direct Download**: Host DMG on personal website
- **File Sharing**: Dropbox, Google Drive, etc.
- **Email**: For small groups (< 25MB DMG)

## Version Management

### Current Approach
- Manual version updates in Xcode
- Build scripts use current project settings

### Recommended for Production
```bash
# Update version before building
xcrun agvtool new-marketing-version "1.0.0"
xcrun agvtool new-version -all "1"
```

## Future Enhancements

### Automatic Updates
- Integrate Sparkle framework
- Host appcast XML file
- Enable in-app update checks

### Analytics (Optional)
- Track usage metrics
- Monitor crash reports
- Understand user behavior

### Enhanced Security
- Code signing with hardened runtime
- Notarization with additional entitlements
- Certificate pinning for updates

## Support & Documentation

### For Users
- Create installation guide
- Document Apple Books integration
- Provide troubleshooting steps

### For Developers
- Maintain CLAUDE.md for development
- Update ROADMAP.md with completed features
- Document any new dependencies

---

## Commands Reference

```bash
# Full distribution workflow
./Scripts/setup-distribution.sh
./Scripts/build-release.sh
./Scripts/create-dmg.sh

# Optional notarization
./Scripts/notarize.sh

# Clean everything
rm -rf build/
xcodebuild clean

# Check certificates
security find-identity -v -p codesigning

# Test app locally
open build/NoteEcho.app
```

Remember: The goal is to make NoteEcho easily shareable with friends while maintaining the full Apple Books integration that makes it special!