#!/bin/bash
# Backup all databases to ./backups/ with timestamped files
set -e
BACKUP_DIR="$(dirname "$0")/../backups"
mkdir -p "$BACKUP_DIR"
DATE=$(date +"%Y%m%d_%H%M%S")

# MySQL
if docker ps | grep -q mysql_container; then
  echo "Backing up MySQL..."
  docker exec mysql_container sh -c 'exec mysqldump --all-databases -uroot -p"$(cat /run/secrets/mysql_root_password)"' > "$BACKUP_DIR/mysql_backup_$DATE.sql"
fi

# MongoDB Read
if docker ps | grep -q mongodb_read_container; then
  echo "Backing up MongoDB (read)..."
  docker exec mongodb_read_container mongodump --archive="/data/db/mongo_backup_$DATE.archive"
  docker cp mongodb_read_container:/data/db/mongo_backup_$DATE.archive "$BACKUP_DIR/mongo_backup_$DATE.archive"
  docker exec mongodb_read_container rm "/data/db/mongo_backup_$DATE.archive"
fi

# PostgreSQL
if docker ps | grep -q postgres_primary; then
  echo "Backing up PostgreSQL..."
  docker exec postgres_primary pg_dumpall -U user > "$BACKUP_DIR/postgres_backup_$DATE.sql"
fi

echo "All backups completed in $BACKUP_DIR" 