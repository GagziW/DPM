#!/usr/bin/env bash
# PreToolUse hook (Bash): stop compile-checks from cold-booting a simulator.
#
# A plain `xcodebuild build` against a CONCRETE simulator (`name=iPhone …`)
# cold-boots Simulator.app + CoreSimulator just to compile — slow, and it
# clogs the machine. The generic destination compiles against the simulator
# SDK without booting anything. So: block the named-sim *build*, point at
# `make build`.
#
# Deliberately narrow — only the plain `build` action is blocked:
#   - `test` / `test-without-building` / `-only-testing`  → tests need a sim, allowed.
#   - `build-for-testing`                                 → allowed (make test boots explicitly).
#   - generic/platform=iOS Simulator                      → no name=, never matches.
#   - `make build` / `make test`                          → no xcodebuild+name in the string.
set -uo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')

emit() { # emit <decision> <reason>
  jq -nc --arg d "$1" --arg r "$2" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  exit 0
}

# Not an xcodebuild call → nothing to do.
printf '%s' "$cmd" | grep -q 'xcodebuild' || exit 0

# Any test-shaped invocation legitimately needs a simulator → allow.
printf '%s' "$cmd" | grep -Eq 'build-for-testing|test-without-building|-only-testing|[[:space:]]test([[:space:]]|$)' && exit 0

# A plain build that targets a concrete simulator (name= + iOS Simulator) is the
# exact pattern that needlessly boots a device. Block it.
if printf '%s' "$cmd" | grep -q 'iOS Simulator' && printf '%s' "$cmd" | grep -q 'name='; then
  emit deny "This plain 'xcodebuild build' targets a concrete simulator (name=…), which cold-boots that device just to compile and clogs the machine. For a compile check run 'make build' (xcodebuild build against generic/platform=iOS Simulator — boots NO simulator). Only use a named destination when you actually need to run tests (make test / make unit-test). See DPMSwift/AGENTS.md → Build & test."
fi

exit 0
