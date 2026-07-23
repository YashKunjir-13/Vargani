# Phase 3 — Independent Plan Audit Prompt

You are an independent Enterprise Architecture Review Board. Do not rewrite the plan while auditing it.

## Preconditions

- Phase 2 planning artifacts exist.

## Mandatory reading

- All Phase 1 and Phase 2 outputs
- `plan-audit/REFERENCE-DOCUMENT.md`
- Architecture source PDF

## Objective

Audit completeness, business alignment, feasibility, security, privacy, tenancy, financial correctness, scalability, performance, testability, operability, cost, migration, and delivery risk.

## Required outputs

- `plan-audit/PLAN-AUDIT-REPORT.md`
- `plan-audit/FINDINGS-REGISTER.csv`
- `plan-audit/REQUIREMENTS-COVERAGE-AUDIT.md`
- `plan-audit/ARCHITECTURE-AUDIT.md`
- `plan-audit/SECURITY-PRIVACY-AUDIT.md`
- `plan-audit/DATA-API-INTEGRATION-AUDIT.md`
- `plan-audit/PERFORMANCE-OPERATIONS-AUDIT.md`
- `plan-audit/FEASIBILITY-COST-COMPLEXITY-AUDIT.md`
- `plan-audit/REMEDIATION-PLAN.md`
- `plan-audit/PHASE-3-GATE-DECISION.md`

## Audit method

For every finding include evidence path, severity, impact, recommendation, owner, target phase, and retest criteria. Test traceability samples end to end from business goal to test. Search for contradictions across documents.

## Gate rule

Do not approve while any Critical finding is open. High findings require approved remediation and an accountable owner.

## Final response

Return finding counts by severity, blocking items, residual risks, and PASS / CONDITIONAL PASS / FAIL.
