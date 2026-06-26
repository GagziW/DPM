---
name: add-shared-field
description: Add or rename a field on the shared Challenge or User model across every DPM platform (iOS, web, cloud functions, Android, rules, indexes). Use whenever a Firestore field on users/{uid} or challenges/{id} is added, renamed, or removed — it crosses Swift, TypeScript, Kotlin, and the database, so no single find-references catches it.
---

# add-shared-field

A Firestore field is a cross-language contract. Adding one in only one client silently desyncs the others. Read `docs/CONTRACT.md` §2–3 first to see current coverage, then touch every applicable site below.

## Checklist (use the exact same camelCase wire name everywhere)

1. **iOS** — `DPMSwift/Dopamining/Models/DynamicModels/{Challenge,User}.swift`: property + Codable key.
2. **Web** — `DPM.org/lib/types/{challenge,user}.ts`: field + any converter in `DPM.org/lib/firebase/converter.ts`.
3. **Android** — `DPMAndroid/.../domain/model/{ChallengeModel,UserModel}.kt`: nullable field + default. (WIP — OK to defer, but record it.)
4. **Cloud functions** — `cloud-functions/src/{index,stripe}.ts`: any trigger/callable that reads or writes it (CONTRACT §4–5). New stat → check `globalStats` aggregators.
5. **Indexes** — `firebase/firestore.indexes.json` only if you'll *query/order* by it.
6. **Rules** — `firebase/firestore_security_rules.rules` only if it needs ownership/visibility beyond the collection default.
7. **Doc** — add/adjust the row in `docs/CONTRACT.md` and clear any related §8 flag.

## Wire-format rules
- Dates → Firestore `Timestamp`. `status` values are **lowercase strings**. Maps keyed `"yyyy-MM-dd"`.
- Optional everywhere unless every existing doc is backfilled — old docs won't have it.

## Verify
- iOS builds; `cd DPM.org && npm test`; functions `cd cloud-functions && npm run build`.
- iOS-first: implement + verify on iOS before Android (never block iOS for parity).
