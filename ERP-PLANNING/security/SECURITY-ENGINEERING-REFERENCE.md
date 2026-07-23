# Security Engineering Reference

## Required practices

- Threat modeling for auth, tenant isolation, payments, files, public pages, ledger, audit, and admin features.
- Argon2id password hashing.
- OTP expiry, attempt limits, single use, and rate limits.
- Rotated refresh sessions with reuse detection.
- RBAC on the backend; optional policy checks for high-risk actions.
- Managed secrets and key rotation.
- Encryption in transit and at rest.
- Structured redacted logging.
- SAST, dependency, secret, container, and DAST scans.
- Security abuse cases become automated tests where practical.

## Review evidence

Every security-sensitive task must identify assets, actors, trust boundaries, threats, controls, tests, residual risk, and reviewer.
