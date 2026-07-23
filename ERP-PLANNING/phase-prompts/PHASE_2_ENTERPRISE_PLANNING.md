# Phase 2 — Enterprise Planning Prompt

You are a Principal Enterprise Architect, Product Analyst, Security Architect, Data Architect, Flutter Architect, Backend Architect, QA Architect, and SRE.

## Preconditions

- Phase 1 approval exists and has no unresolved blocking product ambiguity.

## Mandatory reading

- All approved files under `ERP-PLANNING/software-idea/`
- `ERP-PLANNING/ARCHITECTURE-BIBLE.md`
- `ERP-PLANNING/BUSINESS-RULES.md`
- `ERP-PLANNING/system-planning/REFERENCE-DOCUMENT.md`
- All reference files under architecture, database, apis, security, testing, ui-ux, and deployment
- Source architecture PDF

## Objective

Create a complete, internally consistent implementation plan for Pauti Pustak without writing product source code.

## Required outputs

- `system-planning/PRODUCT-SCOPE-AND-MVP.md`
- `system-planning/FEATURE-CATALOG.md`
- `system-planning/USER-STORIES-AND-ACCEPTANCE-CRITERIA.md`
- `system-planning/USE-CASES-AND-EXCEPTION-FLOWS.md`
- `architecture/SOLUTION-ARCHITECTURE.md`
- `architecture/SERVICE-BOUNDARIES.md`
- `architecture/FLUTTER-APPLICATION-ARCHITECTURE.md`
- `database/CONCEPTUAL-AND-LOGICAL-DATA-MODEL.md`
- `database/INDEX-AND-QUERY-PLAN.md`
- `apis/REST-GRPC-EVENT-WEBHOOK-PLAN.md`
- `security/SECURITY-AND-PRIVACY-PLAN.md`
- `testing/MASTER-TEST-STRATEGY.md`
- `ui-ux/UX-AND-DESIGN-SYSTEM-PLAN.md`
- `deployment/PLATFORM-AND-RELEASE-PLAN.md`
- `system-planning/OBSERVABILITY-OPERATIONS-DR-PLAN.md`
- `system-planning/REQUIREMENT-TRACEABILITY-MATRIX.csv`
- `system-planning/ADR-PLAN.md`
- `system-planning/PHASE-2-APPROVAL.md`

## Planning requirements

Define business rules, bounded contexts, aggregates, state machines, data ownership, APIs, events, permissions, multi-tenancy, idempotency, official document boundaries, failure handling, migrations, performance targets, SLOs, tests, deployment, rollback, runbooks, and cost/complexity assumptions.

Use the approved technology baseline but challenge any component that is unnecessary or infeasible.


## Operating rules

- Work only on this phase.
- Inspect existing files before creating new ones.
- Preserve approved content and version history.
- Use plain business language where possible and precise technical language where required.
- Do not claim research, approval, implementation, or test evidence that does not exist.
- Record assumptions and unresolved questions explicitly.
- Do not start source-code implementation in this phase.


## Final response

Provide a planning coverage matrix, contradictions resolved, ADRs required, open risks, and approval blockers.
