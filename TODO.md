# LyricsX TODO List

> Tracking all pending tasks, issues, and future work

---

## 🔴 Critical (Blocking)

### Build System
- [ ] **Fix SPM package resolution failure**
  - Error: `/Package.swift` cannot be accessed at filesystem root
  - Affects: SnapKit and MASShortcut packages
  - Options:
    - [ ] Revert to Carthage (upstream approach)
    - [ ] Use CocoaPods instead
    - [ ] Manual framework integration
    - [ ] Fork packages with fixed Package.swift
  - See: [BUILD-TROUBLESHOOTING.md](docs/BUILD-TROUBLESHOOTING.md)

---

## 🟡 High Priority

### Code Signing
- [ ] Update signing configuration for new development team
  - Remove hardcoded team ID `3665V726AE`
  - Add `PRODUCT_BUNDLE_IDENTIFIER` back to build settings
  - Document signing setup for contributors

### Documentation
- [x] Create BUILD-TROUBLESHOOTING.md
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
- [x] Migrate most dependencies to SPM (partial - SnapKit/MASShortcut blocked)
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
| B001 | SPM `/Package.swift` resolution error | Open | Critical |
| B002 | Missing bundle identifier in build settings | Open | Medium |
| B003 | Code signing team mismatch | Open | Medium |

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

### November 29, 2025
- Attempted to build project - encountered SPM resolution failure
- Identified root cause: SnapKit/MASShortcut SPM migration issue
- Tried multiple fixes (cache clearing, URL updates, reset to original)
- Created comprehensive documentation:
  - BUILD-TROUBLESHOOTING.md
  - TODO.md
  - Updated ROADMAP.md
  - Created README.new.md
- Marked Phase 3 as complete in ROADMAP

---

*Last Updated: November 29, 2025*
