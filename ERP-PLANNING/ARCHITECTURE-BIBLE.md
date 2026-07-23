# Architecture Bible — Mandatory Read

This file summarizes the rules every planning and implementation prompt must preserve.

## Architecture style

- Modular, domain-aligned services with explicit ownership.
- Database per service for backend bounded contexts.
- REST/OpenAPI at the public boundary.
- gRPC for selected synchronous internal calls.
- NATS JetStream for durable domain events.
- Transactional outbox/inbox and idempotent consumers.
- BullMQ for background jobs such as PDFs, exports, notifications, and reconciliation.
- Private S3-compatible object storage with short-lived signed URLs.

## Client architecture

- Flutter feature-first clean architecture.
- Domain code does not import Flutter, Dio, Drift, Firebase, or presentation code.
- Riverpod provides dependency injection and state management.
- Tenant/event providers are context-keyed and disposed on context switch.
- Native secure storage and web memory/cookie strategy are platform-specific.
- Drift native SQLite on mobile; WASM-backed storage on web where supported.

## Service ownership

- Identity service: users, authentication identities, sessions.
- Tenant service: organizations, memberships, roles, permissions.
- Event service: events and lifecycle.
- Volunteer service: volunteer records and assignments.
- Donor/contributor service: contributor identities and deduplication.
- Contribution service: bills, collections, contributions, receipts.
- Payment service: payment provider orchestration and webhook verification.
- Finance service: accounts, expenses, transfers, ledger, reconciliation.
- Document service: official PDFs and private document metadata.
- Notification service: WhatsApp, email, SMS, push, and delivery records.
- Reporting service: read models, dashboards, exports, public transparency.
- Audit service: append-only security and business audit evidence.

## Financial correctness

- Use database transactions for local aggregate invariants.
- Use sagas/outbox events across services.
- Never rely on distributed database transactions.
- Unique business keys enforce numbering and idempotency.
- Reversals, refunds, cancellations, and replacements preserve the original record.
- Ledger entries are append-only and balanced.

## Multi-tenancy

- `organizationId` is derived from authenticated membership, not trusted from the UI.
- Event-scoped records include `eventId` where applicable.
- Cache keys, storage paths, events, queues, reports, and logs are tenant-aware.
- Cross-tenant access returns a safe denial without revealing existence.
- Automated negative tests prove isolation.

## Security

- Short-lived access JWTs and rotated refresh sessions.
- Passwords use Argon2id.
- OTPs and refresh tokens are stored as hashes.
- Secrets live in a managed secret store.
- Logs redact tokens, OTPs, payment signatures, sensitive documents, and private contributor data.
- Production access is least-privileged, MFA-protected, time-bound, and audited.

## Delivery

- Contract-first APIs and events.
- Backward-compatible migrations.
- CI validates format, lint, tests, contracts, scans, migrations, and builds.
- Production rollout uses canary or blue/green where appropriate.
- Rollback is planned and tested.
