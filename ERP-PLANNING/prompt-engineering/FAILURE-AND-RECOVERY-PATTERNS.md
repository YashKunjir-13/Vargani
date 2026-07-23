# Failure and Recovery Patterns

The agent must stop and report rather than improvise when:

- Required dependency is incomplete.
- Tests cannot run and no approved substitute exists.
- A migration could destroy data.
- Business rules conflict.
- A provider contract is unknown.
- Tenant or permission ownership is unclear.
- The requested file scope conflicts with current architecture.

Recovery requires a new decision, remediation task, or prompt version—not silent scope expansion.
