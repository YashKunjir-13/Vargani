# API Dependency Map

This document maps all REST API endpoints to their backing microservices, required data models, and downstream asynchronous events.

| Public API Route | Microservice | Required Shared Packages | Domain Events Produced |
| :--- | :--- | :--- | :--- |
| `/v1/auth/*` | `auth-service` | `@pauti-pustak/backend-security`, `backend-contracts` | `UserLoggedIn`, `OtpSent` |
| `/v1/users/*` | `user-service` | `@pauti-pustak/backend-security` | `UserProfileUpdated` |
| `/v1/organizations/*` | `tenant-service` | `@pauti-pustak/backend-database` | `OrganizationCreated` |
| `/v1/memberships/*` | `tenant-service` | `@pauti-pustak/backend-security` | `MembershipInvited` |
| `/v1/roles/*` | `tenant-service` | `@pauti-pustak/backend-security` | `RoleCreated` |
| `/v1/events/*` | `service-service` | `@pauti-pustak/backend-database` | `EventCreated`, `EventClosed` |
| `/v1/volunteers/*` | `service-service` | `@pauti-pustak/backend-database` | `VolunteerAssigned` |
| `/v1/donors/*` | `customer-service` | `@pauti-pustak/backend-database` | `DonorCreated`, `DonorsMerged` |
| `/v1/contributors/*` | `customer-service` | `@pauti-pustak/backend-database` | `ContributorAccountCreated` |
| `/v1/contributions/*` | `order-service` | `@pauti-pustak/backend-contracts` | `ContributionCreated` |
| `/v1/bills/*` | `expense-service` | `@pauti-pustak/backend-contracts` | `BillCreated`, `ExpenseApproved` |
| `/v1/payments/*` | `payment-service` | `@pauti-pustak/backend-contracts` | `PaymentCompleted`, `PaymentFailed` |
| `/v1/receipts/*` | `receipt-service` | `@pauti-pustak/backend-contracts` | `ReceiptGenerated` |
| `/v1/finance/*` | `finance-service` | `@pauti-pustak/backend-database` | `LedgerUpdated` |
| `/v1/documents/*` | `document-service` | `@pauti-pustak/backend-config` | `DocumentUploaded` |
| `/v1/notifications/*` | `notification-service` | `@pauti-pustak/backend-contracts` | `NotificationQueued` |
| `/v1/reports/*` | `report-service` | `@pauti-pustak/backend-contracts` | `ReportRequested` |
| `/v1/dashboards/*` | `dashboard-service` | `@pauti-pustak/backend-database` | None |
| `/v1/platform/*` | `api-gateway` / `platform` | `@pauti-pustak/backend-security` | `TenantProvisioned` |
