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

# Extract app from archive
print_status "Extracting application from archive..."
cp -R build/NoteEcho.xcarchive/Products/Applications/NoteEcho.app build/

if [ -d "build/NoteEcho.app" ]; then
    print_success "Build completed! App is ready at: build/NoteEcho.app"
    print_status "You can now test the app and create a DMG for distribution."
else
    print_error "Build failed - no app found in archive"
    exit 1
fi
