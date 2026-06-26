---
name: ios-build
description: Build the iOS app (Dopamining) on the simulator with the canonical xcodebuild invocation and report only the compile errors. Use to verify an iOS change compiles before moving on or porting to Android. iOS is the priority platform.
disable-model-invocation: true
---

# ios-build

iOS is the priority platform — verify Swift changes compile here before porting. This wraps the
canonical build so you don't have to remember the flags.

## Build

The Xcode project is `DopaminingSwift/Dopamining.xcodeproj`, scheme `Dopamining`. Run from `DopaminingSwift/`:

```bash
cd DopaminingSwift && xcodebuild \
  -scheme Dopamining \
  -project Dopamining.xcodeproj \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -skipPackagePluginValidation \
  -disableAutomaticPackageResolution \
  build
```

Notes:
- `xcodebuild` is verbose. Pipe through a filter to surface only failures, e.g.
  `... build 2>&1 | grep -E 'error:|warning:|BUILD (SUCCEEDED|FAILED)'`, then fall back to the
  full log only if something failed.
- `-disableAutomaticPackageResolution` assumes SPM dependencies are already resolved. If the
  build fails on a missing package, re-run once **without** that flag to let Xcode resolve, then
  restore it.
- If the named simulator (`iPhone 16`) isn't installed, list options with
  `xcrun simctl list devices available` and substitute one, telling the user what you picked.

## Report

- On `BUILD SUCCEEDED`: say so and stop.
- On `BUILD FAILED`: report each `error:` line with its `file:line`, grouped by file. Don't
  dump the whole log unless asked.
