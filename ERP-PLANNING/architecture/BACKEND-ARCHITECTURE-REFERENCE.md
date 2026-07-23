# Backend Architecture Reference

## Service internals

```text
Controller / Message Handler
        ↓
Application Use Case
        ↓
Domain Aggregate / Policy
        ↓
Repository Port
        ↓
Prisma / Provider Adapter
```

## Rules

- Controllers validate transport input and delegate.
- Application services orchestrate transactions and domain policies.
- Domain code contains business invariants.
- Repositories enforce tenant scope and persistence concerns.
- Provider-specific logic remains in adapters.
- APIs use DTOs; domain entities are not serialized directly.
- Cross-service database access is prohibited.
