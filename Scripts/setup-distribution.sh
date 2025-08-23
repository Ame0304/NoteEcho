#!/bin/bash

# NoteEcho Distribution Setup Script
# This script helps configure Developer ID code signing for direct distribution

set -e

echo "🚀 NoteEcho Distribution Setup"
echo "==============================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if we're in the right directory
if [ ! -f "NoteEcho.xcodeproj/project.pbxproj" ]; then
    print_error "This script must be run from the NoteEcho project root directory"
    exit 1
fi

print_status "Checking for Developer ID certificates..."

# Check for Developer ID certificates
DEVELOPER_ID_CERTS=$(security find-identity -v -p codesigning | grep "Developer ID Application" || true)

if [ -z "$DEVELOPER_ID_CERTS" ]; then
    print_warning "No Developer ID Application certificates found!"
    echo "To distribute outside the App Store, you need a Developer ID certificate:"
    echo "1. Visit https://developer.apple.com/account/resources/certificates/list"
    echo "2. Create a new 'Developer ID Application' certificate"
    echo "3. Download and install it in your Keychain"
    echo ""
    echo "For now, we'll configure automatic signing which works for development."
else
    print_success "Found Developer ID certificates:"
    echo "$DEVELOPER_ID_CERTS"
    echo ""
fi

print_status "Creating build configuration..."

# Create build script
cat > Scripts/build-release.sh << 'EOF'
#!/bin/bash

# NoteEcho Release Build Script
set -e

echo "🔨 Building NoteEcho for Release Distribution"
echo "============================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Clean build folder
print_status "Cleaning previous builds..."
xcodebuild clean -project NoteEcho.xcodeproj -scheme NoteEcho

# Create archive
print_status "Creating release archive..."
xcodebuild archive \
    -project NoteEcho.xcodeproj \
    -scheme NoteEcho \
    -configuration Release \
    -archivePath "build/NoteEcho.xcarchive" \
    CODE_SIGN_IDENTITY="Developer ID Application" \
    DEVELOPMENT_TEAM="" \
    || {
        print_error "Archive failed. Trying with automatic signing..."
        xcodebuild archive \
            -project NoteEcho.xcodeproj \
            -scheme NoteEcho \
            -configuration Release \
            -archivePath "build/NoteEcho.xcarchive"
    }

print_success "Archive created successfully!"

# Export app
print_status "Exporting application..."
xcodebuild -exportArchive \
    -archivePath "build/NoteEcho.xcarchive" \
    -exportPath "build" \
    -exportOptionsPlist Scripts/ExportOptions.plist

if [ -f "build/NoteEcho.app" ]; then
    print_success "Build completed! App is ready at: build/NoteEcho.app"
    print_status "You can now test the app and create a DMG for distribution."
else
    print_error "Build failed - no app found in output directory"
    exit 1
fi
EOF

chmod +x Scripts/build-release.sh

# Create export options plist for Developer ID distribution
cat > Scripts/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>destination</key>
    <string>export</string>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>teamID</key>
    <string></string>
</dict>
</plist>
EOF

# Create DMG creation script
cat > Scripts/create-dmg.sh << 'EOF'
#!/bin/bash

# NoteEcho DMG Creation Script
set -e

echo "💿 Creating NoteEcho DMG for Distribution"
echo "========================================"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if app exists
if [ ! -d "build/NoteEcho.app" ]; then
    print_error "NoteEcho.app not found! Run build-release.sh first."
    exit 1
fi

print_status "Creating DMG..."

# Create temporary dmg directory
rm -rf build/dmg-temp
mkdir -p build/dmg-temp

# Copy app to dmg directory
cp -R build/NoteEcho.app build/dmg-temp/

# Create symbolic link to Applications folder
ln -s /Applications build/dmg-temp/Applications

# Create DMG
rm -f build/NoteEcho.dmg
hdiutil create -srcfolder build/dmg-temp -volname "NoteEcho" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDBZ build/NoteEcho.dmg

# Clean up
rm -rf build/dmg-temp

print_success "DMG created successfully: build/NoteEcho.dmg"
print_status "You can now distribute this DMG file to your friends!"
EOF

chmod +x Scripts/create-dmg.sh

# Create notarization script (for future use)
cat > Scripts/notarize.sh << 'EOF'
#!/bin/bash

# NoteEcho Notarization Script
# Note: Requires Apple Developer Program membership and app-specific password

set -e

echo "📋 NoteEcho Notarization Setup"
echo "============================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if DMG exists
if [ ! -f "build/NoteEcho.dmg" ]; then
    print_error "NoteEcho.dmg not found! Run create-dmg.sh first."
    exit 1
fi

print_warning "Notarization requires:"
echo "1. Valid Developer ID certificate"
echo "2. App-specific password for Apple ID"
echo "3. Apple Developer Program membership"
echo ""

read -p "Do you have these requirements? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Skipping notarization. You can still distribute the DMG, but users will see security warnings."
    exit 0
fi

# Get Apple ID and app password
read -p "Enter your Apple ID email: " APPLE_ID
read -s -p "Enter your app-specific password: " APP_PASSWORD
echo

print_status "Uploading for notarization..."

# Submit for notarization
xcrun notarytool submit build/NoteEcho.dmg --apple-id "$APPLE_ID" --password "$APP_PASSWORD" --team-id "YOUR_TEAM_ID" --wait

if [ $? -eq 0 ]; then
    print_status "Stapling notarization ticket..."
    xcrun stapler staple build/NoteEcho.dmg
    print_success "Notarization complete! DMG is ready for distribution."
else
    print_error "Notarization failed. Check the output above for details."
fi
EOF

chmod +x Scripts/notarize.sh

# Create build directory
mkdir -p build

print_success "Distribution setup complete!"
echo ""
echo "Next steps:"
echo "1. Run './Scripts/build-release.sh' to create a release build"
echo "2. Run './Scripts/create-dmg.sh' to create a DMG for distribution" 
echo "3. (Optional) Run './Scripts/notarize.sh' to notarize for enhanced security"
echo ""
print_warning "Note: For production distribution, you'll need to:"
echo "• Add your Apple Developer Team ID to the scripts"
echo "• Configure proper code signing certificates"
echo "• Set up notarization with your Apple ID credentials"