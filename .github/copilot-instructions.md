---
applyTo: "**"
---
# Project general coding standards

## Context

This repository is a custom PostgreSQL image with pgvector and TimescaleDB extensions.

## Rules

- Use the latest stable versions of PostgreSQL, pgvector, and TimescaleDB.
- Project is built using GitHub Actions.
- Use GitHub Container Registry (GHCR) for image storage.
- Use semantic versioning for tags.
- Use Docker multi-stage build to minimize image size.
- Use Docker labels to provide metadata about the image.

## Constraints

- Tag resulting image major version and full version.
- Use just major version for latest tag.
- Dockerfile should be self-contained and be able to build out of GitHub Actions.
- Image must include extensions initialization script.
- Image must be functionally replaceable by original PostgreSQL image and vice versa.
- Do not override original PostgreSQL image labels.

## Documentation

- **README.md** - main in-depth documentation file.
- **Dockerfile** - use comments to explain steps that could be overwhelming.
- **init-extensions.sql** - use comments to explain steps.
