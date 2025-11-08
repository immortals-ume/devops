#!/bin/bash
# Setup MySQL Replication
# Run this script after both MySQL containers are up and healthy

set -e

echo "Setting up MySQL replication..."

# Wait for primary to be ready
echo "Waiting for MySQL primary to be ready..."
until docker exec mysql_primary mysqladmin ping -h localhost -u root -proot --silent; do
    echo "Waiting for MySQL primary..."
    sleep 2
done

# Wait for replica to be ready
echo "Waiting for MySQL replica to be ready..."
until docker exec mysql_replica mysqladmin ping -h localhost -u root -proot --silent; do
    echo "Waiting for MySQL replica..."
    sleep 2
done

# Get master status
echo "Getting primary status..."
MASTER_STATUS=$(docker exec mysql_primary mysql -u root -proot -e "SHOW MASTER STATUS\G")
echo "$MASTER_STATUS"

# Configure replica
echo "Configuring replica..."
docker exec mysql_replica mysql -u root -proot <<-EOSQL
    STOP SLAVE;
    CHANGE MASTER TO
        MASTER_HOST='mysql_primary',
        MASTER_PORT=3306,
        MASTER_USER='replicator',
        MASTER_PASSWORD='replicator',
        MASTER_AUTO_POSITION=1;
    START SLAVE;
EOSQL

# Check replica status
echo "Checking replica status..."
sleep 3
docker exec mysql_replica mysql -u root -proot -e "SHOW SLAVE STATUS\G"

echo "MySQL replication setup complete!"
echo "To verify replication is working:"
echo "  docker exec mysql_replica mysql -u root -proot -e 'SHOW SLAVE STATUS\G' | grep 'Slave_IO_Running\\|Slave_SQL_Running'"
