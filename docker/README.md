# Docker Configurations & Environment Manifests (`docker/`)

This directory contains containerization manifests, Dockerfiles, and compose configurations for development, testing, and production environments.

## Layout

- `dev/`: Development compose files with hot-reloading enabled.
- `prod/`: Production container specs and multi-stage builds.
- `docker-compose.yml`: Primary orchestration spec for core services (PostgreSQL, Redis, NATS/RabbitMQ).
