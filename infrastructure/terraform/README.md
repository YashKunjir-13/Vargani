# Terraform Infrastructure Foundations for Pauti Pustak

This directory contains starter Terraform modules and environment definitions for provisioning cloud resources (AWS / Kubernetes / PostgreSQL).

## Environments
- `environments/dev`: Development cloud environment parameters.
- `environments/staging`: Staging pre-production environment parameters.
- `environments/prod`: Production HA environment parameters.

> [!IMPORTANT]
> Do not execute `terraform apply` locally without explicit approval and configured cloud credentials.
