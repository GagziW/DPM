---
name: deploy-functions
description: Guided pre-deploy checklist for the Firebase backend — the v4 backend in DPMv4 (functions, rules, indexes of database dpm-v4) or a legacy fix to DPM_cloud_functions. Use when deploying or about to deploy; "function changes are deploys", so this walks the tests, contract, and blast-radius checks before shipping to prod. Callables are pinned to us-central1.
disable-model-invocation: true
---

# deploy-functions

Two backends share the `dopaminingswift` project; neither deploy touches the other.

- **v4** — `DPMv4/functions/` + `DPMv4/firebase/`: Functions codebase `dpm-v4`, database `dpm-v4`.
  All new work. Steps 1–6.
- **Legacy** — `DPM_cloud_functions/` + root `firebase/`: the `(default)` database, frozen for bug
  fixes. See "Legacy fix" at the end.

Run from the monorepo root. Stop and report if any step fails; don't deploy past a red step.

## 1. Know what's changing

- `git -C DPMv4 status` and `git -C DPMv4 diff --stat -- functions firebase` (DPMv4 is its own
  repo) — read the hot files.
- For each changed callable, trigger, schedule or HTTP function, note **which clients call it**
  (iOS app, website, admin) so you can state the blast radius. Cross-check names and regions
  against `DPMv4/docs/CONTRACT.md` §4–5.
- Stripe / billing / webhook change → run the `stripe-payments-reviewer` subagent first. Rules
  change → `firestore-rules-reviewer`.

## 2. Tests (must be green)

```bash
npm --prefix DPMv4/functions run lint           # tsc --noEmit
npm --prefix DPMv4/functions test               # policy fixtures, commands, triggers, notify, migration
npm --prefix DPMv4/functions run test:rules     # when firebase/firestore.rules changed (Firestore emulator)
npm --prefix DPMv4/functions run deploy:dry-run # CLI validation of the dpm-v4 codebase, changes nothing
```

## 3. Contract & parity

- A changed field, callable, trigger, rule or index updates `DPMv4/docs/CONTRACT.md` and
  `DPMv4/functions/src/schema.ts` in the same commit — use the `add-shared-field` skill. A changed
  number needs its fixture in `DPMv4/fixtures/` and the Swift mirror in `DPMv4/ios/DPMv4Client`.
- Callables stay in **`us-central1`**.
- A new `defineSecret` needs the secret in Secret Manager before the deploy (`DPMv4/README.md` →
  Secrets).
- Admin SDK bypasses security rules — confirm each new write touches only the intended docs, and
  that a balance never moves without its ledger entry.

## 4. Deploy

```bash
npm --prefix DPMv4/functions run deploy     # functions:dpm-v4 + firestore:dpm-v4 (rules, indexes)
# or only what changed:
firebase deploy --only functions:dpm-v4:NAME_A,functions:dpm-v4:NAME_B \
  --config DPMv4/firebase.json --project dopaminingswift
```

## 5. Verify after deploy

- `firebase functions:list --project dopaminingswift` — the function is live in `us-central1`.
- `firebase functions:log --only NAME` (or the Firebase MCP `functions_get_logs`) — watch the
  first real invocations for cold-start errors.
- Schedules (`tick`, `nightly`): confirm they registered. Webhook: confirm Stripe points at the
  v4 URL and the signing secret matches.

## 6. After a deploy of any size

Consider the `audit-contract` skill to reconcile `DPMv4/docs/CONTRACT.md` with the live backend.

## Legacy fix (`DPM_cloud_functions`, `(default)`)

Bug fixes only; port the fix to `DPMv4` when v4 has the same bug.

```bash
git -C DPM_cloud_functions diff --stat
npm --prefix DPM_cloud_functions test                                 # tsc + node:test
firebase deploy --only functions:NAME --project dopaminingswift       # root firebase.json → DPM_cloud_functions
```

Clients of the old callables: the 2.2.x app (`DopaminingSwift/Dopamining/Services/`), the website
(`DPM.org/lib/services/`), Android and the admin board. Update `docs/CONTRACT.md` for any seam the
fix changes.

## Don't

- Don't deploy on a red step or an open contract divergence.
- Don't move a callable off `us-central1`.
- Don't edit `.env`/secrets as part of this (the PreToolUse guard blocks it — handle manually).
