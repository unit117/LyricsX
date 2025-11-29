# LyricsX Modernization Roadmap

> Redesigning LyricsX with modern Swift/SwiftUI while preserving backend logic

## Project Goals
- Modernize UI layer with SwiftUI
- Migrate from Carthage to Swift Package Manager
- Adopt Swift Concurrency (async/await)
- Improve accessibility and localization
- Maintain full backward compatibility

## Timeline

### Phase 1: Foundation Modernization (Week 1-2)
- [x] Migrate dependencies from Carthage to Swift Package Manager
  - ⚠️ **Partial** - SnapKit/MASShortcut SPM migration has issues (see [BUILD-TROUBLESHOOTING.md](docs/BUILD-TROUBLESHOOTING.md))
- [x] Update to Swift 5.9+ with modern concurrency
- [x] Create architecture documentation for existing backend logic
- [x] Set up GitHub Actions CI/CD pipeline

### Phase 2: UI Layer Redesign (Week 3-5)
- [x] Design SwiftUI component library
- [x] Migrate preferences panel to SwiftUI
- [x] Modernize desktop lyrics overlay view
- [x] Create consistent design system and theming

### Phase 3: Backend Integration Layer (Week 6-7)
- [x] Create service protocols for LyricsKit abstraction
- [x] Create service protocols for MusicPlayer abstraction
- [x] Migrate from Combine to Swift Concurrency where appropriate
- [x] Adopt @Observable macro (macOS 14+)
- [x] Implement robust error handling system

### Phase 4: Feature Enhancements (Week 8-9)
- [ ] Add comprehensive VoiceOver accessibility support
- [ ] Migrate to modern String Catalogs for localization
- [ ] Performance profiling and optimization
- [ ] Add macOS widget support for lyrics preview

### Phase 5: Testing & Polish (Week 10)
- [ ] Write unit tests for new ViewModels and Services
- [ ] Create UI test suite for critical user flows
- [ ] Generate DocC documentation
- [ ] Prepare for App Store release (notarization, assets)

## Architecture Decisions

### Preserved Backend Components
These contain critical, battle-tested logic and should be wrapped, not replaced:
- **LyricsKit** - Multi-source lyrics fetching and parsing
- **MusicPlayer** - Multi-player integration (Spotify, Apple Music, etc.)
- **KaraokeLabel/KaraokeLyricsView** - Character-by-character animation
- **LRCX Format** - Custom lyrics format with word-level timing

### New Architecture Pattern
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

## ⚠️ Known Issues

### Critical: SPM Package Resolution Failure

**Status:** Build currently blocked due to Swift Package Manager dependency resolution failure.

**Error:**
```
the package manifest at '/Package.swift' cannot be accessed
(/Package.swift doesn't exist in file system)
```

**Root Cause:** Commit `97cade4` migrated SnapKit and MASShortcut from Carthage to SPM, but the packages fail to resolve. The upstream project uses Carthage frameworks which work correctly.

**Workarounds being investigated:**
1. Revert to Carthage for SnapKit/MASShortcut
2. Manual framework integration
3. Fork packages with corrected Package.swift files

See [BUILD-TROUBLESHOOTING.md](docs/BUILD-TROUBLESHOOTING.md) for detailed analysis and attempted solutions.

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License
GPL-3.0 - See [LICENSE](LICENSE)
