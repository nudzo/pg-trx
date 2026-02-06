---
applyTo: "**"
---
# pg-trx: Custom PostgreSQL Image with Extensions

## Project Overview

Multi-stage Dockerfile building PostgreSQL with pgvector (vector similarity) and TimescaleDB (time-series) extensions. Published to GHCR (`ghcr.io/nudzo/pg-trx`) with multi-architecture support (amd64/arm64).

## Rules

- Use the latest stable versions of PostgreSQL, pgvector, and TimescaleDB
- Use Docker multi-stage build to minimize final image size
- Use Docker labels (`org.opencontainers.image.*` prefix) to provide image metadata — never override original PostgreSQL labels
- Use GitHub Actions for CI/CD and GitHub Container Registry (GHCR) for image storage
- Use semantic versioning for all image tags

## Architecture

**Dockerfile structure (3 stages):**
1. `pgvector-builder` — compiles pgvector from source
2. `timescaledb-builder` — compiles TimescaleDB from source
3. Final stage — copies compiled `.so` files and extension configs to clean `postgres:${PG_VERSION}` base

**Key files:**
- `Dockerfile` — versions defined as ARGs at top (PG_VERSION, PGVECTOR_VERSION, TIMESCALEDB_VERSION)
- `init-extensions.sql` — runs on first container start via `/docker-entrypoint-initdb.d/`
- `.github/workflows/build-image.yml` — CI that extracts versions from Dockerfile ARGs

## Version Updates

When updating versions, change ARGs in Dockerfile (lines 2–4). The workflow extracts these automatically:
```dockerfile
ARG PG_VERSION=17.7
ARG PGVECTOR_VERSION=0.8.1
ARG TIMESCALEDB_VERSION=2.25.0
```

When changing the PostgreSQL **major** version, also update all hardcoded paths in COPY statements and `postgresql-server-dev-*` package names (e.g., `/usr/lib/postgresql/17/lib/`, `postgresql-server-dev-17`).

## Build & Test

```bash
# Local build
docker build -t custom-postgres .

# Test extensions load correctly
docker run --rm -e POSTGRES_PASSWORD=test custom-postgres \
  postgres -c 'shared_preload_libraries=timescaledb' &
sleep 5
docker exec <container> psql -U postgres -c "SELECT extname FROM pg_extension;"
```

## Constraints

- Image must be a drop-in replacement for the official `postgres` image (and vice versa)
- Image must include the extensions initialization script (`init-extensions.sql`)
- Dockerfile must be self-contained — buildable standalone, outside of GitHub Actions (no external scripts beyond Dockerfile + init-extensions.sql)
- TimescaleDB requires `shared_preload_libraries` config (appended to `postgresql.conf.sample`)
- Image must be buildable for both `linux/amd64` and `linux/arm64`

## Tagging Strategy

Tag each architecture separately **and** create a multi-arch manifest:
- `17` — major version (also used as `latest`)
- `17.7` — full PostgreSQL version
- `full-17.7-pgv0.8.1-tsdb2.25.0` — complete version string with all components
- Architecture suffixes: `-amd64`, `-arm64` for platform-specific pulls

## Documentation Standards

- **Dockerfile**: comment non-obvious steps (explain *why*, not *what*)
- **init-extensions.sql**: explain each extension's purpose
- **README.md**: keep usage examples and version references current
