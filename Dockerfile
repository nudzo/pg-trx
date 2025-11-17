# Define versions
ARG PG_VERSION=17.7
ARG PGVECTOR_VERSION=0.8.1
ARG TIMESCALEDB_VERSION=2.23.1

# Custom PostgreSQL image with pgvector and TimescaleDB extensions
# This Dockerfile implements a multi-stage build to minimize the final image size

# Stage 1: Build pgvector extension
# Using the official PostgreSQL image as base for building pgvector
FROM postgres:${PG_VERSION} AS pgvector-builder

# Define extension version
ARG PGVECTOR_VERSION

# Install necessary dependencies for building pgvector
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    postgresql-server-dev-17 \
    && rm -rf /var/lib/apt/lists/*

# Clone and build pgvector
WORKDIR /usr/src/pgvector
RUN git clone --branch v${PGVECTOR_VERSION} --depth 1 https://github.com/pgvector/pgvector.git . \
    && make \
    && make install

# Stage 2: Build TimescaleDB extension
# Using the official PostgreSQL image as base for building TimescaleDB
FROM postgres:${PG_VERSION} AS timescaledb-builder

# Define extension version
ARG TIMESCALEDB_VERSION

# Install necessary dependencies for building TimescaleDB
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    git \
    libkrb5-dev \
    libssl-dev \
    postgresql-server-dev-17 \
    && rm -rf /var/lib/apt/lists/*

# Clone and build TimescaleDB
WORKDIR /usr/src/timescaledb
RUN git clone --branch ${TIMESCALEDB_VERSION} --depth 1 https://github.com/timescale/timescaledb.git . \
    && ./bootstrap -DREGRESS_CHECKS=OFF -DWARNINGS_AS_ERRORS=OFF -DUSE_OPENSSL=ON \
    && cd build \
    && make \
    && make install

# Stage 3: Final image assembly
# Using the official PostgreSQL image as the base for our final image
# This ensures functional compatibility with the original PostgreSQL image
FROM postgres:${PG_VERSION}

# Define versions for metadata
ARG PGVECTOR_VERSION
ARG TIMESCALEDB_VERSION

# Add custom labels for better discoverability and information
# Note: We're not overriding any original PostgreSQL labels, only adding our own
LABEL Name="custom-postgres" \
      Version="${PG_VERSION}" \
      maintainer="Custom PostgreSQL with extensions" \
      org.opencontainers.image.description="PostgreSQL with pgvector and timescaledb extensions" \
      pgvector.version="${PGVECTOR_VERSION}" \
      timescaledb.version="${TIMESCALEDB_VERSION}"

# Copy compiled extensions from builder stages to the final image
# This approach keeps the final image small by excluding build dependencies
COPY --from=pgvector-builder /usr/lib/postgresql/17/lib/*.so* /usr/lib/postgresql/17/lib/
COPY --from=pgvector-builder /usr/share/postgresql/17/extension/vector* /usr/share/postgresql/17/extension/

COPY --from=timescaledb-builder /usr/lib/postgresql/17/lib/*.so* /usr/lib/postgresql/17/lib/
COPY --from=timescaledb-builder /usr/share/postgresql/17/extension/timescaledb* /usr/share/postgresql/17/extension/

# Configure TimescaleDB to be loaded at startup - required for TimescaleDB functionality
# This modifies the sample configuration file used when initializing a new database
RUN echo "shared_preload_libraries = 'timescaledb'" >> /usr/share/postgresql/postgresql.conf.sample

# Set up automatic extension initialization when container starts
# The official PostgreSQL image automatically runs any SQL files in this directory
RUN mkdir -p /docker-entrypoint-initdb.d
COPY init-extensions.sql /docker-entrypoint-initdb.d/

# Verify image
RUN pg_config --version && ls -la /usr/lib/postgresql/17/lib/ | grep -E 'vector|timescale'
