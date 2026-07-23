# Pauti Pustak — ERP Planning Workspace

This folder is the execution control centre for building the complete Pauti Pustak platform with Claude Code, Gemini Code Assist, Codex, or another VS Code coding agent.

It intentionally contains **planning, audit, reference, prompt, and completion artifacts only**. Product source code belongs outside `ERP-PLANNING`, typically under `apps/`, `packages/`, `infra/`, and `docs/` in the main repository.

## How to use this workspace

1. Place `ERP-PLANNING` at the repository root.
2. Read `MASTER-EXECUTION-GUIDE.md` and `PROJECT-CONTEXT.md`.
3. Start with `phase-prompts/SESSION_STARTER.md` in a fresh AI session.
4. Execute lifecycle prompts in order:
   - Phase 1 — Software Idea Description
   - Phase 2 — Enterprise Planning
   - Phase 3 — Plan Audit
   - Phase 4 — Implementation Roadmap
   - Phase 5 — Roadmap Audit
   - Phase 7 Foundation — Prompt Engineering Architecture
   - Phase 6 — Implementation Prompt Generation
5. Execute the generated implementation prompts one at a time.
6. After each phase, create a signed completion record under `phase-completions/`.
7. Never allow an AI tool to claim completion without command output, tests, and repository evidence.

## Governing principle

Every implementation prompt must be traceable to an approved requirement, roadmap task, acceptance criterion, test, security control, and completion record.

## Primary reference

The source architecture PDF is stored at:

`assets/references/Pauti_Pustak_Backend_System_Architecture_Module_Requirements_Enterprise_v2.1_Revised.pdf`

## Execution order

```text
Discovery and product definition
        ↓
Enterprise plan
        ↓
Independent plan audit
        ↓
Dependency-aware roadmap
        ↓
Independent roadmap audit
        ↓
Prompt architecture foundation
        ↓
Task-level implementation prompts
        ↓
Controlled implementation sessions
        ↓
Phase completion evidence and audits
```

## Important

Do not paste every prompt into one AI session. Use one fresh session for one controlled task or implementation phase so the agent retains scope discipline and produces verifiable results.
