# Context Map

## Contexts

- [iOS Product (v4)](./DPMv4/app/CONTEXT.md) — defines the primary workout experience and product language
- v4 Backend — `DPMv4/functions/` on database `dpm-v4`; its seams are [DPMv4/docs/CONTRACT.md](./DPMv4/docs/CONTRACT.md)

Legacy, frozen until the v4 cutover (fixes only):

- [iOS Product (2.2.x)](./DopaminingSwift/CONTEXT.md)
- [Shared Backend (`(default)`)](./DPM_cloud_functions/CONTEXT.md) — the old Firebase behavior and callable contracts

Context glossary files are created when their first domain term is resolved.

## Relationships

- **iOS Product → Android**: iOS originates product behavior; Android follows it without blocking iOS, ignore Android for now.
- **Clients ↔ Backend**: every client shares one set of Firebase identities. The v4 app reads and writes only `dpm-v4`; the 2.2.x app, web, Android and the admin board still use `(default)` and its callables.
- **Cross-platform Documentation → All contexts**: `DPMv4/docs/` documents the v4 seams; `docs/` the legacy ones.
