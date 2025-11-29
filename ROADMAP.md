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
- [ ] Migrate dependencies from Carthage to Swift Package Manager
- [ ] Update to Swift 5.9+ with modern concurrency
- [ ] Create architecture documentation for existing backend logic
- [ ] Set up GitHub Actions CI/CD pipeline

### Phase 2: UI Layer Redesign (Week 3-5)
- [ ] Design SwiftUI component library
- [ ] Migrate preferences panel to SwiftUI
- [ ] Modernize desktop lyrics overlay view
- [ ] Create consistent design system and theming

### Phase 3: Backend Integration Layer (Week 6-7)
- [ ] Create service protocols for LyricsKit abstraction
- [ ] Create service protocols for MusicPlayer abstraction
- [ ] Migrate from Combine to Swift Concurrency where appropriate
- [ ] Adopt @Observable macro (macOS 14+)
- [ ] Implement robust error handling system

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

## Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License
GPL-3.0 - See [LICENSE](LICENSE)
