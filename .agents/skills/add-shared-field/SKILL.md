---
name: add-shared-field
description: Add, rename, or remove a shared Firestore field across DPM — in v4 (database dpm-v4, the default) or, for a legacy fix, on users/{uid} or challenges/{id} in (default). Use whenever a document field changes; it crosses Swift, TypeScript, and the database, so no single find-references catches it.
---

# add-shared-field

A Firestore field is a cross-language contract: changing it in one place silently desyncs the
rest. Use the exact same camelCase wire name everywhere, then touch every applicable site below.

## v4 (`dpm-v4`) — all new work

Read `DPMv4/docs/CONTRACT.md` §3 (collections) and §6 (rules ownership) first.

1. **Contract** — `DPMv4/docs/CONTRACT.md` and its typed form `DPMv4/functions/src/schema.ts`, in
   the same commit.
2. **Functions** — every command, trigger and job under `DPMv4/functions/src/` that reads or
   writes it (document paths come from `core/docs.ts`).
3. **Numbers** — a field carrying economy or day-close math gets a case in `DPMv4/fixtures/` (and
   its copy in `DPMv4/ios/DPMv4Client/Tests/Fixtures/`; a test catches drift) plus the Swift policy
   mirror in `DPMv4/ios/DPMv4Client/Sources/DPMv4Core/Policy/`.
4. **Swift model** — `DPMv4/ios/DPMv4Client/Sources/DPMv4Core/Models/`. If the app's views need
   it, carry it through `DPMv4/app/Dopamining/Services/V4/V4LegacyProjection.swift`.
5. **Rules** — `DPMv4/firebase/firestore.rules` only if the owner may write it (CONTRACT §6), with
   a case in `DPMv4/functions/test/rules/`.
6. **Indexes** — `DPMv4/firebase/firestore.indexes.json` + CONTRACT §7 only if you'll query or
   order by it.
7. **Migration** — a field with a `(default)` source gets its mapping in
   `DPMv4/functions/src/migration/` and `DPMv4/docs/MIGRATION.md`.
8. **Website** — `DPM.org` only for the fields it reads from `dpm-v4` (entitlement,
   `stats/public`; PLAN §8.1).

Verify: `npm --prefix DPMv4/functions test` (+ `run test:rules` for a rules change);
`DPMV4_CORE_ONLY=1 swift test --package-path DPMv4/ios/DPMv4Client`; `make -C DPMv4/app build`.

## Legacy (`(default)`) — bug fixes only

Read `docs/CONTRACT.md` §2–3 first, then:

1. **iOS** — `DopaminingSwift/Dopamining/Models/DynamicModels/{Challenge,User}.swift`: property +
   Codable key.
2. **Web** — `DPM.org/lib/types/{challenge,user}.ts`: field + any converter in
   `DPM.org/lib/firebase/converter.ts`.
3. **Android** — `DPMAndroid/.../domain/model/{ChallengeModel,UserModel}.kt`: nullable field +
   default. (Parked — OK to defer, but record it.)
4. **Cloud functions** — `DPM_cloud_functions/src/{index,stripe}.ts`: any trigger/callable that
   reads or writes it (CONTRACT §4–5). New stat → check `globalStats` aggregators.
5. **Indexes** — `firebase/firestore.indexes.json` only if you'll query/order by it.
6. **Rules** — `firebase/firestore_security_rules.rules` only if it needs ownership/visibility
   beyond the collection default.
7. **Doc** — add/adjust the row in `docs/CONTRACT.md` and clear any related §8 flag.
8. **v4** — if v4 needs the same fix, run the v4 checklist too (and the migration mapping).

Verify: `make -C DopaminingSwift build`; `cd DPM.org && npm test`;
`npm --prefix DPM_cloud_functions test`.

## Wire format (both)

- Dates → Firestore `Timestamp`. Enum values are **lowercase strings**. Day keys `"yyyy-MM-dd"`.
- Optional everywhere unless every existing doc is backfilled (in v4: or the migration writes
  it) — old docs won't have it.
