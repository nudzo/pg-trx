# Define versions
ARG PG_VERSION=17.4
ARG PGVECTOR_VERSION=0.8.0
ARG TIMESCALEDB_VERSION=2.19.3

# Build pgvector extension
FROM postgres:${PG_VERSION} AS pgvector-builder

# Define extension version
ARG PGVECTOR_VERSION

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    postgresql-server-dev-17 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/pgvector

RUN git clone --branch v${PGVECTOR_VERSION} --depth 1 https://github.com/pgvector/pgvector.git . \
    && make \
    && make install

# Build timescaledb extension
FROM postgres:${PG_VERSION} AS timescaledb-builder

# Define extension version
ARG TIMESCALEDB_VERSION

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

WORKDIR /usr/src/timescaledb

RUN git clone --branch ${TIMESCALEDB_VERSION} --depth 1 https://github.com/timescale/timescaledb.git . \
    && ./bootstrap -DREGRESS_CHECKS=OFF -DWARNINGS_AS_ERRORS=OFF -DUSE_OPENSSL=ON \
    && cd build \
    && make \
    && make install

# Final image
FROM postgres:${PG_VERSION}

# Define versions for metadata
ARG PGVECTOR_VERSION
ARG TIMESCALEDB_VERSION

LABEL Name="custom-postgres" \
      Version="${PG_VERSION}" \
      maintainer="Custom PostgreSQL with extensions" \
      org.opencontainers.image.description="PostgreSQL with pgvector and timescaledb extensions" \
      pgvector.version="${PGVECTOR_VERSION}" \
      timescaledb.version="${TIMESCALEDB_VERSION}"

# Copy extensions from builder stages
COPY --from=pgvector-builder /usr/lib/postgresql/17/lib/*.so* /usr/lib/postgresql/17/lib/
COPY --from=pgvector-builder /usr/share/postgresql/17/extension/vector* /usr/share/postgresql/17/extension/

COPY --from=timescaledb-builder /usr/lib/postgresql/17/lib/*.so* /usr/lib/postgresql/17/lib/
COPY --from=timescaledb-builder /usr/share/postgresql/17/extension/timescaledb* /usr/share/postgresql/17/extension/

# Update postgresql.conf to load extensions
RUN echo "shared_preload_libraries = 'timescaledb'" >> /usr/share/postgresql/postgresql.conf.sample

# Create docker-entrypoint initialization script to enable extensions
RUN mkdir -p /docker-entrypoint-initdb.d
COPY init-extensions.sql /docker-entrypoint-initdb.d/

# Verify image
RUN pg_config --version && ls -la /usr/lib/postgresql/17/lib/ | grep -E 'vector|timescale'
