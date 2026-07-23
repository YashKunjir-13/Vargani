# API Standards

- Version public APIs under `/api/v1`.
- Use OpenAPI as the public REST contract.
- Use Protobuf for approved internal gRPC contracts.
- Use AsyncAPI or an event catalogue for NATS subjects.
- Use stable error codes independent of localized messages.
- Support pagination, filtering, sorting, and date ranges consistently.
- Propagate correlation IDs.
- Require idempotency keys for retryable financial commands.
- Validate body, params, query, headers, and authorization context.
- Never leak stack traces, SQL details, or cross-tenant existence.
