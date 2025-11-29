# LyricsX

<p align="center">
  <img src="docs/img/icon.png" width="128px" alt="LyricsX Icon">
</p>

<p align="center">
  <strong>Ultimate lyrics app for macOS</strong>
</p>

<p align="center">
  <a href="https://crowdin.com/project/lyricsx"><img src="https://badges.crowdin.net/lyricsx/localized.svg" alt="Crowdin"></a>
  <a href="https://telegram.me/LyricsXApp"><img src="https://img.shields.io/badge/chat-Telegram-blue.svg" alt="Telegram"></a>
  <a href="https://codebeat.co/projects/github-com-ddddxxx-lyricsx-master"><img src="https://codebeat.co/badges/d4ea2fbf-89a0-4490-875f-857a1568ec16" alt="codebeat badge"></a>
  <img src="https://img.shields.io/badge/Swift-5.9+-orange.svg" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/macOS-14.0+-blue.svg" alt="macOS 14.0+">
</p>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🎵 **Multi-Player Support** | Works seamlessly with Spotify, Apple Music, and more. [Full list](https://github.com/ddddxxx/MusicPlayer#supported-players) |
| 🔍 **Auto Lyrics Search** | Automatically fetches lyrics from multiple sources. [Supported sources](https://github.com/ddddxxx/LyricsKit#supported-sources) |
| 🖥️ **Desktop Lyrics** | Beautiful overlay with customizable fonts, colors, and position |
| 📊 **Menu Bar Display** | View current lyrics right in your menu bar |
| ⏱️ **Offset Adjustment** | Fine-tune lyrics timing from the status menu |
| 🎯 **Click to Navigate** | Double-click any line to jump to that position |
| 📁 **Drag & Drop** | Import/export lyrics files effortlessly |
| 🚀 **Auto Launch** | Automatically starts and quits with your music player |
| 🈶 **Chinese Conversion** | Auto-convert between Traditional and Simplified Chinese |

## 📥 Installation

### Homebrew (Recommended)

```bash
brew install --cask lyricsx
```

### Mac App Store

[![Download on the Mac App Store](docs/img/MAS_badge.svg)](https://itunes.apple.com/us/app/lyricsx/id1254743014?mt=12)

### Manual Download

Download the latest release from [GitHub Releases](https://github.com/ddddxxx/LyricsX/releases).

### System Requirements

- **macOS 14.0+** (Sonoma or later)
- **Swift 5.9+** (for building from source)

## 📸 Screenshots

<details>
<summary>Click to expand screenshots</summary>

### Desktop Lyrics
<img src="docs/img/desktop_lyrics.gif" width="480px" alt="Desktop Lyrics Demo">

### App Preview
<img src="docs/img/preview_1.jpg" width="100%" alt="Preview 1">
<img src="docs/img/preview_2.jpg" width="100%" alt="Preview 2">
<img src="docs/img/preview_3.jpg" width="100%" alt="Preview 3">

</details>

## 🏗️ Architecture

LyricsX has been modernized with a clean architecture:

```
┌─────────────────────────────────────────────────────┐
│                    SwiftUI Views                     │
├─────────────────────────────────────────────────────┤
│                    ViewModels                        │
│              (@Observable, async/await)              │
├─────────────────────────────────────────────────────┤
│                  Service Layer                       │
│           (Protocols + Implementations)              │
├─────────────────────────────────────────────────────┤
│              Preserved Backend Logic                 │
│          (LyricsKit, MusicPlayer, etc.)              │
└─────────────────────────────────────────────────────┘
```

See [ARCHITECTURE.md](docs/ARCHITECTURE.md) for details.

## 📝 LRCX Format

LyricsX uses a custom lyrics format called **LRCX** that supports:
- Word-level timing tags
- Multi-language translations
- Extended metadata

LRCX is fully compatible with standard LRC files. For editing, you can use:
- [Lrcx_Creator](https://github.com/Doublefire-Chen/Lrcx_Creator) by [@Doublefire-Chen](https://github.com/Doublefire-Chen)
- Any standard LRC editor

## 🔧 Building from Source

> ⚠️ **Note:** There are currently known build issues with SPM package resolution. See [BUILD-TROUBLESHOOTING.md](docs/BUILD-TROUBLESHOOTING.md) for details and workarounds.

```bash
# Clone the repository
git clone https://github.com/ddddxxx/LyricsX.git
cd LyricsX

# Open in Xcode
open LyricsX.xcodeproj

# Or build from command line (if packages resolve)
xcodebuild -project LyricsX.xcodeproj -scheme LyricsX -configuration Release build
```

### Build Without Code Signing

For local development builds without a signing certificate:

```bash
xcodebuild -project LyricsX.xcodeproj -scheme LyricsX -configuration Debug build \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

## 🌐 Related Projects

- [LyricsX for iOS](https://github.com/ddddxxx/LyricsX-iOS) - iOS version (in development)
- [lyricsx-cli](https://github.com/ddddxxx/lyricsx-cli) - Linux command-line version

## 🙏 Credits

### Core Components
| Package | Description |
|---------|-------------|
| [LyricsKit](https://github.com/ddddxxx/LyricsKit) | Lyrics fetching and parsing |
| [MusicPlayer](https://github.com/ddddxxx/MusicPlayer) | Multi-player integration |

### Dependencies
- [SwiftyOpenCC](https://github.com/ddddxxx/SwiftyOpenCC) - Chinese conversion
- [SnapKit](https://github.com/SnapKit/SnapKit) - Auto Layout DSL
- [MASShortcut](https://github.com/shpakovski/MASShortcut) - Global shortcuts
- [Sparkle](https://github.com/sparkle-project/Sparkle) - Auto updates
- [CombineX](https://github.com/cx-org/CombineX) - Combine compatibility

### Special Thanks
- [Lyrics Project](https://github.com/MichaelRow/Lyrics) - Original inspiration

## 📄 License

This project is licensed under **GPL-3.0**. See [LICENSE](LICENSE) for details.

## ⚠️ Disclaimer

All lyrics are property and copyright of their respective owners.

---

<p align="center">
  Made with ❤️ for music lovers
</p>
