# Flutter Architecture Reference

## Structure

Use a Dart Pub Workspace with `apps/` and reusable `packages/`. Melos is a task runner, not an alternative dependency resolver.

## Feature dependency direction

```text
presentation → application → domain
                    ↑
                  data
```

- Domain is framework-independent.
- Data implements domain repositories.
- Presentation never calls Dio or Drift directly.
- Riverpod wires dependencies and state.
- `go_router` handles typed, guarded navigation.
- Official documents remain backend-owned.

## Platform differences

- Mobile tokens: Keychain/Keystore-backed secure storage.
- Web access token: memory preferred; refresh credential via secure HttpOnly cookie when backend supports it.
- Mobile database: Drift native SQLite.
- Web database: Drift WASM with tested persistence fallback.

## Tenant switching

Use a context version, cancel old requests, dispose context-scoped providers, namespace persistent data, reload permissions, and reject late responses from the prior context.
