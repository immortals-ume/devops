#!/bin/bash
# Setup MongoDB Replica Set
set -e

echo "Setting up MongoDB Replica Set..."

# Wait for primary to be ready
echo "Waiting for MongoDB primary to be ready..."
until docker exec mongo_primary mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
    echo "Waiting for MongoDB primary..."
    sleep 2
done

# Wait for secondaries
echo "Waiting for MongoDB secondaries to be ready..."
sleep 10

# Initialize replica set
echo "Initializing replica set..."
docker exec mongo_primary mongosh --eval '
rs.initiate({
  _id: "rs0",
  members: [
    { _id: 0, host: "mongo_primary:27017", priority: 2 },
    { _id: 1, host: "mongo_secondary1:27017", priority: 1 },
    { _id: 2, host: "mongo_secondary2:27017", priority: 1 }
  ]
})
'

echo "Waiting for replica set to stabilize..."
sleep 10

# Check replica set status
echo "Checking replica set status..."
docker exec mongo_primary mongosh --eval 'rs.status()'

echo ""
echo "MongoDB Replica Set setup complete!"
echo "Primary: localhost:27017"
echo "Secondary 1: localhost:27018"
echo "Secondary 2: localhost:27019"
echo ""
echo "Connection string: mongodb://admin:admin@localhost:27017,localhost:27018,localhost:27019/?replicaSet=rs0"
