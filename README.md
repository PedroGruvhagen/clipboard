<div align="center">

# ✨ Demoskop Clipboard

**A powerful clipboard history manager for macOS — with Markdown superpowers**

*Never lose a copy again. And when you paste Markdown, it just looks beautiful.*

[Features](#-features) • [Install](#-installation) • [Usage](#-usage) • [Build](#-building-from-source)

---

<img src="assets/screenshot.png" alt="Demoskop Clipboard Screenshot" width="400">

</div>

## What Is It?

**Demoskop Clipboard** is two things:

1. **📋 Clipboard History Manager** — Saves everything you copy. Search, browse, and paste from your history anytime. Never lose that thing you copied 10 minutes ago.

2. **✨ Markdown → Rich Text Converter** — Automatically converts Markdown to formatted text when you paste. Tables become real tables. Bold is actually **bold**. Perfect for pasting into Word, Mail, or Notes.

No extra steps. No "export as". Just copy → paste → done.

---

## 🎯 Features

| Feature | Description |
|---------|-------------|
| 📋 **Clipboard History** | Never lose a copy again — access your last 1000 clips |
| ✨ **Markdown → Rich Text** | Automatic conversion for Word, Mail, Notes, and more |
| 📊 **Full Table Support** | GFM tables render perfectly in Word |
| ⌨️ **Global Hotkeys** | Quick access from any app |
| 🔒 **Privacy First** | 100% local — nothing leaves your Mac |
| 🪶 **Lightweight** | Native Swift app, ~4MB, minimal CPU usage |

### Supported Markdown

```markdown
# Headers (H1-H6)
**Bold** and *italic*
`inline code` and code blocks
- Bullet lists
1. Numbered lists
> Blockquotes
[Links](https://example.com)
| Tables | Work | Too! |
---
```

All convert beautifully to formatted text.

---

## 📦 Installation

### Quick Install

1. **[Download the latest release](../../releases/latest)**
2. Unzip and drag `DemoskopClipboard.app` to **Applications**
3. Launch — the icon appears in your menu bar

### First Launch

macOS will ask for **Accessibility permission** (needed for paste shortcuts).

→ **System Settings** → **Privacy & Security** → **Accessibility** → Enable **Demoskop Clipboard**

---

## 🚀 Usage

### Keyboard Shortcuts

| Shortcut | Action |
|:--------:|--------|
| <kbd>⇧</kbd> <kbd>⌥</kbd> <kbd>V</kbd> | Open clipboard history |
| <kbd>⌥</kbd> <kbd>⌘</kbd> <kbd>V</kbd> | Paste as **rich text** |
| <kbd>⇧</kbd> <kbd>⌥</kbd> <kbd>⌘</kbd> <kbd>V</kbd> | Paste as plain text |

### Daily Workflow

```
1. Copy text with Markdown (from anywhere)
2. Switch to Word/Mail/Notes
3. Press ⌥⌘V
4. 🎉 Formatted text appears!
```

### Menu Bar

Click the 📋 icon to:
- Browse clipboard history
- Search past copies
- Click any item to paste it
- ⭐ Star favorites
- Access settings

---

## 🔧 Building from Source

### Requirements

- macOS 13.0+
- Swift 5.9+ (or Xcode 15+)

### Build

```bash
git clone https://github.com/Demoskop/demoskop-clipboard.git
cd demoskop-clipboard

# Build release binary
swift build -c release

# Or create full .app bundle
./scripts/build-release.sh
```

App bundle appears in `build/DemoskopClipboard.app`

### Dependencies

All managed via Swift Package Manager:

- [Down](https://github.com/johnxnguyen/Down) — Markdown → HTML
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) — Global hotkeys
- [MenuBarExtraAccess](https://github.com/orchetect/MenuBarExtraAccess) — Menu bar control
- [Sparkle](https://github.com/sparkle-project/Sparkle) — Auto-updates

---

## 🏗 Architecture

```
demoskop-clipboard/
├── ClipboardManager/
│   ├── ClipboardManagerApp.swift    # App entry point
│   ├── Views/
│   │   ├── MenuBarView.swift        # Main UI + Help
│   │   └── PreferencesView.swift    # Settings
│   ├── Services/
│   │   ├── ClipboardWatcher.swift   # Monitors clipboard
│   │   ├── MarkdownConverter.swift  # MD → HTML → RTF
│   │   └── HotKeyService.swift      # Global shortcuts
│   ├── Models/
│   │   └── ClipboardEntry.swift     # Data model
│   └── Persistence/
│       └── HistoryStore.swift       # History management
├── scripts/
│   └── build-release.sh             # Build .app bundle
└── Package.swift                    # Dependencies
```

### How It Works

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  Copy    │───▶│  Detect  │───▶│  Parse   │───▶│  Store   │
│  Text    │    │ Markdown │    │  Tables  │    │   RTF    │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
                                     │
                              Custom GFM parser
                            (cmark doesn't do tables)
```

---

## 🔒 Privacy

- **100% offline** — No network requests (except optional update checks)
- **Local storage** — Data stays in `~/Library/Application Support/`
- **No analytics** — Zero tracking, zero telemetry
- **Open source** — Audit the code yourself

---

## 🤝 Contributing

Contributions welcome! Feel free to:

- 🐛 Report bugs
- 💡 Suggest features
- 🔧 Submit pull requests

---

## 📄 License

**MIT License with Attribution** — use it however you like, just credit Demoskop.

If you use this code in your project, include this in your README:
> Based on [Demoskop Clipboard](https://github.com/Demoskop/demoskop-clipboard) by [Demoskop AB](https://demoskop.se)

---

<div align="center">

Made with ☕ by **[Demoskop](https://demoskop.se)**

*If this saves you time, consider giving it a ⭐*

</div>
