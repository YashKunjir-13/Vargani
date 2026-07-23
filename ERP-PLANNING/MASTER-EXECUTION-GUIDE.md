# Master Execution Guide

## Objective

Use the files in this workspace to build Pauti Pustak through controlled, reviewable, enterprise-grade AI-assisted development.

## Mandatory sequence

| Gate | Required artifact | May implementation continue? |
|---|---|---|
| G1 | Approved software idea | No, until approved |
| G2 | Approved enterprise plan | No, until approved |
| G3 | Plan audit with no open Critical finding | No, until passed |
| G4 | Approved implementation roadmap | No, until approved |
| G5 | Roadmap audit with dependency and capacity sign-off | No, until passed |
| G6 | Prompt architecture foundation | Required before bulk prompt generation |
| G7 | Approved task prompt | Only that task may begin |
| G8 | Completion evidence | Required before dependent tasks begin |

## Session operating model

Each AI session must:

1. Inspect the repository and Git status.
2. Read only the context required by the selected prompt.
3. Restate scope, dependencies, and risks before changes.
4. Preserve existing work.
5. Make small, reviewable changes.
6. Execute required checks.
7. Produce a structured execution report.
8. Stop on unresolved security, migration, or architecture ambiguity.

## Tool-neutral usage

The prompts are compatible with Claude Code, Gemini Code Assist, Codex, and similar agents. Tool-specific features are optional; the agent must rely on normal terminal, filesystem, Git, and editor access.

## Evidence policy

A statement such as “implemented”, “secure”, “tested”, or “production-ready” is valid only when supported by:

- File paths and commit diff
- Executed commands and exit results
- Test reports
- Analyzer/linter results
- Migration evidence
- Security scan evidence where required
- Screenshots or API examples for externally visible behaviour

## Stop conditions

The agent must stop rather than guess when:

- A required architecture decision is missing.
- A destructive migration lacks backup and rollback.
- A financial invariant is ambiguous.
- A permission or tenant boundary is unclear.
- Production secrets would be required.
- Existing code conflicts materially with the approved plan.
- Required tests cannot run.

## Completion policy

Use `phase-completions/COMPLETION-REPORT-TEMPLATE.md`. A phase is not complete merely because files exist.
