---
name: deploy-functions
description: Guided pre-deploy checklist for cloud-functions (Firebase Functions). Use when deploying or about to deploy the backend — "function changes are deploys" and there is no CI gate, so this walks the build, contract, and blast-radius checks before shipping to prod. Stripe callables are pinned to us-central1.
disable-model-invocation: true
---

# deploy-functions

`cloud-functions/` deploys straight to prod and is shared by iOS, web, and Android. There is
no CI and no test suite — this checklist is the gate. Run it from the monorepo root. Stop and
report if any step fails; don't deploy past a red step.

## 1. Know what's changing

- `git -C cloud-functions diff --stat` (and full `diff` for the hot files) — read it.
- For each changed `export const … = onCall/onRequest/onDocument…/onSchedule`, note **which
  clients call it** (iOS, web, Android) so you can state the blast radius. Cross-check names
  and regions against `docs/CONTRACT.md` §4–5.
- If a Stripe / payments / webhook function changed, run the `stripe-payments-reviewer`
  subagent first.

## 2. Build (must be clean)

```bash
npm --prefix cloud-functions run build      # tsc -p tsconfig.json; no lint exists
```

A type error here is a guaranteed broken deploy. Fix before proceeding.

## 3. Contract & parity

- New/renamed/removed field on `Challenge` or `User`? This is a cross-platform change — use
  the `add-shared-field` skill, don't ship the function alone.
- Changed a callable signature/name/region? Update `docs/CONTRACT.md` and confirm iOS/web/
  Android callers match. **Stripe callables stay pinned to `us-central1`.**
- Admin SDK bypasses security rules — confirm any new write only touches intended fields/docs.

## 4. Deploy

Prefer deploying only what changed to limit blast radius:

```bash
firebase deploy --only functions:NAME_A,functions:NAME_B    # targeted
# or, full functions deploy (slower, redeploys everything):
firebase deploy --only functions
```

If env/secrets changed, set them (`firebase functions:config` / secrets) before deploying.

## 5. Verify after deploy

- `firebase functions:list` — confirm the function is live with the expected region/trigger.
- `firebase functions:log --only NAME` (or the Firebase MCP `functions_get_logs`) — watch the
  first real invocations for cold-start errors.
- Schedulers: confirm the schedule registered. Webhooks: confirm Stripe is pointed at the live
  URL and the signing secret matches.

## 6. After a deploy of any size

Consider running the `audit-contract` skill to reconcile `docs/CONTRACT.md` with the now-live
backend.

## Don't

- Don't deploy on a failing build or an open contract divergence.
- Don't move a Stripe callable off `us-central1`.
- Don't edit `.env`/secrets as part of this (the PreToolUse guard blocks it — handle manually).
