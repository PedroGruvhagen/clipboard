# Handoff: Demoskop Clipboard

## Project Status: Ready for GitHub

This is a **fully working macOS clipboard manager** with Markdown → Rich Text conversion.

## What's Done

- ✅ Full app implementation (Swift/SwiftUI)
- ✅ Markdown to Rich Text conversion (including GFM tables!)
- ✅ Global keyboard shortcuts working
- ✅ Menu bar UI with history, search, favorites
- ✅ Help dialog with shortcuts guide
- ✅ Beautiful README.md created
- ✅ LICENSE file (MIT with Attribution - requires credit to Demoskop)
- ✅ App icon in assets/

## What's Needed

1. **Create GitHub repo** at github.com/Demoskop/demoskop-clipboard (or your preferred name)
2. **Take a screenshot** of the app and save as `assets/screenshot.png`
3. **Init git and push**:
   ```bash
   cd ~/projects/demoskop-clipboard
   git init
   git add .
   git commit -m "Initial release: Demoskop Clipboard v1.0.0"
   git remote add origin git@github.com:Demoskop/demoskop-clipboard.git
   git push -u origin main
   ```
4. **Create a Release** on GitHub and attach the zip file from Desktop

## Files Structure

```
demoskop-clipboard/
├── README.md              # Beautiful GitHub readme
├── LICENSE                # MIT License
├── Package.swift          # Swift dependencies
├── assets/
│   └── app-icon.png       # Logo for README
├── ClipboardManager/      # All source code
└── scripts/
    └── build-release.sh   # Build script
```

## Key Technical Details

- Uses `.unsafe` option in Down library to allow HTML tables (cmark strips HTML by default)
- Custom GFM table parser since Down/cmark doesn't support tables
- MenuBarExtraAccess library for hotkey toggle of menu bar
- Requires Accessibility permission for paste simulation

## Distribution

The zip is already on Desktop: `~/Desktop/DemoskopClipboard.zip` (3.4 MB)

For proper distribution, consider notarizing the app (requires $99/year Apple Developer account).
