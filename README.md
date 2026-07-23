<<<<<<< HEAD
# Pauti Pustak - Multi-tenant Event Financial-Management Platform

Full-stack monorepo enterprise foundation for **Pauti Pustak**.

## System Architecture Overview

```
.
├── apps/
│   ├── api/             # NestJS REST API Gateway & Authentication
│   ├── worker/          # NestJS BullMQ Workers (PDFs, Reports, Notifications)
│   ├── scheduler/       # NestJS CRON & Interval Scheduler
│   └── mobile/          # Flutter Multi-tenant Client (iOS / Android / Web)
│
├── packages/
│   ├── backend-config/          # Zod schema environment configuration
│   ├── backend-contracts/       # Shared DTOs and API interfaces
│   ├── backend-database/        # Prisma ORM models and client
│   ├── backend-observability/   # OpenTelemetry & Pino logger tracing
│   ├── backend-security/        # Auth, JWT RS256, Argon2id, RBAC & Guards
│   ├── backend-testing/         # Testcontainers fixtures (PostgreSQL / Redis)
│   └── backend-shared-kernel/   # S3/MinIO client & BullMQ queue specs
│
├── infrastructure/
│   ├── terraform/               # Terraform modules & environment foundations
│   ├── kubernetes/              # Kustomize base & overlay manifests
│   ├── helm/                    # Helm chart definitions
│   └── observability/           # OTel Collector, Prometheus, Loki, Tempo, Grafana
│
└── ERP-PLANNING/                # Architecture Bible & Domain Specs
```

## Quick Start & Local Setup

### 1. Prerequisites
- **Node.js**: v22 LTS (`>=22.0.0`)
- **pnpm**: v11 (handled via `npx pnpm`)
- **Docker & Docker Compose**: v29.4+ / v5.1+
- **Flutter**: v3.x (optional for mobile client)

### 2. Install Dependencies
```bash
npx pnpm install
```

### 3. Generate Local JWT Keys (RS256)
For local authentication testing, generate an RS256 keypair into `./config/certs/`:
```bash
mkdir -p config/certs
openssl genpkey -algorithm RSA -out config/certs/jwt_private.key -pkeyopt rsa_keygen_bits:2048
openssl rsa -in config/certs/jwt_private.key -pubout -out config/certs/jwt_public.key
```

### 4. Start Local Infrastructure Services
```bash
# Start core services (PostgreSQL, Redis, MinIO, Mailpit)
npx pnpm run docker:up

# Start full observability stack (Prometheus, Grafana, Loki, Tempo, OTel Collector)
npx pnpm run docker:observability
```

### 5. Generate Prisma ORM Client
```bash
npx pnpm run prisma:generate
```

### 6. Start Microservices in Development Mode
```bash
# Start all microservices concurrently
npx pnpm run dev

# Or start individually
npx pnpm run dev:api
npx pnpm run dev:worker
npx pnpm run dev:scheduler
```

### 7. Core Local Services Map
- **API Gateway / Swagger**: `http://localhost:3000/api/v1` (Docs: `http://localhost:3000/api/v1/docs`)
- **Mailpit Web UI**: `http://localhost:8025`
- **MinIO Console**: `http://localhost:9001` (Credentials: `minioadmin` / `minioadmin`)
- **Grafana Dashboard**: `http://localhost:3001` (Credentials: `admin` / `admin`)
- **Prometheus**: `http://localhost:9090`

## Validation Commands
```bash
npx pnpm run validate
```
=======
# Vargani
>>>>>>> 793328865821b904f23a1614a8f402eddfce0f49
