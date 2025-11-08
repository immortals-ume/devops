# SQL Databases - Local Setup

Complete SQL database stack with primary-replica replication for PostgreSQL and MySQL.

## Databases Included

### PostgreSQL 16.2
- **Primary**: localhost:5432
- **Replica**: localhost:5433
- Automatic streaming replication with GTID
- User: root / Password: root

### MySQL 8.4
- **Primary**: localhost:3306
- **Replica**: localhost:3307
- GTID-based replication
- User: root / Password: root

### MariaDB 11.4
- **Primary**: localhost:3308
- **Replica**: localhost:3309
- GTID-based replication
- User: root / Password: root

### Microsoft SQL Server 2022
- **Port**: localhost:1433
- Developer Edition
- User: sa / Password: YourStrong@Passw0rd

### Oracle Database XE 21c
- **Port**: localhost:1521
- **Enterprise Manager**: http://localhost:5500/em
- User: system / Password: Oracle123
- App User: myapp / Password: myapp

## Quick Start

### 1. Start All Databases

```bash
docker-compose up -d
```

### 2. Setup Replication

After containers are healthy, run:

```bash
# MySQL replication
./setup_mysql_replication.sh

# MariaDB replication
./setup_mariadb_replication.sh
```

PostgreSQL replication is automatic on first start.

### 3. Verify Replication

**PostgreSQL:**
```bash
# Check primary status
docker exec postgres_primary psql -U root -c "SELECT * FROM pg_stat_replication;"

# Check replica status
docker exec postgres_replica psql -U root -c "SELECT * FROM pg_stat_wal_receiver;"
```

**MySQL:**
```bash
# Check replica status
docker exec mysql_replica mysql -u root -proot -e "SHOW SLAVE STATUS\G" | grep "Slave_IO_Running\|Slave_SQL_Running"
```

**MariaDB:**
```bash
# Check replica status
docker exec mariadb_replica mariadb -u root -proot -e "SHOW SLAVE STATUS\G" | grep "Slave_IO_Running\|Slave_SQL_Running"
```

**SQL Server:**
```bash
# Check connection
docker exec mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "SELECT @@VERSION"
```

**Oracle:**
```bash
# Check connection
docker exec oracle_xe sqlplus myapp/myapp@localhost:1521/MYAPP <<< "SELECT * FROM users;"
```

## Testing Replication

### PostgreSQL Test

```bash
# Create test data on primary
docker exec postgres_primary psql -U root -d myapp -c "CREATE TABLE test (id SERIAL PRIMARY KEY, data TEXT);"
docker exec postgres_primary psql -U root -d myapp -c "INSERT INTO test (data) VALUES ('Hello from primary');"

# Verify on replica
docker exec postgres_replica psql -U root -d myapp -c "SELECT * FROM test;"
```

### MySQL Test

```bash
# Create test data on primary
docker exec mysql_primary mysql -u root -proot -e "USE myapp; CREATE TABLE test (id INT AUTO_INCREMENT PRIMARY KEY, data VARCHAR(255));"
docker exec mysql_primary mysql -u root -proot -e "USE myapp; INSERT INTO test (data) VALUES ('Hello from primary');"

# Verify on replica
docker exec mysql_replica mysql -u root -proot -e "USE myapp; SELECT * FROM test;"
```

## Backup & Restore

### Backup All Databases

```bash
./backup.sh
```

Backups are stored in `./backups/` with timestamps.

### Restore from Backup

```bash
# PostgreSQL
./restore.sh postgres postgres_backup_20240101_120000.sql

# MySQL
./restore.sh mysql mysql_backup_20240101_120000.sql

# H2
./restore.sh h2 h2_backup_20240101_120000
```

## Configuration Files

- `postgresql.conf` - PostgreSQL server configuration
- `pg_hba.conf` - PostgreSQL authentication rules
- `mysql_primary.cnf` - MySQL primary configuration
- `mysql_replica.cnf` - MySQL replica configuration
- `postgres_init.sql` - PostgreSQL initialization script
- `mysql_init/` - MySQL initialization scripts

## Environment Variables

Create a `.env` file in this directory:

```env
# PostgreSQL
POSTGRES_USER=root
POSTGRES_PASSWORD=root
POSTGRES_DB=myapp

# MySQL
MYSQL_ROOT_PASSWORD=root
MYSQL_DATABASE=myapp
MYSQL_USER=myapp
MYSQL_PASSWORD=myapp
MYSQL_REPLICATION_USER=replicator
MYSQL_REPLICATION_PASSWORD=replicator
```

## Monitoring

### Check Container Health

```bash
docker-compose ps
```

### View Logs

```bash
# All containers
docker-compose logs -f

# Specific container
docker-compose logs -f postgres_primary
docker-compose logs -f mysql_primary
```

### Resource Usage

```bash
docker stats postgres_primary postgres_replica mysql_primary mysql_replica h2_container
```

## Troubleshooting

### PostgreSQL Replica Not Connecting

```bash
# Check primary logs
docker-compose logs postgres_primary

# Recreate replica
docker-compose stop postgres_replica
docker volume rm db_pg_replica_data
docker-compose up -d postgres_replica
```

### MySQL Replication Issues

```bash
# Check replica status
docker exec mysql_replica mysql -u root -proot -e "SHOW SLAVE STATUS\G"

# Reset replication
docker exec mysql_replica mysql -u root -proot -e "STOP SLAVE; RESET SLAVE ALL;"
./setup_mysql_replication.sh
```

### Port Conflicts

If ports are already in use, modify the ports in `docker-compose.yml`:

```yaml
ports:
  - "5434:5432"  # Change 5432 to 5434
```

## Performance Tuning

### PostgreSQL

Edit `postgresql.conf` to adjust:
- `shared_buffers` - 25% of available RAM
- `effective_cache_size` - 50-75% of available RAM
- `work_mem` - Adjust based on concurrent queries

### MySQL

Edit `mysql_primary.cnf` and `mysql_replica.cnf`:
- `innodb_buffer_pool_size` - 50-70% of available RAM
- `max_connections` - Based on application needs
- `tmp_table_size` and `max_heap_table_size` - For temporary tables

## Security Notes

⚠️ **This setup is for local development only!**

For production:
- Use strong passwords
- Enable SSL/TLS connections
- Implement proper firewall rules
- Use secrets management (Vault, AWS Secrets Manager)
- Enable audit logging
- Regular security updates

## Cleanup

```bash
# Stop all containers
docker-compose down

# Remove volumes (WARNING: deletes all data)
docker-compose down -v
```
