-- PostgreSQL initialization script for pgvector and TimescaleDB extensions
-- This script runs automatically when a container is first started

-- Enable pgvector extension for vector similarity search capabilities
-- This adds new vector data type and similarity search operators
CREATE EXTENSION IF NOT EXISTS vector;

-- Enable TimescaleDB extension for time-series data functionality
-- This adds time-series optimized tables and related functions
CREATE EXTENSION IF NOT EXISTS timescaledb;

-- Verification query to confirm extensions are properly installed
-- This output will be visible in container logs during initialization
SELECT extname, extversion FROM pg_extension WHERE extname IN ('vector', 'timescaledb');
