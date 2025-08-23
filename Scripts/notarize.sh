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
