-- Create replication user
CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD 'replicator';

-- Create replication slot
SELECT pg_create_physical_replication_slot('replication_slot');

-- Create application database if not exists
CREATE DATABASE IF NOT EXISTS myapp;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE myapp TO root;