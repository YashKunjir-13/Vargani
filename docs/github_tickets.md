# GitHub Implementation Tickets Roadmap

## Epic 1: Shared Core Infrastructure & API Gateway
- **TICKET-101**: [INFRA] Setup API Gateway reverse proxy & JWT validation layer.
- **TICKET-102**: [INFRA] Refactor `@pauti-pustak/backend-contracts` to expose event DTOs.
- **TICKET-103**: [INFRA] Configure Redis & BullMQ event bus publisher/subscriber modules.

## Epic 2: Core Identity & Organization Microservices
- **TICKET-201**: [SERVICE] Extract `auth-service` and `user-service`.
- **TICKET-202**: [SERVICE] Extract `tenant-service`, `branch-service`, and `roles-service`.

## Epic 3: Business Domain Microservices
- **TICKET-301**: [SERVICE] Extract `customer-service` (Donors, Volunteers, Contributors).
- **TICKET-302**: [SERVICE] Extract `order-service` (Contributions & Collections).
- **TICKET-303**: [SERVICE] Extract `payment-service` & Razorpay webhook processor.
- **TICKET-304**: [SERVICE] Extract `receipt-service` & Pauti sequence counter.
- **TICKET-305**: [SERVICE] Extract `expense-service` & `finance-service`.

## Epic 4: Async Background Workers & Observability
- **TICKET-401**: [WORKER] Implement Notification & Receipt PDF background workers.
- **TICKET-402**: [OBSERVE] Configure OpenTelemetry tracing & Pino correlation IDs.
- **TICKET-403**: [CI/CD] Finalize Docker Compose and GitHub Actions pipeline.
