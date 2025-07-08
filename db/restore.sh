#!/bin/bash
# Restore all databases from ./backups/ files
# USAGE: ./restore.sh <mysql|mongo|postgres> <backup_file>
# WARNING: Use with caution in production! This will overwrite existing data.
set -e
BACKUP_DIR="$(dirname "$0")/../backups"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <mysql|mongo|postgres> <backup_file>"
  exit 1
fi

DB=$1
FILE=$2

case $DB in
  mysql)
    echo "Restoring MySQL from $FILE..."
    cat "$BACKUP_DIR/$FILE" | docker exec -i mysql_container sh -c 'mysql -uroot -p"$(cat /run/secrets/mysql_root_password)"'
    ;;
  mongo)
    echo "Restoring MongoDB from $FILE..."
    docker cp "$BACKUP_DIR/$FILE" mongodb_read_container:/data/db/restore.archive
    docker exec mongodb_read_container mongorestore --archive="/data/db/restore.archive" --drop
    docker exec mongodb_read_container rm /data/db/restore.archive
    ;;
  postgres)
    echo "Restoring PostgreSQL from $FILE..."
    cat "$BACKUP_DIR/$FILE" | docker exec -i postgres_primary psql -U user
    ;;
  *)
    echo "Unknown database: $DB"
    exit 2
    ;;
esac

echo "Restore completed." 