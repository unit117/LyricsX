# LyricsX Build & Troubleshooting Guide

> Documentation of build issues, solutions, and known problems for future reference.

## Current Build Status

⚠️ **BUILD BLOCKED** - Swift Package Manager dependency resolution failing

### Error Summary

```
xcodebuild: error: Could not resolve package dependencies:
  the package manifest at '/Package.swift' cannot be accessed 
  (/Package.swift doesn't exist in file system)
```

---

## Known Issues

### 1. SPM Package Resolution Failure (CRITICAL)

**Status:** 🔴 Unresolved  
**Date Discovered:** November 29, 2025  
**Affects:** All build attempts

#### Problem Description

When attempting to resolve Swift Package Manager dependencies, Xcode fails with an error stating that `/Package.swift` cannot be accessed at the root filesystem (`/`). This is not referring to a `Package.swift` in the project directory, but at the filesystem root.

#### Root Cause Analysis

1. **Commit `97cade4`** ("Migrate SnapKit and MASShortcut from Carthage to Swift Package Manager") introduced SPM references for SnapKit and MASShortcut
2. The **upstream project** (`ddddxxx/LyricsX`) uses **Carthage frameworks** (`.framework` files) for these dependencies
3. The SPM migration appears to have a bug - either in the package URL or the way packages are referenced
4. The `Package.resolved` file doesn't contain entries for SnapKit or MASShortcut, suggesting they were never successfully resolved

#### Attempted Solutions

| Solution | Result |
|----------|--------|
| Clear SPM cache (`rm -rf ~/Library/Caches/org.swift.swiftpm`) | ❌ Failed |
| Clear DerivedData (`rm -rf ~/Library/Developer/Xcode/DerivedData`) | ❌ Failed |
| Delete Package.resolved and re-resolve | ❌ Failed |
| Update MASShortcut URL to `cocoabits/MASShortcut` (new repo location) | ❌ Failed |
| Reset project file to original state | ❌ Failed (original also has this issue) |
| Open in Xcode GUI for resolution | ⏳ Pending |

#### Package URLs in Project

```
SnapKit: https://github.com/SnapKit/SnapKit (version 5.0.0+)
MASShortcut: https://github.com/shpakovski/MASShortcut (version 2.4.0+)
  - Note: MASShortcut repo was moved to cocoabits/MASShortcut and archived
```

#### Potential Fixes to Try

1. **Revert to Carthage** - Use the upstream project's approach with framework files
2. **Use CocoaPods** - Alternative dependency manager
3. **Manual Framework Integration** - Download and embed frameworks manually
4. **Fork problematic packages** - Create forks with fixed Package.swift files

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

### Working SPM Packages (from Package.resolved)

| Package | Version | URL |
|---------|---------|-----|
| AppCenter | 4.1.1 | microsoft/appcenter-sdk-apple |
| CombineX | 0.4.0 | cx-org/CombineX |
| CXExtensions | 0.4.0 | cx-org/CXExtensions |
| CXShim | 0.4.0 | cx-org/CXShim |
| GenericID | 0.7.0 | ddddxxx/GenericID |
| Gzip | 5.1.1 | 1024jp/GzipSwift |
| LyricsKit | 0.11.0 | ddddxxx/LyricsKit |
| MusicPlayer | 0.8.2 | ddddxxx/MusicPlayer |
| PLCrashReporter | 1.8.1 | microsoft/PLCrashReporter |
| Regex | 1.0.1 | ddddxxx/Regex |
| Semver | 0.2.1 | ddddxxx/Semver |
| Sparkle | 1.26.0 | sparkle-project/Sparkle |
| swift-atomics | 0.0.3 | apple/swift-atomics |
| SwiftCF | 0.2.1 | ddddxxx/SwiftCF |
| SwiftyOpenCC | v2.0.0-beta (branch) | ddddxxx/SwiftyOpenCC |
| TouchBarHelper | 0.1.0 | ddddxxx/TouchBarHelper |

### Problematic Packages (NOT in Package.resolved)

| Package | Intended Version | Issue |
|---------|-----------------|-------|
| SnapKit | 5.0.0+ | Never resolved, causes `/Package.swift` error |
| MASShortcut | 2.4.0+ | Repo archived, never resolved |

---

## Project History

### Relevant Commits

| Commit | Description | Impact |
|--------|-------------|--------|
| `97cade4` | Migrate SnapKit/MASShortcut to SPM | 🔴 Introduced build issue |
| `c16b6a4` | Upstream master (uses Carthage) | ✅ Works |

### Upstream vs Fork Comparison

The **upstream project** (`ddddxxx/LyricsX`) at commit `c16b6a4`:
- Uses **Carthage** for SnapKit and MASShortcut
- Has `.framework` files in the project
- Builds successfully

The **fork** (`unit117/LyricsX`) at commit `bffa152`:
- Attempted SPM migration for SnapKit/MASShortcut
- SPM references exist but packages won't resolve
- Build is blocked

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

# Reset to upstream state (CAUTION: loses local changes)
git checkout upstream/master -- LyricsX.xcodeproj/project.pbxproj
```

---

## Next Steps

1. [ ] Try building in Xcode GUI (sometimes resolves packages better)
2. [ ] Consider reverting SPM migration and using Carthage
3. [ ] Open issue on upstream repo to discuss proper SPM migration
4. [ ] Test with fresh clone of upstream project to verify it builds

---

## Related Documentation

- [ROADMAP.md](ROADMAP.md) - Project modernization roadmap
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Architecture documentation
- [Upstream README](https://github.com/ddddxxx/LyricsX) - Original project

---

*Last Updated: November 29, 2025*
