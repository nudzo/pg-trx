# Custom PostgreSQL with Extensions

This repository contains a Dockerfile for building a custom PostgreSQL image with additional extensions pre-installed:

- pgvector - for vector similarity search
- TimescaleDB - for time-series data

## Features

- Based on the official PostgreSQL 17.4 image
- Multi-stage build to minimize image size
- Pre-configured with pgvector and TimescaleDB extensions
- Extensions are automatically enabled on database initialization
- Parametrized versions for easy updates

## Usage

### Build Locally

To build the image locally:

```bash
docker build -t custom-postgres .
```

With custom versions:

```bash
docker build \
  --build-arg PG_VERSION=17.4 \
  --build-arg PGVECTOR_VERSION=0.8.0 \
  --build-arg TIMESCALEDB_VERSION=2.19.3 \
  -t custom-postgres .
```

### Run the Container

```bash
docker run -d \
  --name postgres-with-extensions \
  -e POSTGRES_PASSWORD=mysecretpassword \
  -p 5432:5432 \
  custom-postgres
```

### Verify Extensions

Connect to the PostgreSQL instance and verify the extensions:

```sql
SELECT extname, extversion FROM pg_extension WHERE extname IN ('vector', 'timescaledb');
```

## GitHub Actions

This repository uses GitHub Actions to automatically build and publish the Docker image.

You can trigger a manual build with custom versions using the GitHub Actions UI.

## License

See the [LICENSE](LICENSE) file for details for files in this repository.
See [pgvector](https://github.com/pgvector/pgvector) and [TimescaleDB](https://github.com/timescale/timescaledb) for their respective licenses.
