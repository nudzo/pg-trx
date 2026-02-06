# Custom PostgreSQL with Extensions

This repository contains a production-ready, multi-stage Dockerfile for building a custom PostgreSQL 17.7 image with additional extensions pre-installed:

- pgvector (v0.8.1) - for vector similarity search capabilities
- TimescaleDB (v2.25.0) - for time-series data management

## Features

- Based on the official PostgreSQL 17.7 image
- Multi-stage build to minimize image size
- Pre-configured with pgvector and TimescaleDB extensions
- Extensions are automatically enabled on database initialization
- Parametrized versions for easy updates
- Fully compatible with the original PostgreSQL image
- Semantic versioning for image tags

## Usage

### Build Locally

To build the image locally with default versions:

```bash
docker build -t custom-postgres .
```

With custom versions:

```bash
docker build \
  --build-arg PG_VERSION=17.7 \
  --build-arg PGVECTOR_VERSION=0.8.1 \
  --build-arg TIMESCALEDB_VERSION=2.25.0 \
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

The extensions are automatically enabled when the container starts. You can verify they are properly installed by connecting to the PostgreSQL instance and running:

```sql
SELECT extname, extversion FROM pg_extension WHERE extname IN ('vector', 'timescaledb');
```

### Using with Docker Compose

```yaml
version: '3.8'

services:
  db:
    image: ghcr.io/nudzo/pg-trx:17
    environment:
      POSTGRES_PASSWORD: mysecretpassword
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## GitHub Actions

This repository uses GitHub Actions to automatically build and publish the Docker image to GitHub Container Registry (GHCR).

### Multi-Architecture Support

The images are built for multiple architectures to support different hardware platforms:

- **linux/amd64** (Intel/AMD x86_64)
- **linux/arm64** (ARM 64-bit, including Apple Silicon)

Docker automatically selects the correct architecture when you pull an image using the standard tags.

### Image Tagging

The workflow creates several tags following semantic versioning principles:

**Multi-architecture tags (recommended):**
- `17` - Major version tag
- `17.7` - Full PostgreSQL version tag  
- `full-17.7-pgv0.8.1-tsdb2.25.0` - Full semantic version including all component versions
- `latest` - Latest stable version

**Architecture-specific tags:**
- `17-amd64`, `17-arm64` - Major version for specific architecture
- `17.7-amd64`, `17.7-arm64` - Full version for specific architecture
- `full-17.7-pgv0.8.1-tsdb2.25.0-amd64`, `full-17.7-pgv0.8.1-tsdb2.25.0-arm64` - Full version for specific architecture
- `latest-amd64`, `latest-arm64` - Latest version for specific architecture

**Usage Examples:**

```bash
# Pull the multi-arch image (automatically selects your platform)
docker pull ghcr.io/nudzo/pg-trx:17

# Pull a specific architecture
docker pull ghcr.io/nudzo/pg-trx:17-amd64
docker pull ghcr.io/nudzo/pg-trx:17-arm64
```

### Manual Builds

You can trigger a manual build with custom extension versions using the GitHub Actions UI. This allows specifying different versions of PostgreSQL, pgvector, and TimescaleDB.

## Extension Details

### pgvector

pgvector adds vector similarity search to PostgreSQL for embeddings and other ML workloads. It provides:

- Vector data type
- L2 distance, inner product, and cosine distance operators
- Exact and approximate nearest neighbor search

### TimescaleDB

TimescaleDB is a time-series database built as a PostgreSQL extension. It provides:

- Automatic partitioning across time and space
- Full SQL interface for time-series data
- Optimized time-series queries and functions

## Compatibility

This image is designed to be a drop-in replacement for the official PostgreSQL image. All environment variables, volumes, and configuration options from the original PostgreSQL image work with this custom image.

## License

See the [LICENSE](LICENSE) file for details for files in this repository.
See [pgvector](https://github.com/pgvector/pgvector) and [TimescaleDB](https://github.com/timescale/timescaledb) for their respective licenses.
