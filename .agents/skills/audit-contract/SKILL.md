---
name: audit-contract
description: Verify or regenerate docs/CONTRACT.md against the live Firebase project and current source. Use to check the cross-platform contract for drift — deployed functions vs documented, new model fields, changed rules — or after backend deploys.
---

# audit-contract

`docs/CONTRACT.md` drifts as code ships. Source of truth = code; live backend = verification. Reconcile both.

## Steps

1. **Deployed functions (authoritative):** `firebase functions:list`. Diff names/regions/triggers vs CONTRACT §4–5. Flag deployed-but-undocumented and documented-but-undeployed (e.g. the §8 `exchangeAppleAuthCode` flag).
2. **Indexes:** `firebase firestore:indexes` → confirm §2's queried fields.
3. **Rules:** re-read `firebase/firestore_security_rules.rules` vs §6 (ownership, server-only, permissive collections).
4. **Models:** re-scan the four files in CONTRACT §0; diff field sets across iOS/web/Android → update §2–3 + §8 divergences.
5. **Live doc shape (only the MCP/Admin SDK can do this, not the CLI):** if the Firebase MCP is connected, sample one `challenges/{id}` + one `users/{uid}` doc to catch fields code added but the doc/models missed. Otherwise note it as unverified.
6. **Write back:** update CONTRACT.md tables + flags, bump the "Verified … on <date>" line. Keep it terse.

## Don't
- Don't treat a §8 flag as a confirmed bug — verify (a scan may miss an aliased name) before "fixing".
- Stripe callables stay pinned to `us-central1`.
