#!/usr/bin/env bash
# PreToolUse hook (Edit|Write|MultiEdit): protect secrets and the *active* security rules.
#
#  - Block edits to any .env* file outright (Stripe keys, service-account creds live there).
#  - Ask for confirmation before editing firebase/firestore_security_rules.rules — the LIVE
#    rules file per firebase.json, governing all three clients (admin SDK bypasses it).
#  - Ask before editing firestore.rules, which is the DECOY file (easy to edit by mistake).
set -uo pipefail

input=$(cat)
file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // ""')
base=$(basename "$file_path")

emit() { # emit <decision> <reason>
  jq -nc --arg d "$1" --arg r "$2" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:$d,permissionDecisionReason:$r}}'
  exit 0
}

case "$base" in
  .env|.env.*|*.env|.env.local|.env.*.local)
    emit deny "Editing $base is blocked: it holds secrets (Stripe keys, service-account creds). Change it manually outside Claude." ;;
esac

case "$file_path" in
  */firebase/firestore_security_rules.rules)
    emit ask "This is the ACTIVE Firestore rules file (per firebase.json). It governs iOS + web + Android at once, and the Admin SDK in functions bypasses it. Confirm before editing." ;;
  */firestore.rules)
    emit ask "Heads up: firestore.rules is the DECOY — firebase/firestore_security_rules.rules is the live file per firebase.json. Confirm you really mean to edit this one." ;;
esac

exit 0
