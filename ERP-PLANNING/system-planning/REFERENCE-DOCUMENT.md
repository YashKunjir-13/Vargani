# Phase 2 Reference — Enterprise System Planning

## Planning goal

Create a plan that is complete enough for independent audit and roadmap generation without requiring the implementation team to invent business rules.

## Required planning areas

- Scope, actors, user stories, use cases, and acceptance criteria
- Domain model and bounded contexts
- System, solution, data, security, integration, deployment, and client architecture
- API, event, webhook, and document contracts
- Database ownership, schemas, indexes, migrations, retention, and backups
- Threat model and tenant-isolation strategy
- Testing, observability, operations, recovery, and release strategy
- Assumptions, risks, ADRs, and requirement traceability

## Technology baseline

- Client: Flutter + Dart, Material 3, Riverpod, go_router, Dio, Freezed/json_serializable, Drift, secure platform storage, English/Marathi/Hindi localization.
- Backend: NestJS 11 + TypeScript, PostgreSQL + Prisma, Redis + BullMQ, NATS JetStream, REST/OpenAPI, gRPC, S3-compatible private storage, Handlebars/Puppeteer PDF generation, Razorpay.
- Platform: Docker, Kubernetes, Helm, GitLab CI, OpenTelemetry, structured logs, metrics, traces, alerts, runbooks.
- Quality: Jest, Supertest, Testcontainers, Pact/contract tests, Playwright, Flutter tests, integration tests, k6, SAST/DAST/dependency scanning.

## Planning principle

Every technology must solve a stated requirement. Do not include a framework, protocol, database, cloud service, or AI component merely because it is fashionable.
