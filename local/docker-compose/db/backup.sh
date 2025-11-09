#!/bin/bash
# Backup all SQL databases to ./backups/ with timestamped files
set -e
BACKUP_DIR="$(dirname "$0")/backups"
mkdir -p "$BACKUP_DIR"
DATE=$(date +"%Y%m%d_%H%M%S")

echo "Starting database backups..."

# PostgreSQL
if docker ps | grep -q postgres_primary; then
  echo "Backing up PostgreSQL..."
  docker exec postgres_primary pg_dumpall -U root > "$BACKUP_DIR/postgres_backup_$DATE.sql"
  echo "PostgreSQL backup completed: postgres_backup_$DATE.sql"
fi

# MySQL
if docker ps | grep -q mysql_primary; then
  echo "Backing up MySQL..."
  docker exec mysql_primary mysqldump --all-databases -uroot -proot > "$BACKUP_DIR/mysql_backup_$DATE.sql"
  echo "MySQL backup completed: mysql_backup_$DATE.sql"
fi

# MariaDB
if docker ps | grep -q mariadb_primary; then
  echo "Backing up MariaDB..."
  docker exec mariadb_primary mariadb-dump --all-databases -uroot -proot > "$BACKUP_DIR/mariadb_backup_$DATE.sql"
  echo "MariaDB backup completed: mariadb_backup_$DATE.sql"
fi

# SQL Server
if docker ps | grep -q mssql_server; then
  echo "Backing up SQL Server..."
  docker exec mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' \
    -Q "BACKUP DATABASE myapp TO DISK = '/var/opt/mssql/backup_$DATE.bak'"
  docker cp mssql_server:/var/opt/mssql/backup_$DATE.bak "$BACKUP_DIR/mssql_backup_$DATE.bak"
  echo "SQL Server backup completed: mssql_backup_$DATE.bak"
fi

# Oracle
if docker ps | grep -q oracle_xe; then
  echo "Backing up Oracle..."
  docker exec oracle_xe expdp myapp/myapp@MYAPP directory=DATA_PUMP_DIR dumpfile=backup_$DATE.dmp logfile=backup_$DATE.log
  docker cp oracle_xe:/opt/oracle/admin/XE/dpdump/backup_$DATE.dmp "$BACKUP_DIR/oracle_backup_$DATE.dmp" 2>/dev/null || echo "Oracle backup may require additional configuration"
fi

echo ""
echo "All backups completed in $BACKUP_DIR"
echo "Backup files:"
ls -lh "$BACKUP_DIR" | grep "$DATE" 