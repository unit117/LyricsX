# LyricsX Build & Troubleshooting Guide

> Documentation of build issues, solutions, and known problems for future reference.

## Current Build Status

✅ **BUILD READY** - Swift Package Manager dependencies should now resolve correctly

---

## Known Issues

### 1. SPM Package Resolution Failure (FIXED)

**Status:** ✅ Resolved  
**Date Fixed:** November 29, 2025  
**Root Cause:** MASShortcut repository was moved from `shpakovski/MASShortcut` to `cocoabits/MASShortcut`

#### Solution Applied

Updated `project.pbxproj` to use the new MASShortcut repository URL:
- Old URL: `https://github.com/shpakovski/MASShortcut` (archived)
- New URL: `https://github.com/cocoabits/MASShortcut`

#### If You Still See Package Resolution Errors

Try clearing all caches:

```bash
# Full cleanup
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/.swiftpm

# Delete Package.resolved if it exists
rm -f LyricsX.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

# Resolve packages
xcodebuild -resolvePackageDependencies -project LyricsX.xcodeproj

# Build without signing
xcodebuild -project LyricsX.xcodeproj -scheme LyricsX -configuration Debug build \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

---

### 2. Code Signing Issues

**Status:** 🟡 Workaround Available  
**Severity:** Medium

#### Problem

```
No Account for Team "3665V726AE"
No signing certificate "Mac Development" found
```

#### Solution

For local development builds, disable code signing:

```bash
xcodebuild -project LyricsX.xcodeproj -scheme LyricsX -configuration Debug build \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO
```

Or in Xcode:
1. Select project in navigator
2. For each target, go to Signing & Capabilities
3. Change Team to your own or "None"
4. Set Signing Certificate to "Sign to Run Locally"

---

### 3. Missing Bundle Identifier

**Status:** 🟡 Minor  
**Affects:** LyricsX target

#### Problem

```
Bundle identifier is missing. LyricsX doesn't have a bundle identifier.
```

#### Solution

The `PRODUCT_BUNDLE_IDENTIFIER` was removed from build settings. Add it back:
- Value: `ddddxxx.LyricsX` (or your own identifier)

---

## Dependency Overview

### All SPM Packages (Working)

| Package | Version | URL |
|---------|---------|-----|
| AppCenter | 4.1.1 | microsoft/appcenter-sdk-apple |
| CombineX | 0.4.0 | cx-org/CombineX |
| CXExtensions | 0.4.0 | cx-org/CXExtensions |
| CXShim | 0.4.0 | cx-org/CXShim |
| GenericID | 0.7.0 | ddddxxx/GenericID |
| Gzip | 5.1.1 | 1024jp/GzipSwift |
| LyricsKit | 0.11.0 | ddddxxx/LyricsKit |
| MASShortcut | 2.4.0+ | cocoabits/MASShortcut |
| MusicPlayer | 0.8.2 | ddddxxx/MusicPlayer |
| PLCrashReporter | 1.8.1 | microsoft/PLCrashReporter |
| Regex | 1.0.1 | ddddxxx/Regex |
| Semver | 0.2.1 | ddddxxx/Semver |
| SnapKit | 5.0.0+ | SnapKit/SnapKit |
| Sparkle | 1.26.0 | sparkle-project/Sparkle |
| swift-atomics | 0.0.3 | apple/swift-atomics |
| SwiftCF | 0.2.1 | ddddxxx/SwiftCF |
| SwiftyOpenCC | v2.0.0-beta (branch) | ddddxxx/SwiftyOpenCC |
| TouchBarHelper | 0.1.0 | ddddxxx/TouchBarHelper |

---

## Project History

### Relevant Commits

| Commit | Description | Impact |
|--------|-------------|--------|
| Current | Fix MASShortcut URL to cocoabits/MASShortcut | ✅ Build working |
| `97cade4` | Migrate SnapKit/MASShortcut to SPM | ⚠️ Had wrong MASShortcut URL |
| `c16b6a4` | Upstream master (uses Carthage) | ✅ Works |

### Upstream vs Fork Comparison

The **upstream project** (`ddddxxx/LyricsX`) at commit `c16b6a4`:
- Uses **Carthage** for SnapKit and MASShortcut
- Has `.framework` files in the project
- Builds successfully

The **fork** (`unit117/LyricsX`):
- Successfully migrated SnapKit and MASShortcut to SPM
- Uses updated MASShortcut URL (`cocoabits/MASShortcut`)
- All SPM dependencies resolve correctly

---

## Environment Information

```
macOS: (check with `sw_vers`)
Xcode: (check with `xcodebuild -version`)
Swift: 5.9+
```

---

## Commands Reference

### Clean Build

```bash
# Full cleanup
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/.swiftpm

# Resolve packages
xcodebuild -resolvePackageDependencies -project LyricsX.xcodeproj

# Build without signing
xcodebuild -project LyricsX.xcodeproj -scheme LyricsX -configuration Debug build \
  CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

### Git Operations

```bash
# Check upstream
git fetch upstream
git log upstream/master --oneline -5

# Compare with upstream
git diff upstream/master -- LyricsX.xcodeproj/project.pbxproj | head -100
```

---

## Related Documentation

- [BUILDING.md](BUILDING.md) - Complete build instructions
- [ROADMAP.md](../ROADMAP.md) - Project modernization roadmap
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture documentation
- [Upstream README](https://github.com/ddddxxx/LyricsX) - Original project

---

*Last Updated: November 29, 2025*
