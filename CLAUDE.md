# Demoskop Clipboard - Project Instructions

## App Overview
Native Swift macOS menu bar clipboard manager with automatic Markdown-to-rich-text conversion.
Bundle ID: `se.demoskop.clipboard`

## Apple Code Signing & Distribution

### Credentials
- **Team ID**: NDVYB433TK
- **Signing Identity**: `Developer ID Application: Pedro Gruvhagen (NDVYB433TK)`
- **Apple ID**: apple.demoskop@demoskop.appleaccount.com
- **App-specific password**: Stored in macOS Keychain under service name `AC_PASSWORD`

### How to Build & Sign a Release

**Quick version (one command for full release):**
```bash
./scripts/publish-release.sh 0.9.0
```
This handles everything: version bump, build, sign, notarize, DMG, Sparkle signing, GitHub release.

**Step by step:**
```bash
# 1. Build the app bundle (includes code signing automatically)
./scripts/build-release.sh

# 2. Notarize with Apple (so users don't get Gatekeeper warnings)
./scripts/notarize.sh

# 3. Create DMG installer (includes DMG signing)
./scripts/create-dmg.sh

# 4. Sign update for Sparkle auto-updater
./scripts/sign_update.sh build/DemoskopClipboard-0.9.0.dmg
```

### Notarization Prerequisite
The app-specific password must be in the Keychain. If it's missing:
```bash
security add-generic-password -s "AC_PASSWORD" -a "apple.demoskop@demoskop.appleaccount.com" -w "THE_PASSWORD"
```
Generate a new app-specific password at https://appleid.apple.com if needed (Sign-In and Security > App-Specific Passwords).

### Important Notes
- `build-release.sh` signs both Sparkle.framework and the main app bundle automatically
- Always do a clean build before releases: `swift package clean && swift build -c release`
- The DMG is also signed and should be notarized separately for distribution
- After notarization, staple the ticket: `xcrun stapler staple build/DemoskopClipboard.app`

## Auto-Update System
- Framework: Sparkle 2.5+
- Releases repo: `DemoskopAB/demoskop-clipboard-releases` (public, release artifacts only, NO source code)
- Appcast URL: `https://raw.githubusercontent.com/DemoskopAB/demoskop-clipboard-releases/main/appcast.xml`
- Sparkle Ed25519 keys need to be generated once: `./scripts/generate_keys.sh`
- Public key goes in Info.plist (`SUPublicEDKey`), private key stays in Keychain

## Build Requirements
- macOS 13+
- Swift 5.9+
- Dependencies managed via Swift Package Manager (Down, KeyboardShortcuts, Sparkle, MenuBarExtraAccess)

## Current Version
0.8.0
