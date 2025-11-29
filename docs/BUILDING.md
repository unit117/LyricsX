# Building LyricsX

> Complete guide for building LyricsX from source

## Prerequisites

### System Requirements

- **macOS**: 12.0 (Monterey) or later
- **Xcode**: 14.0 or later
- **Swift**: 5.9 or later

### Required Tools

```bash
# Verify Xcode installation
xcode-select --print-path
xcodebuild -version

# Verify Swift version
swift --version
```

If Xcode command line tools are not installed:

```bash
xcode-select --install
```

## Quick Start

### Option 1: Xcode GUI (Recommended for Development)

1. Clone the repository:
   ```bash
   git clone https://github.com/unit117/LyricsX.git
   cd LyricsX
   ```

2. Open the project in Xcode:
   ```bash
   open LyricsX.xcodeproj
   ```

3. Wait for Xcode to automatically resolve Swift Package Manager dependencies

4. Select the "LyricsX" scheme and your Mac as the destination

5. Build with ⌘B or run with ⌘R

### Option 2: Command Line

```bash
# Clone repository
git clone https://github.com/unit117/LyricsX.git
cd LyricsX

# Clean any existing caches (optional but recommended for first build)
rm -rf ~/Library/Developer/Xcode/DerivedData/LyricsX-*
rm -rf ~/Library/Caches/org.swift.swiftpm

# Resolve package dependencies
xcodebuild -resolvePackageDependencies -project LyricsX.xcodeproj

# Build without code signing (for local development)
xcodebuild -project LyricsX.xcodeproj \
  -scheme LyricsX \
  -configuration Debug \
  build \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

## Code Signing

### For Local Development (No Signing)

If you just want to build and test locally, disable code signing:

```bash
xcodebuild -project LyricsX.xcodeproj \
  -scheme LyricsX \
  -configuration Debug \
  build \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

Or in Xcode:
1. Select the project in the navigator
2. For each target, go to **Signing & Capabilities**
3. Change **Team** to "None" or your personal team
4. Set **Signing Certificate** to "Sign to Run Locally"

### For Distribution

To build for distribution, you need:
1. An Apple Developer account
2. A valid signing certificate
3. Proper provisioning profiles

Update the team ID in the project settings to your own team.

## Dependencies

LyricsX uses Swift Package Manager for all dependencies. Dependencies are automatically resolved when opening the project in Xcode or running `xcodebuild -resolvePackageDependencies`.

### SPM Packages

| Package | Version | Purpose |
|---------|---------|---------|
| [LyricsKit](https://github.com/ddddxxx/LyricsKit) | 0.11.0+ | Lyrics fetching and parsing |
| [MusicPlayer](https://github.com/ddddxxx/MusicPlayer) | 0.8.0+ | Music player integration |
| [SnapKit](https://github.com/SnapKit/SnapKit) | 5.0.0+ | Auto Layout DSL |
| [MASShortcut](https://github.com/cocoabits/MASShortcut) | 2.4.0+ | Keyboard shortcuts |
| [SwiftyOpenCC](https://github.com/ddddxxx/SwiftyOpenCC) | v2.0.0-beta | Chinese conversion |
| [GenericID](https://github.com/ddddxxx/GenericID) | 0.7.0+ | Generic identifiers |
| [SwiftCF](https://github.com/ddddxxx/SwiftCF) | 0.2.0+ | Core Foundation extensions |
| [Semver](https://github.com/ddddxxx/Semver) | 0.2.0+ | Semantic versioning |
| [TouchBarHelper](https://github.com/ddddxxx/TouchBarHelper) | 0.1.0+ | Touch Bar support |
| [CombineX/CXShim](https://github.com/cx-org/CombineX) | 0.4.0+ | Combine compatibility |
| [CXExtensions](https://github.com/cx-org/CXExtensions) | 0.4.0+ | Combine extensions |
| [Sparkle](https://github.com/sparkle-project/Sparkle) | 1.26.0+ | Auto-updates |
| [AppCenter](https://github.com/microsoft/appcenter-sdk-apple) | 4.1.0+ | Analytics/crash reporting |

## Troubleshooting

### Package Resolution Fails

If SPM package resolution fails:

```bash
# Clear all caches
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/.swiftpm

# Delete Package.resolved and re-resolve
rm -f LyricsX.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

# Try resolving again
xcodebuild -resolvePackageDependencies -project LyricsX.xcodeproj
```

### Code Signing Errors

**Error:** "No Account for Team" or "No signing certificate found"

**Solution:** Use the code signing workaround commands above, or set up your own development team in Xcode.

### Missing Bundle Identifier

**Error:** "Bundle identifier is missing"

**Solution:** In Xcode, go to the target's Build Settings and add `PRODUCT_BUNDLE_IDENTIFIER` with value `ddddxxx.LyricsX` (or your own identifier).

### Xcode Cache Issues

If you experience strange build issues:

```bash
# Close Xcode first, then:
rm -rf ~/Library/Developer/Xcode/DerivedData/LyricsX-*

# Reopen project
open LyricsX.xcodeproj
```

## Build Configurations

| Configuration | Purpose |
|---------------|---------|
| Debug | Local development with debugging symbols |
| Release | Optimized production build |

## Targets

| Target | Description |
|--------|-------------|
| LyricsX | Main application |
| LyricsXHelper | Helper app for login item functionality |
| LyricsXWidget | macOS widget extension |
| SwiftLint | Code linting aggregate target |

## Running Tests

```bash
# Run all tests
xcodebuild test -project LyricsX.xcodeproj \
  -scheme LyricsX \
  -destination 'platform=macOS'
```

## Useful Commands

```bash
# List available schemes
xcodebuild -project LyricsX.xcodeproj -list

# Clean build folder
xcodebuild -project LyricsX.xcodeproj clean

# Archive for distribution
xcodebuild -project LyricsX.xcodeproj \
  -scheme LyricsX \
  -configuration Release \
  archive \
  -archivePath build/LyricsX.xcarchive
```

## Related Documentation

- [BUILD-TROUBLESHOOTING.md](BUILD-TROUBLESHOOTING.md) - Detailed troubleshooting guide
- [ARCHITECTURE.md](ARCHITECTURE.md) - Project architecture overview
- [ROADMAP.md](../ROADMAP.md) - Development roadmap

---

*Last Updated: November 29, 2025*
