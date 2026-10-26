# Firebase layout (DPM)

Project: **`dopaminingswift`**. Production uses the v4 backend and database.

| Purpose | Deploy config | Scope |
|---|---|---|
| Production | `DPMv4/firebase.json` | Functions codebase `dpm-v4`; rules and indexes for database `dpm-v4` |
| Legacy access freeze | root `firebase.json` | Only `(default)` rules from `DPMv4/firebase/legacy.readonly.rules` |

For production changes, read `DPMv4/README.md` and deploy from `DPMv4/`.
The root config has no functions or index deployment. `DPM_cloud_functions` is archived and its
`npm run deploy` exits with a retirement notice.

Legacy client access permits only public document get of `appConfig/features` so old builds can
show the update gate. All other client reads and writes are denied. Admin SDK support access remains.
The historical `firebase/firestore_security_rules.rules` and indexes are retained as reference.

Retirement evidence, the export location and retention requirements are in
`DPMv4/docs/MIGRATION.md` §6. Preserve the default database and export until that retention window
ends; cleanup requires a second export and an explicit data-deletion task.

The website is `DPM.org/` (App Hosting; `staging` and `main` production).
The ops board is `DPM_admin_board/`; current support actions use v4 ops jobs. Its old admin CLI
and scripts are retired. Emulator configs in archived clients remain test-only.
