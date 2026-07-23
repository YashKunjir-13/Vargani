# Environment Matrix

| Concern | Local | Development | Staging/UAT | Production |
|---|---|---|---|---|
| Data | Synthetic | Synthetic | Sanitized/synthetic | Real |
| Secrets | Local ignored files | Secret store | Secret store | Secret store |
| Payments | Mock/sandbox | Sandbox | Sandbox | Live |
| Notifications | Stub/dev channels | Test recipients | Approved test recipients | Live |
| Observability | Console/local | Shared dev | Production-like | Full SLO/alerts |
| Deployment | Docker Compose | Automated | Approval gate | Controlled rollout |
