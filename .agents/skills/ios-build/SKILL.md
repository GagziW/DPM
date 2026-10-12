---
name: ios-build
description: Compile-check the iOS app (Dopamining) without booting a simulator and report only the compile errors. Use to verify an iOS change compiles before moving on. iOS is the priority platform.
disable-model-invocation: true
---

# ios-build

The app is `DPMv4/app` (v4 — all new work). Compile-check it against the generic simulator
destination, which boots nothing:

```bash
make -C DPMv4/app build
```

`make build` runs `check-backend` (every Firestore/Functions handle must come from
`Config/Backend.swift`), then `xcodebuild build -quiet` against `generic/platform=iOS Simulator`:
it prints only warnings and errors, and exit status 0 means success. A `name=iPhone …`
destination cold-boots that simulator; the PreToolUse hook denies it.

A fix in the frozen 2.2.x app compiles the same way: `make -C DopaminingSwift build`.

If the build fails on a missing package, the packages are unresolved (the Makefile passes
`-disableAutomaticPackageResolution`): say so and stop rather than resolving over a slow network.

## Report

- On success: say so and stop.
- On failure: report each `error:` line with its `file:line`, grouped by file. Don't dump the
  whole log unless asked.
