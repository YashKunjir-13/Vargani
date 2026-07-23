# Testing Strategy Reference

## Test pyramid

- Domain unit tests for calculations, state machines, and policies
- Service integration tests with real PostgreSQL/Redis/NATS using containers
- Contract tests for REST, events, and gRPC
- API E2E for protected workflows and negative authorization cases
- Flutter unit, widget, golden, and integration tests
- Browser E2E for critical public and admin flows
- k6 load, spike, and soak tests
- Security, resilience, backup/restore, and message-replay tests

## Financial critical paths

Target the strongest branch coverage for money calculations, idempotency, tenant isolation, payment verification, receipt numbering, ledger balancing, and audit immutability.

## Evidence

CI retains test reports, traces, screenshots/videos on failure, coverage, contract results, migration validation, performance summaries, and security outputs.
