# DevOps and Deployment Reference

## Environments

- Local
- Development
- Staging/UAT
- Production

## Pipeline gates

- Dependency resolution
- Code generation verification
- Format and lint
- Unit/integration/contract/E2E tests
- Migration validation
- SAST, secret, dependency, and container scans
- SBOM and signed artifacts
- Build and deploy diff
- Smoke tests and rollback validation

## Production

Use controlled canary or blue/green rollout for critical services. Automated rollback signals include health, latency, error rate, queue lag, and reconciliation mismatches.
