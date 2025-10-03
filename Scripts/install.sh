#!/bin/bash

# CleoAI Install Script
# Usage: ./install.sh [debug|release]

set -e

# Configuration
PROJECT_NAME="CleoAI"
SCHEME_NAME="CleoAI"
CONFIGURATION=${1:-Debug}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}📲 Installing CleoAI to connected iPhone...${NC}"
echo -e "${YELLOW}Configuration: ${CONFIGURATION}${NC}"

# Check if device is connected
echo -e "${YELLOW}🔍 Checking for connected devices...${NC}"
DEVICE_INFO=$(xcrun devicectl list devices | grep "connected" | head -1)

if [ -z "$DEVICE_INFO" ]; then
    echo -e "${RED}❌ No connected device found!${NC}"
    echo -e "${YELLOW}Please connect your iPhone via USB and trust this computer.${NC}"
    exit 1
fi

DEVICE_ID=$(echo "$DEVICE_INFO" | awk '{print $3}')
DEVICE_NAME=$(echo "$DEVICE_INFO" | awk '{print $1}')

echo -e "${GREEN}📱 Found device: ${DEVICE_NAME} (${DEVICE_ID})${NC}"

# Build and install
echo -e "${YELLOW}🔨 Building and installing...${NC}"
./Scripts/build.sh "$CONFIGURATION" device true

if [ $? -eq 0 ]; then
    echo -e "${GREEN}🎉 CleoAI successfully installed on ${DEVICE_NAME}!${NC}"
    echo -e "${YELLOW}💡 You can now find CleoAI on your iPhone's home screen.${NC}"
else
    echo -e "${RED}❌ Installation failed!${NC}"
    exit 1
fi



