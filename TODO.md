# LyricsX TODO List

> Tracking all pending tasks, issues, and future work

---

## 🔴 Critical (Blocking)

### Build System
- [x] **Fix SPM package resolution failure**
  - ✅ Fixed: Updated MASShortcut URL from archived `shpakovski/MASShortcut` to `cocoabits/MASShortcut`
  - SnapKit: `https://github.com/SnapKit/SnapKit` (version 5.0.0+)
  - MASShortcut: `https://github.com/cocoabits/MASShortcut` (version 2.4.0+)
  - See: [BUILDING.md](docs/BUILDING.md) for build instructions

---

## 🟡 High Priority

### Code Signing
- [ ] Update signing configuration for new development team
  - Remove hardcoded team ID `3665V726AE`
  - Add `PRODUCT_BUNDLE_IDENTIFIER` back to build settings
  - Document signing setup for contributors

### Documentation
- [x] Create BUILD-TROUBLESHOOTING.md
- [x] Create BUILDING.md
- [x] Update ROADMAP.md with known issues
- [x] Create new README (README.new.md)
- [ ] Replace old README with new version (after review)
- [ ] Add CONTRIBUTING.md guidelines
- [ ] Generate DocC documentation

---

## 🟢 Normal Priority (Phase 4)

### Accessibility (Phase 4.1)
- [ ] Add comprehensive VoiceOver support
  - [ ] Desktop lyrics view accessibility
  - [ ] Preferences panel accessibility
  - [ ] Menu bar accessibility
- [ ] Add accessibility labels to all UI elements
- [ ] Test with VoiceOver enabled

### Localization (Phase 4.2)
- [ ] Migrate to modern String Catalogs
  - [ ] Convert Localizable.strings files
  - [ ] Convert InfoPlist.strings files
  - [ ] Update storyboard strings
- [ ] Review all existing translations
- [ ] Add missing translations

### Performance (Phase 4.3)
- [ ] Profile application with Instruments
  - [ ] Memory usage analysis
  - [ ] CPU usage during playback
  - [ ] Energy impact assessment
- [ ] Optimize lyrics rendering
- [ ] Reduce startup time

### Widget Support (Phase 4.4)
- [ ] Complete macOS widget implementation
  - [ ] LyricsTimelineProvider
  - [ ] LyricsWidget entry point
  - [ ] LyricsWidgetView UI
- [ ] Test widget updates during playback
- [ ] Add widget configuration options

---

## 🔵 Low Priority (Phase 5)

### Testing
- [ ] Write unit tests for ViewModels
  - [ ] DesktopLyricsViewModel tests
  - [ ] Service layer tests
- [ ] Create UI test suite
  - [ ] Preferences panel tests
  - [ ] Desktop lyrics interaction tests
- [ ] Achieve 70% code coverage minimum

### Release Preparation
- [ ] App notarization setup
- [ ] Update App Store assets
- [ ] Update screenshots
- [ ] Prepare release notes

---

## 📝 Completed

### Phase 1: Foundation ✅
- [x] Migrate dependencies to SPM (complete - SnapKit/MASShortcut now working)
- [x] Update to Swift 5.9+
- [x] Create architecture documentation
- [x] Set up GitHub Actions CI/CD

### Phase 2: UI Layer ✅
- [x] Design SwiftUI component library
- [x] Migrate preferences panel to SwiftUI
- [x] Modernize desktop lyrics overlay
- [x] Create design system and theming

### Phase 3: Backend Integration ✅
- [x] Create LyricsServiceProtocol
- [x] Create MusicPlayerServiceProtocol
- [x] Migrate to Swift Concurrency
- [x] Adopt @Observable macro
- [x] Implement error handling system

---

## 🐛 Bug Tracker

| ID | Description | Status | Priority |
|----|-------------|--------|----------|
| B001 | SPM `/Package.swift` resolution error | ✅ Fixed | Critical |
| B002 | Missing bundle identifier in build settings | Open | Medium |
| B003 | Code signing team mismatch | Open | Medium |

---

## 📦 Package Dependency Status

| Package | Status | URL | Version |
|---------|--------|-----|---------|
| LyricsKit | ✅ Working | ddddxxx/LyricsKit | 0.11.0+ |
| MusicPlayer | ✅ Working | ddddxxx/MusicPlayer | 0.8.0+ |
| SnapKit | ✅ Working | SnapKit/SnapKit | 5.0.0+ |
| MASShortcut | ✅ Fixed | cocoabits/MASShortcut | 2.4.0+ |
| SwiftyOpenCC | ✅ Working | ddddxxx/SwiftyOpenCC | v2.0.0-beta |
| GenericID | ✅ Working | ddddxxx/GenericID | 0.7.0+ |
| SwiftCF | ✅ Working | ddddxxx/SwiftCF | 0.2.0+ |
| Semver | ✅ Working | ddddxxx/Semver | 0.2.0+ |
| TouchBarHelper | ✅ Working | ddddxxx/TouchBarHelper | 0.1.0+ |
| CombineX | ✅ Working | cx-org/CombineX | 0.4.0+ |
| CXExtensions | ✅ Working | cx-org/CXExtensions | 0.4.0+ |
| Sparkle | ✅ Working | sparkle-project/Sparkle | 1.26.0+ |
| AppCenter | ✅ Working | microsoft/appcenter-sdk-apple | 4.1.0+ |

---

## 💡 Ideas / Future Enhancements

- [ ] Apple Silicon native optimization
- [ ] Lyrics translation integration
- [ ] Spotify lyrics API integration (if available)
- [ ] Custom themes marketplace
- [ ] Lyrics karaoke mode with scoring
- [ ] iCloud sync for lyrics library
- [ ] Shortcut/Siri integration

---

## 📅 Session Log

### November 29, 2025 (Update)
- ✅ Fixed SPM resolution issue by updating MASShortcut URL
- ✅ Created comprehensive BUILDING.md documentation
- Updated TODO.md with package status table

### November 29, 2025
- Attempted to build project - encountered SPM resolution failure
- Identified root cause: MASShortcut repo moved from shpakovski to cocoabits
- Created comprehensive documentation:
  - BUILD-TROUBLESHOOTING.md
  - TODO.md
  - Updated ROADMAP.md
  - Created README.new.md
- Marked Phase 3 as complete in ROADMAP

---

*Last Updated: November 29, 2025*
