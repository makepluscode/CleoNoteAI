#!/bin/bash

# CleoAI Deploy Script
# Usage: ./deploy.sh [archive|export]

set -e

# Configuration
PROJECT_NAME="CleoAI"
SCHEME_NAME="CleoAI"
ACTION=${1:-archive}
PROJECT_FILE="${PROJECT_NAME}.xcodeproj/project.pbxproj"

# Auto-detect team ID from project
TEAM_ID=$(grep "DEVELOPMENT_TEAM" "$PROJECT_FILE" | head -1 | awk -F'= ' '{print $2}' | tr -d ';' | tr -d ' ')

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Deploying CleoAI...${NC}"

if [ "$ACTION" = "archive" ]; then
    echo -e "${YELLOW}📦 Creating archive...${NC}"
    
    # Create archive
    xcodebuild archive \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME_NAME}" \
        -configuration Release \
        -destination "generic/platform=iOS" \
        -archivePath "./build/CleoAI.xcarchive" \
        -derivedDataPath "./DerivedData"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Archive created successfully!${NC}"
        echo -e "${GREEN}📁 Archive location: ./build/CleoAI.xcarchive${NC}"
    else
        echo -e "${RED}❌ Archive failed!${NC}"
        exit 1
    fi
    
elif [ "$ACTION" = "export" ]; then
    echo -e "${YELLOW}📤 Exporting IPA...${NC}"
    
    # Create export options plist
    cat > "./build/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
EOF
    
    # Export IPA
    xcodebuild -exportArchive \
        -archivePath "./build/CleoAI.xcarchive" \
        -exportPath "./build" \
        -exportOptionsPlist "./build/ExportOptions.plist"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ IPA exported successfully!${NC}"
        echo -e "${GREEN}📱 IPA location: ./build/CleoAI.ipa${NC}"
    else
        echo -e "${RED}❌ Export failed!${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Invalid action. Use 'archive' or 'export'${NC}"
    exit 1
fi




