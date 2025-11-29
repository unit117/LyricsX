# LyricsX Architecture Documentation

> Comprehensive documentation of the existing backend logic and system architecture

## Overview

LyricsX is a macOS lyrics application that automatically fetches and displays synchronized lyrics for currently playing music. The application follows a layered architecture with clear separation between UI, business logic, and external integrations.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     UI Layer (AppKit)                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Karaoke    │  │  Menu Bar   │  │     Touch Bar       │  │
│  │  Overlay    │  │  Lyrics     │  │     Lyrics          │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
├─────────────────────────────────────────────────────────────┤
│                   Controller Layer                          │
│  ┌─────────────────────────────────────────────────────┐    │
│  │               AppController (Singleton)              │    │
│  │  - Lyrics state management                          │    │
│  │  - Current line tracking                            │    │
│  │  - Search coordination                              │    │
│  └─────────────────────────────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│                   Service Layer                             │
│  ┌──────────────────┐  ┌──────────────────────────────┐    │
│  │   LyricsKit      │  │      MusicPlayer             │    │
│  │  (External SPM)  │  │     (External SPM)           │    │
│  │                  │  │                              │    │
│  │  - Multi-source  │  │  - Multi-player support      │    │
│  │    fetching      │  │  - Playback state tracking   │    │
│  │  - LRCX parsing  │  │  - Track metadata            │    │
│  └──────────────────┘  └──────────────────────────────┘    │
├─────────────────────────────────────────────────────────────┤
│                   External Systems                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐  │
│  │ Apple Music  │  │   Spotify    │  │ Lyrics Sources   │  │
│  │    (API)     │  │    (API)     │  │    (Web APIs)    │  │
│  └──────────────┘  └──────────────┘  └──────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Core Components

### 1. AppController (Singleton)

**Location:** `LyricsX/Component/AppController.swift` (relative to project root)

The central coordinator for the application's business logic.

#### Responsibilities:
- Manages current lyrics state (`@Published var currentLyrics`)
- Tracks current line index for display synchronization
- Coordinates lyrics search operations
- Handles lyrics offset adjustments
- Manages lyrics persistence

#### Key Properties:
```swift
class AppController: NSObject {
    static let shared = AppController()
    
    let lyricsManager = LyricsProviders.Group()
    @Published var currentLyrics: Lyrics?
    @Published var currentLineIndex: Int?
    @objc dynamic var lyricsOffset: Int
}
```

#### Event Flow:
1. Track change detected via `selectedPlayer.currentTrackWillChange`
2. `currentTrackChanged()` is called
3. Local lyrics are searched first
4. If not found, remote lyrics search is initiated
5. Best matching lyrics are selected and displayed

### 2. MusicPlayer Integration

**External Package:** [ddddxxx/MusicPlayer](https://github.com/ddddxxx/MusicPlayer)

Provides unified interface for multiple music players.

#### Supported Players:
- Apple Music (iTunes)
- Spotify
- Swinsian
- Vox
- Audirvana
- And more...

#### Key Types:
- `MusicPlayers.Selected` - Currently active player
- `MusicTrack` - Track metadata (title, artist, album, duration)
- `PlaybackState` - Current playback position and state

#### Usage Pattern:
```swift
let selectedPlayer = MusicPlayers.Selected.shared
let track = selectedPlayer.currentTrack
let playbackState = selectedPlayer.playbackState
```

### 3. LyricsKit Integration

**External Package:** [ddddxxx/LyricsKit](https://github.com/ddddxxx/LyricsKit)

Handles lyrics fetching, parsing, and management.

#### Supported Sources:
- NetEase Music (网易云音乐)
- QQ Music (QQ音乐)
- Kugou (酷狗音乐)
- Xiami (虾米音乐)
- Gecimi
- ViewLyrics
- Syair

#### Key Types:
- `Lyrics` - Parsed lyrics with lines and metadata
- `LyricsLine` - Individual line with timing information
- `LyricsSearchRequest` - Search parameters
- `LyricsProviders.Group` - Aggregated provider

#### LRCX Format:
LyricsX uses a custom extension of the LRC format that supports:
- Word-level timing (karaoke mode)
- Multi-language translations
- Rich metadata

### 4. UI Controllers

#### KaraokeLyricsController
**Location:** `LyricsX/Controller/KaraokeLyricsController.swift`

Manages the desktop lyrics overlay window with karaoke-style animation.

Features:
- Floating window above all applications
- Character-by-character progress animation
- Customizable fonts, colors, and positioning
- Mouse passthrough when not interacting

#### MenuBarLyricsController
**Location:** `LyricsX/Controller/MenuBarLyricsController.swift`

Displays lyrics in the macOS menu bar.

Features:
- Compact single-line display
- Scrolling for long lines
- Quick access menu

#### TouchBarLyricsController
**Location:** `LyricsX/Controller/TouchBarLyricsController.swift`

Shows lyrics on MacBook Pro Touch Bar (where available).

### 5. View Components

#### KaraokeLyricsView
**Location:** `LyricsX/View/KaraokeLyricsView.swift`

Core rendering component for desktop lyrics.

#### KaraokeLabel
**Location:** `LyricsX/View/KaraokeLabel.swift`

Custom label that supports character-by-character fill animation for karaoke effect.

#### ScrollLyricsView
**Location:** `LyricsX/View/ScrollLyricsView.swift`

Scrollable view showing multiple lyrics lines with current line highlighting.

## Data Flow

### Lyrics Search Flow

```
┌─────────────┐     ┌─────────────────┐     ┌───────────────┐
│ Track Change│ ──▶ │ Check Local     │ ──▶ │ Search Remote │
│   Event     │     │ Lyrics Files    │     │ Sources       │
└─────────────┘     └─────────────────┘     └───────────────┘
                            │                       │
                            ▼                       ▼
                    ┌───────────────┐       ┌───────────────┐
                    │ Found: Load   │       │ Found: Filter │
                    │ & Display     │       │ & Persist     │
                    └───────────────┘       └───────────────┘
```

### Lyrics Display Synchronization

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│ Playback Time   │ ──▶ │ Calculate Line   │ ──▶ │ Update UI   │
│ Change          │     │ Index            │     │ Controllers │
└─────────────────┘     └──────────────────┘     └─────────────┘
                               │
                               ▼
                        ┌──────────────────┐
                        │ Schedule Next    │
                        │ Line Check       │
                        └──────────────────┘
```

## State Management

### Reactive Patterns (CXShim/Combine)

The application uses CombineX (CXShim) for reactive state management:

```swift
// Publisher for track changes
selectedPlayer.currentTrackWillChange
    .signal()
    .receive(on: DispatchQueue.lyricsDisplay.cx)
    .invoke(AppController.currentTrackChanged, weaklyOn: self)
    .store(in: &cancelBag)

// Published properties for UI binding
@Published var currentLyrics: Lyrics?
@Published var currentLineIndex: Int?
```

### User Defaults

User preferences are managed via typed keys:

```swift
extension UserDefaults.DefaultsKeys {
    static let desktopLyricsEnabled = Key<Bool>("DesktopLyricsEnabled")
    static let menuBarLyricsEnabled = Key<Bool>("MenuBarLyricsEnabled")
    // ... many more
}

// Usage
defaults[.desktopLyricsEnabled] = true
```

## File Organization

```
LyricsX/
├── Component/              # Core business logic
│   ├── AppController.swift    # Main coordinator
│   ├── AppDelegate.swift      # App lifecycle
│   └── ...
├── Controller/             # UI controllers
│   ├── KaraokeLyricsController.swift
│   ├── MenuBarLyricsController.swift
│   └── Preferences/        # Preference panels
├── View/                   # Custom views
│   ├── KaraokeLyricsView.swift
│   ├── KaraokeLabel.swift
│   └── ...
├── Utility/               # Helpers and extensions
│   ├── Global.swift       # Global constants
│   ├── Extension.swift    # Swift extensions
│   └── ...
└── Supporting Files/      # Resources
```

## Dependencies

### Swift Package Manager Dependencies

| Package | Purpose |
|---------|---------|
| [LyricsKit](https://github.com/ddddxxx/LyricsKit) | Lyrics fetching and parsing |
| [MusicPlayer](https://github.com/ddddxxx/MusicPlayer) | Music player integration |
| [CombineX](https://github.com/cx-org/CombineX) | Reactive programming (backport) |
| [SwiftyOpenCC](https://github.com/ddddxxx/SwiftyOpenCC) | Chinese character conversion |
| [GenericID](https://github.com/ddddxxx/GenericID) | Type-safe identifiers |
| [SwiftCF](https://github.com/ddddxxx/SwiftCF) | Core Foundation wrappers |
| [SnapKit](https://github.com/SnapKit/SnapKit) | Auto Layout DSL |
| [MASShortcut](https://github.com/shpakovski/MASShortcut) | Global keyboard shortcuts |
| [Sparkle](https://github.com/sparkle-project/Sparkle) | Auto-updates (non-MAS) |
| [AppCenter](https://github.com/microsoft/appcenter-sdk-apple) | Analytics and crash reporting |

## Thread Safety

### Dispatch Queues

```swift
extension DispatchQueue {
    static let lyricsDisplay = DispatchQueue(label: "LyricsDisplay")
}
```

All lyrics display updates are serialized on the `lyricsDisplay` queue to prevent race conditions.

## Preserved Components

The following components contain critical, battle-tested logic and should be wrapped, not replaced during modernization:

1. **LyricsKit** - Multi-source lyrics fetching and parsing
2. **MusicPlayer** - Multi-player integration
3. **KaraokeLabel/KaraokeLyricsView** - Character-by-character rendering
4. **LRCX Format Handling** - Custom lyrics format with word-level timing

## Future Architecture (Planned)

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

## Migration Notes

When modernizing to SwiftUI and Swift Concurrency:

1. **Replace CXShim/CombineX with native Combine** - macOS 12+ has native Combine (CXShim is a compatibility shim for CombineX)
2. **Adopt @Observable** - Replace @Published with @Observable macro (macOS 14+)
3. **Use async/await** - Replace completion handlers with async functions
4. **Create Service Protocols** - Abstract LyricsKit/MusicPlayer for testability
5. **Preserve KaraokeLabel** - Complex animation logic should be wrapped in SwiftUI

## References

- [ROADMAP.md](../ROADMAP.md) - Modernization timeline and goals
- [LyricsKit Documentation](https://github.com/ddddxxx/LyricsKit)
- [MusicPlayer Documentation](https://github.com/ddddxxx/MusicPlayer)
