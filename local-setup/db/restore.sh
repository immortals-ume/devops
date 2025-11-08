#!/bin/bash
# Restore SQL databases from ./backups/ files
# USAGE: ./restore.sh <postgres|mysql|h2> <backup_file>
# WARNING: Use with caution! This will overwrite existing data.
set -e
BACKUP_DIR="$(dirname "$0")/backups"

if [ $# -ne 2 ]; then
  echo "Usage: $0 <postgres|mysql|h2> <backup_file>"
  echo ""
  echo "Examples:"
  echo "  $0 postgres postgres_backup_20240101_120000.sql"
  echo "  $0 mysql mysql_backup_20240101_120000.sql"
  echo "  $0 h2 h2_backup_20240101_120000"
  exit 1
fi

DB=$1
FILE=$2

case $DB in
  postgres)
    echo "Restoring PostgreSQL from $FILE..."
    if ! docker ps | grep -q postgres_primary; then
      echo "Error: postgres_primary container is not running"
      exit 1
    fi
    cat "$BACKUP_DIR/$FILE" | docker exec -i postgres_primary psql -U root
    echo "PostgreSQL restore completed."
    ;;
  mysql)
    echo "Restoring MySQL from $FILE..."
    if ! docker ps | grep -q mysql_primary; then
      echo "Error: mysql_primary container is not running"
      exit 1
    fi
    cat "$BACKUP_DIR/$FILE" | docker exec -i mysql_primary mysql -uroot -proot
    echo "MySQL restore completed."
    ;;
  h2)
    echo "Restoring H2 from $FILE..."
    if ! docker ps | grep -q h2_container; then
      echo "Error: h2_container is not running"
      exit 1
    fi
    docker cp "$BACKUP_DIR/$FILE" h2_container:/opt/h2-data
    docker restart h2_container
    echo "H2 restore completed."
    ;;
  *)
    echo "Unknown database: $DB"
    echo "Supported databases: postgres, mysql, h2"
    exit 2
    ;;
esac

echo "Restore completed successfully."
