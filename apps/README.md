# Monorepo Applications Directory (`apps/`)

This directory contains all application deliverables in the **PautiPustak** monorepo workspace.

## Directory Structure

```text
apps/
├── backend/                  # Enterprise microservices architecture & API services
│   ├── api-gateway/          # Gateway routing & edge proxy service
│   ├── audit-service/        # System audit logs & compliance service
│   ├── auth-service/         # Authentication, authorization & JWT management
│   ├── branch-service/       # Organization & branch hierarchy service
│   ├── customer-service/     # Contributor, donor & volunteer management
│   ├── expense-service/      # Expense & billing management service
│   ├── notification-service/ # Multi-channel notification dispatch service
│   ├── order-service/        # Contribution receipts & order fulfillment
│   ├── payment-service/      # Payment gateway integrations & settlements
│   ├── report-service/       # Analytics, exports & reporting engine
│   ├── scheduler-service/    # Cron job & background tasks scheduler
│   ├── search-service/       # Global search & index querying service
│   ├── service-service/      # Events, activities & service management
│   ├── tenant-service/       # Multi-tenant isolation & workspace management
│   └── user-service/         # User profiles & RBAC access control
└── mobile-app/               # Cross-platform Flutter mobile application
```

## Running Applications

- **Backend Microservices**: Run all or specific services via `pnpm dev:api` or `nx serve <service-name>`
- **Mobile Client**: Run Flutter app via `cd apps/mobile-app && flutter run`
