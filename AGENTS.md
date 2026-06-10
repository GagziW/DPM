# Dopamining (DPM)

iOS-first habit/stake monorepo. All clients share one Firebase project (`dopaminingswift`).

## Platforms (priority order)

- **`DPMSwift/`** — iOS, public, production. **The priority.** Product decisions originate here.
- **`cloud-functions/`** — Firebase Functions (TypeScript). Shared backend for iOS, Android, website.
- **`website/`** — Next.js + Stripe. Marketing + challenge creation flow.
- **`DPMAndroid/`** — Kotlin, WIP, not public. Follows iOS; never block iOS for parity.
- **`admin-board/`, `firebase-admin/`** — internal ops.

## Cross-platform contract

Source of truth for "what the user is doing right now":

```
users/{uid}.activeChallenge  →  challenges/{id}
```

Same UID, same Firestore paths, same callables across all clients. Changing a Firestore field, function signature, or security rule changes all three at once — check siblings before merging.

## Working rules

- **iOS-first.** Implement and verify on iOS before porting to Android.
- **Firestore parity.** New field on `Challenge` / `User` → update iOS model + cloud functions + `website/lib/types/` + Android model + `docs/CONTRACT.md` (the `add-shared-field` skill walks all of it).
- **Function changes are deploys.** Stripe callables are pinned to **`us-central1`**.
- **Security rules:** `firebase/firestore_security_rules.rules` is the active file (per `firebase/firebase.json`) — not `firestore.rules`.
- **Admin SDK in functions bypasses rules.** Be deliberate about writes.
- **Editor:** always use `vim`, never `nano`. When a command needs an editor, set it inline: `EDITOR=vim VISUAL=vim <cmd>` (e.g. `EDITOR=vim git commit`, `EDITOR=vim crontab -e`).

## Deeper context (read on demand)

- `DPMSwift/AGENTS.md` — iOS specifics (build, patterns, conventions)
- `cloud-functions/AGENTS.md` — backend specifics (deploy, callables, Stripe)
- `docs/CONTRACT.md` — **the cross-platform contract, keyed by seam**: shared Firestore fields, callables, triggers, rules, and where each lives across iOS/web/functions/Android. Read this before changing any shared field, function signature, or rule. Includes known divergences + drift flags. **Upkeep obligation:** after changing any seam (field, callable, trigger, rule, index), update the affected CONTRACT.md table in the same piece of work and push it (`docs/` is its own repo). To reconcile wholesale, run the `audit-contract` skill.
- `docs/` — HTML architecture docs (open `docs/overview.html`)
