# Database Engineering Reference

## Standards

- PostgreSQL with Prisma for service-owned operational data.
- UUID identifiers unless an approved ADR states otherwise.
- Integer paise for money and explicit currency.
- UTC timestamps; local display conversion occurs at the edge.
- Soft deletion only where business history permits it.
- Append-only models for ledger and audit evidence.
- Explicit unique constraints for idempotency and numbering.
- Indexes are justified by query patterns and verified with execution plans.

## Migration safety

- Expand-and-contract for breaking schema changes.
- Backfills are restartable and observable.
- Destructive changes require backup, rollback, and approval.
- Migrations run as controlled release jobs, not arbitrary application startup side effects.
