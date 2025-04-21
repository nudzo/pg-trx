-- Enable extensions automatically on database initialization
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Simple verification query
SELECT extname, extversion FROM pg_extension WHERE extname IN ('vector', 'timescaledb');
