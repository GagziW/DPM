# Firebase layout (DPM)

Project: **`dopaminingswift`**. One canonical config at the repo root; everything else is
emulator/test-only. After the June 2026 consolidation there are no duplicate deploy configs.

## What gets deployed (the canonical set)

| Concern | File | Notes |
|---|---|---|
| Deploy config | `firebase.json` (repo root) | the only deploy config |
| Project alias | `.firebaserc` (repo root) | `default → dopaminingswift` |
| Security rules | `firebase/firestore_security_rules.rules` | the ONLY deployed ruleset |
| Indexes | `firebase/firestore.indexes.json` | 29 indexes (union, reconciled) |
| Functions | `DPM_cloud_functions/` | `firebase.json` → `functions.source` |

**Deploy from the repo root:**

```
firebase deploy                       # rules + indexes + functions
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only functions       # or: npm --prefix DPM_cloud_functions run deploy
```

`DPM_cloud_functions`'s own `deploy`/`serve` scripts point back at the root config via
`--config ../firebase.json --project dopaminingswift`, so they stay in sync.

## NOT deployed — emulator / test only

- `DPMSwift/firebase.emulator.json` — iOS emulator stack (open rules for tests). Its `indexes`
  now points at the canonical `../firebase/firestore.indexes.json` (no separate copy).
- `DPMSwift/firestore.emulator.rules` — OPEN rules, "NEVER DEPLOY".
- `DPMSwift/rules-tests/` — Firestore rules unit tests (`dummy.rules` + its own `firebase.json`).

## Admin / ops

- `DPM_admin_board/` — admin web app **and** `admin-cli/` (Admin-SDK scripts, formerly the
  separate `firebase-admin` repo). One repo, one `.env.local`, one credential
  (`op://DPM/FirebaseAdmin/ServiceAccountJson`). Run scripts with the env injected, e.g.
  `op run --env-file=.env.local.tpl -- npm run admin`.

## Removed in consolidation

- `firebase/firebase.json` + `firebase/.firebaserc` — duplicate deploy config (root is canonical).
- `DPMSwift/firebase.json` — stale (pointed at old `../cloud-functions` + a missing
  `firestore.rules`; carried an orphaned hosting block whose `public` dir didn't exist).
- `DPMSwift/firestore.indexes.json` — duplicate that had drifted from prod.
- `firebase-admin/` repo — merged into `DPM_admin_board/admin-cli/`.

## ⚠ Action needed

- **Deploy the reconciled indexes:** 10 composite indexes the app uses were missing from prod
  (`challenges`, `archivedChallenges`, `competitions`, `challengeGroups`, `liveActivities`).
  Run `firebase deploy --only firestore:indexes` and let them build.
- **Commit per-repo before re-cloning/renaming.** Uncommitted working-tree edits are lost when a
  repo is re-cloned (this happened to the website→`DPM.org` rename). Commit code + `.tpl` files in
  each product repo, and ensure each repo's `.gitignore` keeps `!.env.local.tpl` so templates persist.
