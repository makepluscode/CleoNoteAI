#!/bin/bash

# CleoAI OTA Release Script
# Usage: ./Scripts/release.sh [patch|minor|major]
#
# Bumps the version, builds an unsigned IPA, publishes a GitHub Release with the
# IPA attached, updates the AltStore source manifest, and commits + pushes.
#
# AltStore re-signs the app with the user's own certificate at install time, so
# the published IPA is intentionally unsigned.

set -euo pipefail

# ----- Configuration --------------------------------------------------------
PROJECT_NAME="CleoAI"
SCHEME_NAME="CleoAI"
APP_NAME="CleoAI"
GH_REPO="makepluscode/CleoNoteAI"

# Resolve repo root (this script lives in <root>/Scripts).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

PBXPROJ="$ROOT/${PROJECT_NAME}.xcodeproj/project.pbxproj"
ALTSTORE_JSON="$ROOT/altstore-source.json"
BUILD_OUTPUT="$ROOT/build"
DERIVED="$BUILD_OUTPUT/DerivedData"

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
step()  { echo -e "\n${BLUE}==>${NC} ${1}"; }
ok()    { echo -e "${GREEN}✅ ${1}${NC}"; }
warn()  { echo -e "${YELLOW}⚠️  ${1}${NC}"; }
die()   { echo -e "${RED}❌ ${1}${NC}" >&2; exit 1; }

# ----- 0. Validate input & environment --------------------------------------
BUMP="${1:-}"
case "$BUMP" in
  patch|minor|major) ;;
  *) die "Usage: $0 [patch|minor|major]" ;;
esac

# Load GH_TOKEN from a local .env if gh is not already authenticated.
if ! gh auth status >/dev/null 2>&1; then
  for envfile in "$ROOT/.env" "$HOME/.hermes/profiles/cleoai/.env"; do
    if [ -f "$envfile" ]; then
      # shellcheck disable=SC1090
      set -a; . "$envfile"; set +a
      [ -n "${GH_TOKEN:-}" ] && export GH_TOKEN && break
    fi
  done
fi
gh auth status >/dev/null 2>&1 || [ -n "${GH_TOKEN:-}" ] || \
  die "GitHub CLI not authenticated and GH_TOKEN not found. Set GH_TOKEN or run 'gh auth login'."

command -v jq >/dev/null 2>&1 || die "jq is required but not installed."

# Refuse to release with a dirty tree (besides the files we are about to touch).
if [ -n "$(git status --porcelain --untracked-files=no)" ]; then
  warn "Working tree has uncommitted changes; they will be included in the release commit:"
  git status --short
fi

# ----- 1. Read & bump version -----------------------------------------------
step "Reading current version from project.pbxproj"
CUR_VERSION="$(grep -m1 'MARKETING_VERSION = ' "$PBXPROJ" | sed -E 's/.*= ([^;]+);/\1/' | tr -d ' ')"
CUR_BUILD="$(grep -m1 'CURRENT_PROJECT_VERSION = ' "$PBXPROJ" | sed -E 's/.*= ([^;]+);/\1/' | tr -d ' ')"
[ -n "$CUR_VERSION" ] || die "Could not read MARKETING_VERSION."
[ -n "$CUR_BUILD" ]   || die "Could not read CURRENT_PROJECT_VERSION."
echo "   Current: version=$CUR_VERSION  build=$CUR_BUILD"

# Normalize to MAJOR.MINOR.PATCH
IFS='.' read -r MAJOR MINOR PATCH <<< "$CUR_VERSION"
MAJOR="${MAJOR:-0}"; MINOR="${MINOR:-0}"; PATCH="${PATCH:-0}"

case "$BUMP" in
  patch) PATCH=$((PATCH + 1)) ;;
  minor) MINOR=$((MINOR + 1)); PATCH=0 ;;
  major) MAJOR=$((MAJOR + 1)); MINOR=0; PATCH=0 ;;
esac
NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
NEW_BUILD=$((CUR_BUILD + 1))
TAG="v${NEW_VERSION}"
RELEASE_DATE="$(date +%Y-%m-%d)"
DOWNLOAD_URL="https://github.com/${GH_REPO}/releases/download/${TAG}/${APP_NAME}.ipa"

ok "Bumping ${CUR_VERSION} (build ${CUR_BUILD}) -> ${NEW_VERSION} (build ${NEW_BUILD})"

# Abort early if the tag already exists remotely.
if gh release view "$TAG" --repo "$GH_REPO" >/dev/null 2>&1; then
  die "Release $TAG already exists on GitHub. Aborting."
fi

step "Updating project.pbxproj"
sed -i '' -E "s/MARKETING_VERSION = [^;]+;/MARKETING_VERSION = ${NEW_VERSION};/g" "$PBXPROJ"
sed -i '' -E "s/CURRENT_PROJECT_VERSION = [^;]+;/CURRENT_PROJECT_VERSION = ${NEW_BUILD};/g" "$PBXPROJ"
ok "project.pbxproj updated"

# ----- 2. Build the app (unsigned, device) ----------------------------------
step "Building ${SCHEME_NAME} for device (unsigned)"
rm -rf "$DERIVED"
xcodebuild build \
  -project "${PROJECT_NAME}.xcodeproj" \
  -scheme "${SCHEME_NAME}" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  | { command -v xcbeautify >/dev/null 2>&1 && xcbeautify || cat; }

APP_PATH="$(find "$DERIVED/Build/Products" -maxdepth 2 -name "${APP_NAME}.app" -type d | head -1)"
[ -n "$APP_PATH" ] || die "Build succeeded but ${APP_NAME}.app not found."
ok "Built: $APP_PATH"

# ----- 3. Package IPA -------------------------------------------------------
step "Packaging IPA"
IPA_PATH="$BUILD_OUTPUT/${APP_NAME}.ipa"
PAYLOAD_DIR="$BUILD_OUTPUT/Payload"
rm -rf "$PAYLOAD_DIR" "$IPA_PATH"
mkdir -p "$PAYLOAD_DIR"
cp -R "$APP_PATH" "$PAYLOAD_DIR/"
( cd "$BUILD_OUTPUT" && zip -qry "${APP_NAME}.ipa" Payload )
rm -rf "$PAYLOAD_DIR"
[ -f "$IPA_PATH" ] || die "Failed to create IPA."
IPA_SIZE="$(stat -f%z "$IPA_PATH")"
ok "IPA created: $IPA_PATH ($(du -h "$IPA_PATH" | cut -f1))"

# ----- 4. Update AltStore source manifest -----------------------------------
step "Updating altstore-source.json"
TMP_JSON="$(mktemp)"
jq \
  --arg v "$NEW_VERSION" \
  --arg b "$NEW_BUILD" \
  --arg url "$DOWNLOAD_URL" \
  --argjson size "$IPA_SIZE" \
  --arg date "$RELEASE_DATE" \
  '
  .apps[0].version = $v
  | .apps[0].versionDate = $date
  | .apps[0].versionDescription = ("Release " + $v)
  | .apps[0].downloadURL = $url
  | .apps[0].size = $size
  | .apps[0].versions =
      ([{
          version: $v,
          buildVersion: $b,
          date: $date,
          localizedDescription: ("Release " + $v),
          downloadURL: $url,
          size: $size
        }] + (.apps[0].versions // []))
  ' "$ALTSTORE_JSON" > "$TMP_JSON"
mv "$TMP_JSON" "$ALTSTORE_JSON"
ok "altstore-source.json updated (version $NEW_VERSION, size $IPA_SIZE bytes)"

# ----- 5. Commit & push -----------------------------------------------------
step "Committing and pushing version bump"
git add "$PBXPROJ" "$ALTSTORE_JSON"
git commit -m "chore(release): ${NEW_VERSION} (build ${NEW_BUILD})

- Bump MARKETING_VERSION to ${NEW_VERSION}, CURRENT_PROJECT_VERSION to ${NEW_BUILD}
- Update AltStore source for ${TAG}"
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
git push origin "$CURRENT_BRANCH"
ok "Pushed commit to origin/${CURRENT_BRANCH}"

# ----- 6. Create GitHub Release ---------------------------------------------
step "Creating GitHub Release ${TAG}"
gh release create "$TAG" "$IPA_PATH" \
  --repo "$GH_REPO" \
  --target "$CURRENT_BRANCH" \
  --title "${APP_NAME} ${NEW_VERSION}" \
  --notes "Automated release ${TAG} (build ${NEW_BUILD}).

Install via AltStore using the source:
\`https://raw.githubusercontent.com/${GH_REPO}/main/altstore-source.json\`"
ok "GitHub Release ${TAG} published with ${APP_NAME}.ipa attached"

echo -e "\n${GREEN}🎉 Release ${TAG} complete!${NC}"
echo -e "   Version:      ${NEW_VERSION} (build ${NEW_BUILD})"
echo -e "   Download URL: ${DOWNLOAD_URL}"
echo -e "   AltStore src: https://raw.githubusercontent.com/${GH_REPO}/main/altstore-source.json"
