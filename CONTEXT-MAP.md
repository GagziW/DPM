# Context Map

## Contexts

- [iOS Product](./DopaminingSwift/CONTEXT.md) — defines the primary workout experience and product language
- [Shared Backend](./DPM_cloud_functions/CONTEXT.md) — owns shared Firebase behavior and callable contracts

Context glossary files are created when their first domain term is resolved.

## Relationships

- **iOS Product → Android**: iOS originates product behavior; Android follows it without blocking iOS.
- **Clients ↔ Shared Backend**: iOS, Android, and Web share Firebase identities, Firestore paths, and callable contracts.
- **Cross-platform Documentation → All contexts**: documents the seams shared across contexts.
