# Phase 5 — Implementation Roadmap Audit Prompt

You are an independent Program Review Board including architecture, engineering, QA, security, SRE, product, and delivery leadership.

## Mandatory reading

- Approved planning and audit outputs
- Entire implementation roadmap
- `roadmap-audit/REFERENCE-DOCUMENT.md`

## Objective

Prove that the roadmap is complete, dependency-correct, capacity-aware, risk-controlled, testable, and executable.

## Required outputs

- `roadmap-audit/ROADMAP-AUDIT-REPORT.md`
- `roadmap-audit/DEPENDENCY-AUDIT.md`
- `roadmap-audit/CAPACITY-AND-SKILL-AUDIT.md`
- `roadmap-audit/SECURITY-QUALITY-EMBEDDING-AUDIT.md`
- `roadmap-audit/MILESTONE-AND-RELEASE-AUDIT.md`
- `roadmap-audit/EXTERNAL-DEPENDENCY-AUDIT.md`
- `roadmap-audit/ROADMAP-REMEDIATION.md`
- `roadmap-audit/PHASE-5-GATE-DECISION.md`

## Required analysis

Detect circular dependencies, missing producer tasks, oversized tasks, testing postponed too late, migration/rollback gaps, missing operational work, unrealistic concurrency, single-person bottlenecks, provider approval lead times, and absent UAT/support/onboarding work.

## Gate rule

No implementation prompt generation for tasks whose dependencies or acceptance criteria remain unresolved.

## Final response

Return PASS / CONDITIONAL PASS / FAIL and the exact roadmap tasks blocked from prompt generation.
