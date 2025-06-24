CREATE ROLE replicator WITH REPLICATION LOGIN ENCRYPTED PASSWORD 'test';
select pg_create_physical_replication_slot('replication_slot');