---
name: audit-contract
description: Verify or regenerate a DPM contract doc against the live Firebase project and current source — DPMv4/docs/CONTRACT.md (v4, database dpm-v4) by default, or the legacy docs/CONTRACT.md. Use to check for drift — deployed functions vs documented, new model fields, changed rules — or after backend deploys.
---

# audit-contract

Contracts drift as code ships. Source of truth = code; live backend = verification. Reconcile
both. Audit v4 unless the user names the legacy contract.

| | v4 (default) | Legacy |
|---|---|---|
| Contract | `DPMv4/docs/CONTRACT.md` + its typed form `DPMv4/functions/src/schema.ts` | `docs/CONTRACT.md` |
| Functions | codebase `dpm-v4`: exports of `DPMv4/functions/src/index.ts` | `DPM_cloud_functions/src/` |
| Database | `dpm-v4` | `(default)` |
| Rules | `DPMv4/firebase/firestore.rules` | `firebase/firestore_security_rules.rules` |
| Indexes | `DPMv4/firebase/firestore.indexes.json` | `firebase/firestore.indexes.json` |
| Models | `DPMv4/ios/DPMv4Client/Sources/DPMv4Core/Models/` | the four files in CONTRACT §0 |

## Steps

1. **Deployed functions (authoritative):** `firebase functions:list --project dopaminingswift`.
   Diff names/regions/triggers against the contract's callables and triggers (§4–5 in both).
   Flag deployed-but-undocumented and documented-but-undeployed.
2. **Indexes:** `firebase firestore:indexes --database <database> --project dopaminingswift` →
   the contract's index table (v4 §7) or queried fields (legacy §2).
3. **Rules:** re-read the rules file against the ownership table (§6 in both).
4. **Models:** diff the model files (and, for v4, `schema.ts`) against the contract's field
   tables → update the tables and the divergence flags (legacy §8).
5. **Live doc shape (only the MCP/Admin SDK can do this, not the CLI):** if the Firebase MCP is
   connected, sample one `users/{uid}` from the target database (v4: plus one `days/{yyyy-MM-dd}`;
   legacy: plus one `challenges/{id}`) to catch fields code added but the doc/models missed.
   Otherwise note it as unverified.
6. **Write back:** update the tables and flags, and the verification line (v4: the `Status:` line;
   legacy: "Verified … on <date>"). Keep it terse.

## Don't

- Don't treat a drift flag as a confirmed bug — verify (a scan may miss an aliased name) before
  "fixing".
- Callables stay pinned to `us-central1`.
