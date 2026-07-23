# System Architecture Reference

## Runtime view

```text
Flutter Apps / Web
        ↓ HTTPS
API Gateway / BFF
        ↓ REST or gRPC
Domain Services
        ↔ NATS JetStream
        ↔ Redis / BullMQ
        ↔ Service-owned PostgreSQL
        ↔ Private Object Storage
        ↔ External Providers
```

## Key rules

- Public traffic enters through a controlled gateway.
- Each service owns its data and migrations.
- Cross-service reads use APIs, events, or reporting projections.
- Financial commands use idempotency keys.
- Domain events use outbox/inbox reliability.
- Long-running work uses jobs, not request threads.
- Reporting uses read models rather than synchronous fan-out across every service.

## Architecture review questions

- Who owns this aggregate?
- Which invariant must be atomic?
- What happens when a dependency is unavailable?
- Can the operation be safely retried?
- How is tenant context validated?
- What evidence proves the result?
