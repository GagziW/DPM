#!/usr/bin/env bash
# PostToolUse hook (Edit|Write|MultiEdit): type-check cloud-functions after any edit
# under cloud-functions/src.
#
# Why: cloud-functions has no lint and no tests, and per AGENTS.md "function changes are
# deploys" (straight to prod, shared by iOS + web + Android). The tsc compile is the only
# automated gate. Exit code 2 feeds stderr back to Claude so it fixes the error in-loop.
set -uo pipefail

root="${CLAUDE_PROJECT_DIR:-/Users/gagzi/Code/DPM}"
input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')

# Only act on edits inside the functions source tree.
case "$file_path" in
  *cloud-functions/src/*) ;;
  *) exit 0 ;;
esac

fn_dir="$root/cloud-functions"
tsc="$fn_dir/node_modules/.bin/tsc"
[ -x "$tsc" ] || tsc="npx tsc"

# --noEmit is safe: tsconfig.json has no composite/incremental.
out=$(cd "$fn_dir" && $tsc --noEmit -p tsconfig.json 2>&1)
status=$?

if [ "$status" -ne 0 ]; then
  echo "cloud-functions type-check FAILED after editing ${file_path#"$root/"}:" >&2
  echo "$out" >&2
  exit 2
fi

echo "cloud-functions type-check passed."
exit 0
