#!/bin/bash
# Setup MariaDB Replication
set -e

echo "Setting up MariaDB replication..."

# Wait for primary to be ready
echo "Waiting for MariaDB primary to be ready..."
until docker exec mariadb_primary mariadb-admin ping -h localhost -u root -proot --silent; do
    echo "Waiting for MariaDB primary..."
    sleep 2
done

# Wait for replica to be ready
echo "Waiting for MariaDB replica to be ready..."
until docker exec mariadb_replica mariadb-admin ping -h localhost -u root -proot --silent; do
    echo "Waiting for MariaDB replica..."
    sleep 2
done

# Get master status
echo "Getting primary status..."
MASTER_STATUS=$(docker exec mariadb_primary mariadb -u root -proot -e "SHOW MASTER STATUS\G")
echo "$MASTER_STATUS"

# Configure replica
echo "Configuring replica..."
docker exec mariadb_replica mariadb -u root -proot <<-EOSQL
    STOP SLAVE;
    CHANGE MASTER TO
        MASTER_HOST='mariadb_primary',
        MASTER_PORT=3306,
        MASTER_USER='replicator',
        MASTER_PASSWORD='replicator',
        MASTER_USE_GTID=slave_pos;
    START SLAVE;
EOSQL

# Check replica status
echo "Checking replica status..."
sleep 3
docker exec mariadb_replica mariadb -u root -proot -e "SHOW SLAVE STATUS\G"

echo "MariaDB replication setup complete!"
echo "To verify replication is working:"
echo "  docker exec mariadb_replica mariadb -u root -proot -e 'SHOW SLAVE STATUS\G' | grep 'Slave_IO_Running\\|Slave_SQL_Running'"
