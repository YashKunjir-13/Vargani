# Audit All Lifecycle Phases Prompt

You are an independent enterprise governance auditor.

Inspect every lifecycle phase, completion report, approval, audit, roadmap artifact, generated implementation prompt, and prompt registry record.

Create:

- `phase-completions/ENTERPRISE-LIFECYCLE-AUDIT.md`
- `phase-completions/LIFECYCLE-GAPS.csv`

Verify:

- Required artifacts exist and contain substantive content.
- Approval and gate decisions are evidence-based.
- Findings are closed or explicitly accepted.
- Roadmap tasks trace to requirements and prompts.
- Prompts trace to execution reports and commits.
- No phase is marked complete based only on folder/file presence.
- Security, testing, migration, observability, operations, and documentation are embedded.

Return an overall maturity score, blocked stages, missing evidence, and the next corrective action.
