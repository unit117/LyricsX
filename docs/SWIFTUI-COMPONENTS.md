# LyricsX SwiftUI Component Library

> A modern design system and component library for LyricsX built with SwiftUI

## Overview

This component library provides a consistent, reusable set of UI components following the LyricsX design system. The components are designed to work alongside existing AppKit views during the gradual migration to SwiftUI.

## Requirements

- macOS 12.0+ (Monterey)
- Swift 5.9+
- Xcode 15.2+

## Directory Structure

```
LyricsX/SwiftUI/
├── DesignSystem/
│   └── DesignSystem.swift          # Colors, typography, spacing, animations
├── Components/
│   └── LyricsXComponents.swift     # Reusable UI components
├── Views/
│   ├── PreferencesView.swift       # SwiftUI preferences panel
│   ├── LyricsDisplayView.swift     # Lyrics display components
│   └── DesktopLyricsOverlay.swift  # Desktop overlay implementation
└── SwiftUIHosting.swift            # AppKit integration bridges
```

## Design System

### Colors (`LyricsXColors`)

| Color | Usage |
|-------|-------|
| `accent` | Primary accent (cyan/teal) |
| `secondaryAccent` | Secondary accent |
| `textPrimary` | Primary text |
| `textSecondary` | Secondary/muted text |
| `lyricsText` | Lyrics text (white) |
| `lyricsProgress` | Karaoke progress color |
| `backgroundPrimary` | Window backgrounds |
| `backgroundSecondary` | Card/section backgrounds |
| `lyricsBackground` | Lyrics overlay background |

### Typography (`LyricsXTypography`)

| Style | Usage |
|-------|-------|
| `lyricsLarge(size:)` | Large lyrics display |
| `lyricsMedium(size:)` | Medium lyrics display |
| `lyricsSmall(size:)` | Small lyrics display |
| `title` | Section titles |
| `headline` | Subsection headers |
| `body` | Body text |
| `caption` | Small explanatory text |
| `monospace` | Technical/code text |

### Spacing (`LyricsXSpacing`)

| Constant | Value | Usage |
|----------|-------|-------|
| `xs` | 4pt | Tight spacing |
| `sm` | 8pt | Small spacing |
| `md` | 12pt | Medium spacing |
| `lg` | 16pt | Large spacing |
| `xl` | 24pt | Extra large spacing |
| `xxl` | 32pt | Section spacing |

### Corner Radius (`LyricsXRadius`)

| Constant | Value |
|----------|-------|
| `small` | 4pt |
| `medium` | 8pt |
| `large` | 12pt |
| `extraLarge` | 16pt |

### Animations (`LyricsXAnimation`)

| Animation | Duration | Usage |
|-----------|----------|-------|
| `quick` | 0.15s | Button presses, micro-interactions |
| `standard` | 0.25s | General transitions |
| `smooth` | 0.35s | Smooth transitions |
| `spring` | Spring | Bouncy interactions |

## Components

### LyricsXToggle

A styled toggle switch for settings.

```swift
LyricsXToggle(
    "Enable Desktop Lyrics",
    subtitle: "Show floating lyrics on your desktop",
    isOn: $isEnabled
)
```

### LyricsXSectionHeader

A section header with optional icon.

```swift
LyricsXSectionHeader("General", icon: "gear")
```

### LyricsXPickerRow

A picker row for selecting options.

```swift
LyricsXPickerRow(
    "Player",
    options: [("Auto", -1), ("Apple Music", 0), ("Spotify", 1)],
    selection: $selectedPlayer
)
```

### LyricsXSliderRow

A slider row with value display.

```swift
LyricsXSliderRow(
    "Font Size",
    value: $fontSize,
    in: 12...48,
    step: 1
) { "\(Int($0)) pt" }
```

### LyricsXColorPickerRow

A color picker row.

```swift
LyricsXColorPickerRow("Text Color", color: $textColor)
```

### LyricsXButtonRow

An action button row with disclosure indicator.

```swift
LyricsXButtonRow("Choose Folder", icon: "folder") {
    // action
}
```

## Views

### PreferencesView

A complete SwiftUI preferences panel with tabs:
- **General**: Player selection, auto-launch, lyrics storage
- **Display**: Desktop/menubar lyrics, styling options
- **Shortcuts**: Keyboard shortcut configuration
- **Filter**: Lyrics filtering options
- **Lab**: Experimental features

```swift
PreferencesView()
    .frame(width: 500, height: 400)
```

### LyricsDisplayView

A karaoke-style lyrics display view.

```swift
LyricsDisplayView(
    line1: "Never gonna give you up",
    line2: "永远不会放弃你",
    progress: 0.6
)
.fontSize(28)
.textColor(.white)
.progressColor(LyricsXColors.accent)
```

### LyricsListView

A scrollable lyrics list with highlighting.

```swift
LyricsListView(
    lines: lyricsLines,
    currentIndex: currentIndex
) { index in
    // Handle line selection
}
```

## Button Styles

### Primary Button

```swift
Button("Save") { }
    .buttonStyle(.lyricsXPrimary)
```

### Secondary Button

```swift
Button("Cancel") { }
    .buttonStyle(.lyricsXSecondary)
```

## View Modifiers

### Card Style

```swift
MyView()
    .lyricsXCard()
```

### Section Style

```swift
MySection()
    .lyricsXSection()
```

### Shadow

```swift
MyView()
    .lyricsXShadow()
```

## Integration with AppKit

The SwiftUI views can be hosted in existing AppKit windows using the `SwiftUIHosting.swift` bridges:

### Opening SwiftUI Preferences

```swift
// On macOS 13+
SwiftUIPreferencesWindowController.showPreferences()

// Or use the extension method that auto-selects based on OS version
appDelegate.openPreferences()
```

### Using the Desktop Lyrics Overlay

```swift
// Show the SwiftUI desktop lyrics overlay
if #available(macOS 12.0, *) {
    let controller = SwiftUIDesktopLyricsController.shared
    controller.show()
    controller.updateLyrics(line1: "Hello", line2: "World", progress: 0.5)
}
```

### Wrapping KaraokeLyricsView for SwiftUI

```swift
// Use the existing AppKit view in SwiftUI
KaraokeLyricsViewRepresentable(
    line1: "Current lyrics",
    line2: "Next line",
    font: .systemFont(ofSize: 28, weight: .semibold),
    textColor: .white,
    progressColor: NSColor(red: 0.2, green: 1.0, blue: 0.87, alpha: 1.0)
)
```

### Legacy AppKit Integration

The SwiftUI views can also be hosted in existing AppKit windows directly:

```swift
import SwiftUI

// In your NSViewController
let preferencesView = PreferencesView()
let hostingController = NSHostingController(rootView: preferencesView)
present(hostingController, animator: ...)
```

Or embed in NSWindow:

```swift
let window = NSWindow(
    contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
    styleMask: [.titled, .closable],
    backing: .buffered,
    defer: false
)
window.contentView = NSHostingView(rootView: PreferencesView())
```

## Adding to Xcode Project

To include these files in your build:

1. Open LyricsX.xcodeproj in Xcode
2. Right-click on the LyricsX group
3. Select "Add Files to LyricsX..."
4. Navigate to `LyricsX/SwiftUI`
5. Select all folders (DesignSystem, Components, Views)
6. Ensure "Copy items if needed" is unchecked
7. Select both LyricsX and LyricsX MAS targets
8. Click "Add"

## Future Enhancements

- [ ] Add `@Observable` macro support (macOS 14+)
- [ ] Add accessibility labels and hints
- [ ] Add localization support
- [ ] Create AppStorage wrapper for UserDefaults sync
- [ ] Add unit tests for view models
