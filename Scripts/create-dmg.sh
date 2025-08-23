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
