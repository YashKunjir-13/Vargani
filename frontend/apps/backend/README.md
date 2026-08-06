# Backend Microservices Suite (`apps/backend/`)

This directory houses the microservices architecture for the **PautiPustak** enterprise platform.

## Microservices Breakdown

| Service Name | Description | Module Scope |
| :--- | :--- | :--- |
| `api-gateway` | Reverse Proxy, Rate Limiting & Aggregation Gateway | Edge Routing, Security Headers, JWT Validation |
| `audit-service` | Audit Trail & Compliance Log Manager | System Logs, Security Audits, Change History |
| `auth-service` | Identity, OAuth2, Session & JWT Service | Login, MFA, Password Reset, Token Exchange |
| `branch-service` | Organization, Division & Branch Management | Tenant Branches, Sub-Units, Hierarchy |
| `customer-service` | Contributor, Donor & Volunteer CRM | Donors, Beneficiaries, Member Directory |
| `expense-service` | Expense, Bills & Financial Claims | Bills Management, Outflows, Vendor Claims |
| `notification-service` | Multi-Channel Notification Engine | Push (FCM), SMS, Email (SMTP), WhatsApp API |
| `order-service` | Collection Receipts & Billing Orders | Receipt Generation, Pauti Management |
| `payment-service` | Payment Gateways & Settlement Engine | Razorpay, UPI, Bank Transfers, Reconciliations |
| `report-service` | Analytics, CSV/PDF Exporter & Metrics | Financial Statements, Audit Reports, BI |
| `scheduler-service` | Background Job Processor & Cron Manager | Recurring Reminders, Cleanup Jobs, Queue Workers |
| `search-service` | Global Search & Elastic/Vector Queries | Full-Text Search, Contributor Lookups |
| `service-service` | Events, Programs & Activity Services | Community Events, Campaigns, Festivals |
| `tenant-service` | Multi-Tenant Provisioning & Isolation | Tenant Onboarding, Schema / DB Routing |
| `user-service` | User Profiles & RBAC Authorization | User Accounts, Roles, Permissions, Profiles |

## Architecture & Integration

All microservices inherit standard configuration, database access, security guards, and telemetry from workspace shared packages:
- `@pauti-pustak/backend-config`
- `@pauti-pustak/backend-contracts`
- `@pauti-pustak/backend-database`
- `@pauti-pustak/backend-observability`
- `@pauti-pustak/backend-security`
- `@pauti-pustak/backend-shared-kernel`
- `@pauti-pustak/backend-testing`
