#!/bin/bash
#
# Publish a new release of DemoskopClipboard
# Handles: version bump, build, sign, notarize, DMG, Sparkle signing, GitHub release
#
# Usage: ./scripts/publish-release.sh <version>
# Example: ./scripts/publish-release.sh 1.1.0
#
# Prerequisites:
# - Apple Developer ID certificate installed
# - Sparkle Ed25519 private key in Keychain
# - gh CLI authenticated
# - App-specific password in Keychain (AC_PASSWORD)
#

set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 1.1.0"
    exit 1
fi

VERSION="$1"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( cd "$SCRIPT_DIR/.." && pwd )"
BUILD_DIR="$PROJECT_DIR/build"
APP_NAME="DemoskopClipboard"
SIGNING_IDENTITY="Developer ID Application: Pedro Gruvhagen (NDVYB433TK)"
TEAM_ID="NDVYB433TK"
APPLE_ID="apple.demoskop@demoskop.appleaccount.com"

# GitHub release repo (public repo for hosting release artifacts)
GITHUB_RELEASES_REPO="DemoskopAB/demoskop-clipboard-releases"

echo "=== DemoskopClipboard Release v${VERSION} ==="
echo ""

# Step 1: Update version in Info.plist
echo "Step 1: Updating version to ${VERSION}..."
python3 -c "
import plistlib
with open('$PROJECT_DIR/ClipboardManager/Info.plist', 'rb') as f:
    plist = plistlib.load(f)
plist['CFBundleShortVersionString'] = '$VERSION'
build = int(plist.get('CFBundleVersion', '0')) + 1
plist['CFBundleVersion'] = str(build)
with open('$PROJECT_DIR/ClipboardManager/Info.plist', 'wb') as f:
    plistlib.dump(plist, f)
print(f'Version: $VERSION, Build: {build}')
"

# Step 2: Build release
echo ""
echo "Step 2: Building release..."
"$SCRIPT_DIR/build-release.sh"

# Step 3: Notarize
echo ""
echo "Step 3: Notarizing..."
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

# Create ZIP for notarization
ZIP_PATH="$BUILD_DIR/$APP_NAME-notarize.zip"
ditto -c -k --keepParent "$APP_BUNDLE" "$ZIP_PATH"

echo "Submitting to Apple for notarization..."
xcrun notarytool submit "$ZIP_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "@keychain:AC_PASSWORD" \
    --wait

# Staple the ticket
xcrun stapler staple "$APP_BUNDLE"
rm -f "$ZIP_PATH"

# Step 4: Create DMG
echo ""
echo "Step 4: Creating DMG..."
"$SCRIPT_DIR/create-dmg.sh"

DMG_PATH="$BUILD_DIR/$APP_NAME-${VERSION}.dmg"

# Notarize DMG (already signed by create-dmg.sh)
echo "Notarizing DMG..."
xcrun notarytool submit "$DMG_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$TEAM_ID" \
    --password "@keychain:AC_PASSWORD" \
    --wait
xcrun stapler staple "$DMG_PATH"

# Step 5: Sign update for Sparkle
echo ""
echo "Step 5: Signing update for Sparkle..."
DMG_SIZE=$(stat -f%z "$DMG_PATH")

# Try to find sign_update in Sparkle checkout
SPARKLE_CHECKOUT="$PROJECT_DIR/.build/checkouts/Sparkle"
SIGN_UPDATE=$(find "$SPARKLE_CHECKOUT" -name "sign_update" -type f 2>/dev/null | head -1)

if [ -n "$SIGN_UPDATE" ] && [ -x "$SIGN_UPDATE" ]; then
    SIGNATURE=$("$SIGN_UPDATE" "$DMG_PATH" 2>/dev/null | grep "sparkle:edSignature" | sed 's/.*sparkle:edSignature="\([^"]*\)".*/\1/')
    if [ -z "$SIGNATURE" ]; then
        SIGNATURE=$("$SIGN_UPDATE" "$DMG_PATH" 2>/dev/null)
    fi
else
    echo "WARNING: sign_update not found. Sparkle signature will be empty."
    echo "You can sign manually later with: ./scripts/sign_update.sh $DMG_PATH"
    SIGNATURE=""
fi

# Step 6: Generate appcast.xml
echo ""
echo "Step 6: Generating appcast.xml..."

DOWNLOAD_URL="https://github.com/${GITHUB_RELEASES_REPO}/releases/download/v${VERSION}/${APP_NAME}-${VERSION}.dmg"
PUB_DATE=$(date -R)

cat > "$BUILD_DIR/appcast.xml" << APPCAST_EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <channel>
        <title>Demoskop Clipboard Updates</title>
        <link>https://raw.githubusercontent.com/${GITHUB_RELEASES_REPO}/main/appcast.xml</link>
        <description>Most recent changes with links to updates.</description>
        <language>en</language>
        <item>
            <title>Version ${VERSION}</title>
            <pubDate>${PUB_DATE}</pubDate>
            <sparkle:version>${VERSION}</sparkle:version>
            <sparkle:shortVersionString>${VERSION}</sparkle:shortVersionString>
            <sparkle:minimumSystemVersion>13.0</sparkle:minimumSystemVersion>
            <enclosure
                url="${DOWNLOAD_URL}"
                sparkle:edSignature="${SIGNATURE}"
                length="${DMG_SIZE}"
                type="application/octet-stream"/>
        </item>
    </channel>
</rss>
APPCAST_EOF

echo "Appcast generated at: $BUILD_DIR/appcast.xml"

# Step 7: Create GitHub Release
echo ""
echo "Step 7: Creating GitHub release..."

if command -v gh &> /dev/null; then
    echo "Creating release v${VERSION} on ${GITHUB_RELEASES_REPO}..."

    # Check if the releases repo exists
    if gh repo view "$GITHUB_RELEASES_REPO" &>/dev/null; then
        gh release create "v${VERSION}" \
            --repo "$GITHUB_RELEASES_REPO" \
            --title "Demoskop Clipboard v${VERSION}" \
            --notes "Release v${VERSION}" \
            "$DMG_PATH"

        # Update appcast.xml in the releases repo
        echo "Updating appcast.xml in releases repo..."
        gh api repos/${GITHUB_RELEASES_REPO}/contents/appcast.xml \
            --method PUT \
            --field message="Update appcast.xml for v${VERSION}" \
            --field content="$(base64 < "$BUILD_DIR/appcast.xml")" \
            --field sha="$(gh api repos/${GITHUB_RELEASES_REPO}/contents/appcast.xml --jq '.sha' 2>/dev/null || echo '')" \
            2>/dev/null || \
        gh api repos/${GITHUB_RELEASES_REPO}/contents/appcast.xml \
            --method PUT \
            --field message="Add appcast.xml for v${VERSION}" \
            --field content="$(base64 < "$BUILD_DIR/appcast.xml")" \
            2>/dev/null

        echo ""
        echo "Release published!"
        echo "DMG: https://github.com/${GITHUB_RELEASES_REPO}/releases/download/v${VERSION}/${APP_NAME}-${VERSION}.dmg"
        echo "Appcast: https://raw.githubusercontent.com/${GITHUB_RELEASES_REPO}/main/appcast.xml"
    else
        echo "WARNING: Releases repo ${GITHUB_RELEASES_REPO} not found."
        echo "Create it first: gh repo create ${GITHUB_RELEASES_REPO} --public --description 'Demoskop Clipboard releases'"
        echo ""
        echo "Then re-run this script or manually upload:"
        echo "  gh release create v${VERSION} --repo ${GITHUB_RELEASES_REPO} --title 'v${VERSION}' $DMG_PATH"
    fi
else
    echo "WARNING: gh CLI not found. Upload manually to GitHub."
    echo "DMG: $DMG_PATH"
    echo "Appcast: $BUILD_DIR/appcast.xml"
fi

echo ""
echo "=== Release v${VERSION} Complete ==="
echo ""
echo "Files:"
echo "  App: $APP_BUNDLE"
echo "  DMG: $DMG_PATH"
echo "  Appcast: $BUILD_DIR/appcast.xml"
echo ""
echo "If this is the first release, you need to:"
echo "1. Create the releases repo: gh repo create ${GITHUB_RELEASES_REPO} --public"
echo "2. Generate Sparkle keys: ./scripts/generate_keys.sh"
echo "3. Add the public key to Info.plist (SUPublicEDKey)"
echo "4. Store the app-specific password: security add-generic-password -s 'AC_PASSWORD' -a '${APPLE_ID}' -w 'YOUR_APP_PASSWORD'"
