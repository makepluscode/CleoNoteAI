#!/bin/bash

# CleoAI Build Script
# Usage: ./build.sh [debug|release] [simulator|device] [install]

set -e

# Configuration
PROJECT_NAME="CleoAI"
SCHEME_NAME="CleoAI"
CONFIGURATION=${1:-Debug}
DESTINATION=${2:-simulator}
INSTALL_TO_DEVICE=${3:-false}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Building CleoAI...${NC}"
echo -e "${YELLOW}Configuration: ${CONFIGURATION}${NC}"
echo -e "${YELLOW}Destination: ${DESTINATION}${NC}"
echo -e "${YELLOW}Install to device: ${INSTALL_TO_DEVICE}${NC}"

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
xcodebuild clean -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME_NAME}" -configuration "${CONFIGURATION}"

# Build the project
echo -e "${YELLOW}🔨 Building project...${NC}"

if [ "$DESTINATION" = "simulator" ]; then
    xcodebuild build \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME_NAME}" \
        -configuration "${CONFIGURATION}" \
        -destination "platform=iOS Simulator,name=iPhone 16" \
        -derivedDataPath "./DerivedData"
else
    xcodebuild build \
        -project "${PROJECT_NAME}.xcodeproj" \
        -scheme "${SCHEME_NAME}" \
        -configuration "${CONFIGURATION}" \
        -destination "generic/platform=iOS" \
        -derivedDataPath "./DerivedData" \
        -allowProvisioningUpdates
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Build successful!${NC}"
    
    # Find the built app
    APP_PATH=$(find ./DerivedData -name "*.app" -type d | head -1)
    if [ -n "$APP_PATH" ]; then
        echo -e "${GREEN}📱 App built at: ${APP_PATH}${NC}"
        
        # Get app size
        APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
        echo -e "${GREEN}📊 App size: ${APP_SIZE}${NC}"
        
        # Install to device if requested
        if [ "$INSTALL_TO_DEVICE" = "true" ] && [ "$DESTINATION" = "device" ]; then
            echo -e "${YELLOW}📲 Installing to connected device...${NC}"
            
            # Get connected device ID
            DEVICE_ID=$(xcrun devicectl list devices | grep "connected" | head -1 | awk '{print $3}')
            
            if [ -n "$DEVICE_ID" ]; then
                echo -e "${YELLOW}📱 Installing to device: ${DEVICE_ID}${NC}"
                
                # Install using devicectl
                xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH"
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}✅ App installed successfully!${NC}"
                else
                    echo -e "${RED}❌ Installation failed!${NC}"
                    exit 1
                fi
            else
                echo -e "${RED}❌ No connected device found!${NC}"
                exit 1
            fi
        fi
    fi
else
    echo -e "${RED}❌ Build failed!${NC}"
    exit 1
fi
