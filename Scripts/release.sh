#!/bin/bash

# CleoAI Release Script (SideStore OTA)
# Usage: ./Scripts/release.sh [major|minor|patch]
# 
# Prerequisites:
#   - gh CLI installed and authenticated (gh auth login)
#   - Xcode with iOS development certificates
#   - iPhone provisioning profile (development team: 9YQZSH2X84)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_FILE="CleoAI.xcodeproj/project.pbxproj"
SOURCE_JSON="altstore-source.json"

echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}  CleoAI SideStore OTA Release${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"

# ── 1. Read current version ──
CURRENT_VERSION=$(grep "MARKETING_VERSION" "$PROJECT_FILE" | head -1 | awk -F'= ' '{print $2}' | tr -d ';' | tr -d ' ')
BUILD_NUMBER=$(grep "CURRENT_PROJECT_VERSION" "$PROJECT_FILE" | head -1 | awk -F'= ' '{print $2}' | tr -d ';' | tr -d ' ')

echo -e "${YELLOW}Current version: ${CURRENT_VERSION} (build ${BUILD_NUMBER})${NC}"

# ── 2. Bump version ──
BUMP_TYPE=${1:-patch}

if [ "$BUMP_TYPE" = "major" ]; then
    NEW_VERSION=$(echo "$CURRENT_VERSION" | awk -F. '{print $1+1".0.0"}')
elif [ "$BUMP_TYPE" = "minor" ]; then
    if [[ "$CURRENT_VERSION" == *.*.* ]]; then
        NEW_VERSION=$(echo "$CURRENT_VERSION" | awk -F. '{print $1"."$2+1".0"}')
    else
        NEW_VERSION=$(echo "$CURRENT_VERSION" | awk -F. '{print $1"."$2+1".0"}')
    fi
else # patch
    if [[ "$CURRENT_VERSION" == *.*.* ]]; then
        NEW_VERSION=$(echo "$CURRENT_VERSION" | awk -F. '{print $1"."$2"."$3+1}')
    elif [[ "$CURRENT_VERSION" == *.* ]]; then
        NEW_VERSION=$(echo "$CURRENT_VERSION" | awk -F. '{print $1"."$2+1".0"}')
    else
        NEW_VERSION="${CURRENT_VERSION}.0.1"
    fi
fi

NEW_BUILD=$((BUILD_NUMBER + 1))

echo -e "${YELLOW}New version: ${NEW_VERSION} (build ${NEW_BUILD})${NC}"

# ── 3. Update project.pbxproj ──
echo -e "${GREEN}▶ Updating project version...${NC}"
sed -i '' "s/MARKETING_VERSION = $CURRENT_VERSION;/MARKETING_VERSION = $NEW_VERSION;/g" "$PROJECT_FILE"
sed -i '' "s/CURRENT_PROJECT_VERSION = $BUILD_NUMBER;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" "$PROJECT_FILE"

# ── 4. Archive ──
echo -e "${GREEN}▶ Archiving...${NC}"
./Scripts/deploy.sh archive

# ── 5. Export IPA ──
echo -e "${GREEN}▶ Exporting IPA...${NC}"
./Scripts/deploy.sh export

IPA_PATH="./build/CleoAI.ipa"
if [ ! -f "$IPA_PATH" ]; then
    echo -e "${RED}❌ IPA not found at $IPA_PATH${NC}"
    exit 1
fi

IPA_SIZE=$(stat -f%z "$IPA_PATH")
echo -e "${GREEN}✅ IPA generated: ${IPA_PATH} (${IPA_SIZE} bytes)${NC}"

# ── 6. Git commit + tag ──
echo -e "${GREEN}▶ Committing version bump...${NC}"
git add -A
git commit -m "🔖 v${NEW_VERSION}"

TAG_NAME="v${NEW_VERSION}"
echo -e "${GREEN}▶ Tagging ${TAG_NAME}...${NC}"
git tag "$TAG_NAME"

# ── 7. Push ──
echo -e "${GREEN}▶ Pushing to GitHub...${NC}"
git push origin main --tags

# ── 8. GitHub Release ──
echo -e "${GREEN}▶ Creating GitHub Release...${NC}"
RELEASE_NOTES=$(mktemp)
cat > "$RELEASE_NOTES" << EOF
## CleoAI v${NEW_VERSION}

### 변경 사항
$(git log --oneline --no-decorate "$TAG_NAME" ^$(git tag --sort=-creatordate | head -2 | tail -1 2>/dev/null || echo "") 2>/dev/null || echo "- Initial release")

### 설치 방법 (SideStore)
1. iPhone에서 SideStore 열기
2. Sources 탭 → + 버튼
3. 아래 URL 입력:
   \`https://raw.githubusercontent.com/makepluscode/CleoNoteAI/main/altstore-source.json\`
4. CleoAI 앱 찾아서 설치

### 요구사항
- iOS 18.5 이상
- SideStore 0.6+
EOF

gh release create "$TAG_NAME" \
    --title "CleoAI v${NEW_VERSION}" \
    --notes-file "$RELEASE_NOTES" \
    "$IPA_PATH"

rm "$RELEASE_NOTES"
echo -e "${GREEN}✅ Release published: https://github.com/makepluscode/CleoNoteAI/releases/tag/${TAG_NAME}${NC}"

# ── 9. Update altstore-source.json ──
echo -e "${GREEN}▶ Updating SideStore source...${NC}"
RELEASE_DATE=$(date -u +%Y-%m-%d)

# Update version, date, downloadURL, size in source JSON
python3 -c "
import json, sys

with open('${SOURCE_JSON}', 'r') as f:
    data = json.load(f)

if data['apps']:
    app = data['apps'][0]
    app['version'] = '${NEW_VERSION}'
    app['versionDate'] = '${RELEASE_DATE}'
    app['downloadURL'] = 'https://github.com/makepluscode/CleoNoteAI/releases/download/${TAG_NAME}/CleoAI.ipa'
    app['size'] = ${IPA_SIZE}

with open('${SOURCE_JSON}', 'w') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
"

git add "$SOURCE_JSON"
git commit -m "📦 Update SideStore source to v${NEW_VERSION}"
git push origin main

echo -e ""
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Release v${NEW_VERSION} complete!${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e ""
echo -e "SideStore Source URL:"
echo -e "  https://raw.githubusercontent.com/makepluscode/CleoNoteAI/main/altstore-source.json"
echo -e ""
echo -e "Release URL:"
echo -e "  https://github.com/makepluscode/CleoNoteAI/releases/tag/${TAG_NAME}"
echo -e ""
echo -e "iPhone에서 SideStore → Sources → + → 위 URL 입력 후 설치하세요."
