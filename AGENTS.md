# Dopamining (DPM)

iOS-first monorepo. All clients share one Firebase project (`dopaminingswift`) and one set of UIDs.

## DPMv4 — where all new work goes

**`DPMv4/`** (GitHub `GagziW/DpmSwift`) is the product since 2026-10-10: every new feature, backend change and cloud function lands here. Read `DPMv4/AGENTS.md` and `DPMv4/docs/PLAN.md` first.

- `DPMv4/app/` — the iOS app, 2.3.0 onward (imported from `DopaminingSwift` at `e31cbfe6`). Build, test and conventions: `DPMv4/app/AGENTS.md`.
- `DPMv4/functions/` — the backend: Functions codebase `dpm-v4` on Firestore database `dpm-v4`. Run, test, deploy, secrets, ops jobs and migration: `DPMv4/README.md`.
- `DPMv4/firebase/` — rules + indexes of `dpm-v4`; `DPMv4/firebase.json` is the v4 deploy config.
- `DPMv4/ios/DPMv4Client/` — the Swift data layer the app links (models, policy mirrors, callables).
- `DPMv4/docs/` — `PLAN` (design, cutover), `CONTRACT` (the seams), `DECISIONS`, `MIGRATION`; `DPMv4/fixtures/` pins the numbers Swift and TypeScript share.

Satellites on `dpm-v4` (PLAN §8.1), each its own repo:

- **`DPM.org/`** — the website (Next.js + Stripe): landing, `/join/<code>` bridge, subscription (`billing`), `/profile`, `/dashboard`. Read-only on Firestore; work on `staging` (push = staging deploy), production is `main`. `DPM.org/AGENTS.md`.
- **`DPM_admin_board/`** — the ops board: support actions as v4 ops jobs (`config/jobs/runs`). Its `admin-cli/` and old `scripts/` are retired legacy. `DPM_admin_board/AGENTS.md`.

What the player is doing right now: `users/{uid}.challenge` (embedded) plus one `users/{uid}/days/{yyyy-MM-dd}` record per day, in database `dpm-v4`.

## Legacy — retired archive

All users are on v4. Legacy functions and client database access were retired on 2026-10-26.
Keep archived source and data for support; implement production fixes in `DPMv4/`.
Retirement evidence, backup and retention: `DPMv4/docs/MIGRATION.md` §6.

- **`DopaminingSwift/`** — archived 2.2.x app; current iOS work belongs in `DPMv4/app/`.
- **`DPM_cloud_functions/`** — retired backend source. Its deploy script is disabled. Root `firebase.json` only maintains the `(default)` client access freeze; current deploys use `DPMv4/firebase.json` (`FIREBASE.md`).
- **`docs/CONTRACT.md`** — historical `(default)` contract, with the current access freeze documented.
- **`DPMAndroid/`** — parked legacy client; current Android work belongs in `DPMv4/android/`.
- `DopaminingSwift-main/`, `DPMdocs/` — second clones of old branches; use the real checkouts above for historical reference.

## Working rules

- **iOS-first.** Implement and verify in `DPMv4/app` first; other clients follow and never block it.
- **Seams cross every client.** Changing a Firestore field, callable, trigger, rule or index changes all clients at once; a field change goes through the `add-shared-field` skill. v4 seams update `DPMv4/docs/CONTRACT.md` in the same commit (`DPMv4/AGENTS.md` says what moves with it).
- **Function changes are deploys.** v4 deploys from `DPMv4/` and never touches `(default)` or the old functions. Callables stay in **`us-central1`**.
- **Admin SDK in functions bypasses rules.** Be deliberate about writes.
- **Secrets:** keep secret files machine-local and gitignored. Provision them explicitly with `./op-sync.sh` (fills `DPMv4/app` and `DopaminingSwift`); agents do not access password-manager tooling by default.
- **Editor:** always use `vim`, never `nano`. When a command needs an editor, set it inline: `EDITOR=vim VISUAL=vim <cmd>` (e.g. `EDITOR=vim git commit`, `EDITOR=vim crontab -e`).

## Deeper context (read on demand)

- **iOS publishing:** `DPMv4/app/fastlane/WORKFLOW.md` — read before `fstln beta`, `fstln release`, changing version/build counters, or recovering an upload/submission. The archived 2.2.x workflow shares the same App Store record; use the v4 publishing workflow.
- Historical source: `DopaminingSwift/AGENTS.md` (iOS), `DPM_cloud_functions/AGENTS.md` (old backend, Stripe, economy flags).
- `docs/year-economy-simulator.html` — interactive year-game economy simulator.

## Agent skills

### Issue tracker

Product issues, specs, and cross-platform tickets live in `GagziW/DPM` GitHub Issues; implementation PRs remain in the affected platform repositories. See `docs/agents/issue-tracker.md`.

### Triage labels

Triage uses the canonical `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, and `wontfix` labels. See `docs/agents/triage-labels.md`.

### Domain docs

DPM uses a multi-context domain model with a root context map, platform glossaries, and system-wide or platform-specific ADRs. See `docs/agents/domain.md`.
