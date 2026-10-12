# Dopamining (DPM)

iOS-first monorepo. All clients share one Firebase project (`dopaminingswift`) and one set of UIDs.

## DPMv4 — where all new work goes

**`DPMv4/`** (GitHub `GagziW/DpmSwift`) is the product since 2026-10-10: every new feature, backend change and cloud function lands here. Read `DPMv4/AGENTS.md` and `DPMv4/docs/PLAN.md` first.

- `DPMv4/app/` — the iOS app, 2.3.0 onward (imported from `DopaminingSwift` at `e31cbfe6`). Build, test and conventions: `DPMv4/app/AGENTS.md`.
- `DPMv4/functions/` — the backend: Functions codebase `dpm-v4` on Firestore database `dpm-v4`. Run, test, deploy, secrets, ops jobs and migration: `DPMv4/README.md`.
- `DPMv4/firebase/` — rules + indexes of `dpm-v4`; `DPMv4/firebase.json` is the v4 deploy config.
- `DPMv4/ios/DPMv4Client/` — the Swift data layer the app links (models, policy mirrors, callables).
- `DPMv4/docs/` — `PLAN` (design, cutover), `CONTRACT` (the seams), `DECISIONS`, `MIGRATION`; `DPMv4/fixtures/` pins the numbers Swift and TypeScript share.

What the player is doing right now: `users/{uid}.challenge` (embedded) plus one `users/{uid}/days/{yyyy-MM-dd}` record per day, in database `dpm-v4`.

## Legacy — keep it running, fix only

Everything outside `DPMv4/` is deprecated. It serves the live 2.2.x App Store app and the `(default)` database until the v4 cutover (`DPMv4/docs/PLAN.md` §8), then retires. Keep it working so a production break can still be fixed there; build nothing new on it.

- **`DopaminingSwift/`** — the 2.2.x App Store app. Bug fixes only, and every fix also lands in `DPMv4/app/`.
- **`DPM_cloud_functions/`** — the old backend (≈80 functions on `(default)`). Bug fixes only. Deploys from the root `firebase.json`; its rules file is `firebase/firestore_security_rules.rules` (`FIREBASE.md`).
- **`docs/CONTRACT.md`** — the old contract: `users/{uid}.activeChallenge → challenges/{id}` on `(default)`. A legacy seam fix updates it in the same piece of work and pushes it (`docs/` is its own repo); `audit-contract` reconciles it wholesale.
- **`DPM.org/`** (Next.js + Stripe), **`DPM_admin_board/`** (ops web app + `admin-cli/`), **`DPMAndroid/`** (Kotlin, parked) — still on `(default)`. PLAN §8.1 narrows the website and repoints it and the admin board at `dpm-v4`; Android stays parked.
- `DopaminingSwift-main/`, `DPMdocs/` — second clones of old branches; edit the real checkouts above.

## Working rules

- **iOS-first.** Implement and verify in `DPMv4/app` first; other clients follow and never block it.
- **Seams cross every client.** Changing a Firestore field, callable, trigger, rule or index changes all clients at once; a field change goes through the `add-shared-field` skill. v4 seams update `DPMv4/docs/CONTRACT.md` in the same commit (`DPMv4/AGENTS.md` says what moves with it); legacy seams update `docs/CONTRACT.md`.
- **Function changes are deploys.** v4 deploys from `DPMv4/` and never touches `(default)` or the old functions. Callables stay in **`us-central1`** on both backends.
- **Admin SDK in functions bypasses rules.** Be deliberate about writes.
- **Secrets:** keep secret files machine-local and gitignored. Provision them explicitly with `./op-sync.sh` (fills `DPMv4/app` and `DopaminingSwift`); agents do not access password-manager tooling by default.
- **Editor:** always use `vim`, never `nano`. When a command needs an editor, set it inline: `EDITOR=vim VISUAL=vim <cmd>` (e.g. `EDITOR=vim git commit`, `EDITOR=vim crontab -e`).

## Deeper context (read on demand)

- **iOS publishing:** `DPMv4/app/fastlane/WORKFLOW.md` — read before `fstln beta`, `fstln release`, changing version/build counters, or recovering an upload/submission. The legacy 2.2.x train uses `DopaminingSwift/fastlane/WORKFLOW.md`; both upload to the same App Store record.
- Legacy fixes: `DopaminingSwift/AGENTS.md` (iOS), `DPM_cloud_functions/AGENTS.md` (old backend, Stripe, economy flags).
- `docs/year-economy-simulator.html` — interactive year-game economy simulator.

## Agent skills

### Issue tracker

Product issues, specs, and cross-platform tickets live in `GagziW/DPM` GitHub Issues; implementation PRs remain in the affected platform repositories. See `docs/agents/issue-tracker.md`.

### Triage labels

Triage uses the canonical `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, and `wontfix` labels. See `docs/agents/triage-labels.md`.

### Domain docs

DPM uses a multi-context domain model with a root context map, platform glossaries, and system-wide or platform-specific ADRs. See `docs/agents/domain.md`.
