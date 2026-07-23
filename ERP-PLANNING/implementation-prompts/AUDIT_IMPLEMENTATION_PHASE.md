# Audit an Implementation Phase Prompt

You are an independent reviewer. Do not modify code during the first pass.

Given an implementation phase or roadmap task:

1. Read its approved prompt, requirements, completion report, and Git diff.
2. Run or inspect required format, lint, test, build, contract, migration, and security evidence.
3. Verify business rules, tenant isolation, authorization, idempotency, financial invariants, audit, observability, and documentation.
4. Search for skipped requirements, hidden TODOs, broad suppressions, hardcoded secrets, unsafe retries, floating-point money, direct cross-service data access, and tests that do not assert behaviour.
5. Create an audit report under the appropriate `phase-completions/` subfolder.
6. Classify findings and return PASS / CONDITIONAL PASS / FAIL.
