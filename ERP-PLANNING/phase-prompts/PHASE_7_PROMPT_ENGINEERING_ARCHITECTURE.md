# Phase 7 — Prompt Engineering Architecture Setup Prompt

You are a Principal Prompt Platform Architect.

## Objective

Establish the versioned prompt architecture before generating implementation prompts at scale.

## Required outputs

Create or complete:

- `prompt-engineering/PROMPT-GOVERNANCE.md`
- `prompt-engineering/CONTEXT-MANAGEMENT.md`
- `prompt-engineering/PROMPT-NAMING-AND-VERSIONING.md`
- `prompt-engineering/PROMPT-REVIEW-CHECKLIST.md`
- `prompt-engineering/PROMPT-EVALUATION-RUBRIC.md`
- `prompt-engineering/EXECUTION-WORKFLOW.md`
- `prompt-engineering/FAILURE-AND-RECOVERY-PATTERNS.md`
- `prompt-engineering/AGENT-TOOL-COMPATIBILITY.md`
- Reusable templates under `prompt-engineering/templates/`
- Context packs under `prompt-engineering/context/`
- `prompt-registry.yaml`

## Requirements

Prompts are immutable after approval; changes create semantic versions. Every prompt maps to one roadmap task. Context must be layered to control token use. Execution reports must capture starting/ending commit, files, commands, tests, deviations, and unresolved items.

## Evaluation

Score prompts for requirement coverage, scope control, technical accuracy, security, testability, repository awareness, dependency awareness, token efficiency, failure handling, reusability, and auditability.

## Final response

Return the architecture created, templates available, registry validation result, and readiness for Phase 6.
