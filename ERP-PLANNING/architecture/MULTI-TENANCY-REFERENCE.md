# Multi-Tenancy Reference

## Required controls

- Resolve organization from an authenticated active membership.
- Require event context only for event-scoped operations.
- Include tenant scope in every repository query and unique constraint where relevant.
- Namespace cache, object storage, jobs, messages, reports, and local client data.
- Verify tenant/event context again before applying asynchronous results.
- Test forged IDs, stale tokens, switched context, guessed file paths, and replayed messages.

## Forbidden patterns

- Trusting `organizationId` supplied by the client without membership validation
- Global cache keys for tenant-owned data
- Shared object-storage prefixes without tenant isolation
- Admin bypasses without explicit platform scope and audit
- Returning 404/403 responses that reveal cross-tenant record existence
