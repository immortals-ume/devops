# NoSQL Databases - Local Setup

Complete NoSQL database stack with replication and clustering support.

## Databases Included

### MongoDB 7.0 (Replica Set)
- **Primary**: localhost:27017
- **Secondary 1**: localhost:27018
- **Secondary 2**: localhost:27019
- 3-node replica set with automatic failover
- User: admin / Password: admin

### Cassandra 5.0 (Cluster)
- **Node 1**: localhost:9042
- **Node 2**: localhost:9043
- 2-node cluster with replication
- CQL native protocol

### CouchDB 3.3
- **HTTP API**: http://localhost:5984
- **Admin UI**: http://localhost:5984/_utils
- User: admin / Password: admin

## Quick Start

### 1. Start All NoSQL Databases

```bash
docker-compose up -d
```

### 2. Setup MongoDB Replica Set

After containers are healthy:

```bash
./setup_mongo_replicaset.sh
```

### 3. Verify Setup

**MongoDB:**
```bash
docker exec mongo_primary mongosh --eval "rs.status()"
```

**Cassandra:**
```bash
docker exec cassandra_node1 nodetool status
```

**CouchDB:**
```bash
curl http://admin:admin@localhost:5984/_up
```

## Connection Strings

### MongoDB
```
# Single node
mongodb://admin:admin@localhost:27017/myapp

# Replica set
mongodb://admin:admin@localhost:27017,localhost:27018,localhost:27019/myapp?replicaSet=rs0
```

### Cassandra
```python
# Python example
from cassandra.cluster import Cluster
cluster = Cluster(['localhost'], port=9042)
session = cluster.connect()
```

### CouchDB
```bash
# REST API
curl -X GET http://admin:admin@localhost:5984/_all_dbs
```

## Testing

### MongoDB Replication Test

```bash
# Insert on primary
docker exec mongo_primary mongosh --eval '
  db.getSiblingDB("myapp").test.insertOne({
    message: "Hello from primary",
    timestamp: new Date()
  })
'

# Read from secondary
docker exec mongo_secondary1 mongosh --eval '
  db.getSiblingDB("myapp").setSecondaryOk();
  db.getSiblingDB("myapp").test.find().pretty()
'
```

### Cassandra Cluster Test

```bash
# Create keyspace
docker exec cassandra_node1 cqlsh -e "
  CREATE KEYSPACE IF NOT EXISTS myapp 
  WITH replication = {'class': 'SimpleStrategy', 'replication_factor': 2};
"

# Create table
docker exec cassandra_node1 cqlsh -e "
  USE myapp;
  CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    name TEXT,
    email TEXT
  );
"

# Insert data
docker exec cassandra_node1 cqlsh -e "
  USE myapp;
  INSERT INTO users (id, name, email) 
  VALUES (uuid(), 'John Doe', 'john@example.com');
"

# Query data
docker exec cassandra_node1 cqlsh -e "USE myapp; SELECT * FROM users;"
```

### CouchDB Test

```bash
# Create database
curl -X PUT http://admin:admin@localhost:5984/myapp

# Insert document
curl -X POST http://admin:admin@localhost:5984/myapp \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "email": "john@example.com"}'

# Query all documents
curl -X GET http://admin:admin@localhost:5984/myapp/_all_docs?include_docs=true
```

## Backup & Restore

### MongoDB Backup

```bash
# Backup
docker exec mongo_primary mongodump \
  --uri="mongodb://admin:admin@localhost:27017" \
  --out=/data/backup

docker cp mongo_primary:/data/backup ./backups/mongo_$(date +%Y%m%d_%H%M%S)

# Restore
docker cp ./backups/mongo_20240101_120000 mongo_primary:/data/restore
docker exec mongo_primary mongorestore \
  --uri="mongodb://admin:admin@localhost:27017" \
  /data/restore
```

### Cassandra Backup

```bash
# Snapshot
docker exec cassandra_node1 nodetool snapshot myapp

# Export snapshot location
docker exec cassandra_node1 nodetool listsnapshots
```

### CouchDB Backup

```bash
# Replicate to file
curl -X POST http://admin:admin@localhost:5984/_replicate \
  -H "Content-Type: application/json" \
  -d '{"source": "myapp", "target": "myapp_backup"}'
```

## Configuration Files

- `mongod_primary.conf` - MongoDB primary configuration
- `mongod_secondary.conf` - MongoDB secondary configuration
- `mongo_init.js` - MongoDB initialization script
- `setup_mongo_replicaset.sh` - MongoDB replica set setup

## Environment Variables

Create `.env` file:

```env
# MongoDB
MONGO_ROOT_USER=admin
MONGO_ROOT_PASSWORD=admin
MONGO_DATABASE=myapp

# Cassandra
CASSANDRA_CLUSTER_NAME=DevCluster
CASSANDRA_DC=dc1
CASSANDRA_RACK=rack1

# CouchDB
COUCHDB_USER=admin
COUCHDB_PASSWORD=admin
```

## Monitoring

### MongoDB

```bash
# Replica set status
docker exec mongo_primary mongosh --eval "rs.status()"

# Database stats
docker exec mongo_primary mongosh --eval "db.stats()"

# Current operations
docker exec mongo_primary mongosh --eval "db.currentOp()"
```

### Cassandra

```bash
# Cluster status
docker exec cassandra_node1 nodetool status

# Ring information
docker exec cassandra_node1 nodetool ring

# Performance stats
docker exec cassandra_node1 nodetool tablestats
```

### CouchDB

```bash
# Server stats
curl http://admin:admin@localhost:5984/_stats

# Active tasks
curl http://admin:admin@localhost:5984/_active_tasks
```

## Troubleshooting

### MongoDB Replica Set Issues

```bash
# Check logs
docker-compose logs mongo_primary

# Reconfigure replica set
docker exec mongo_primary mongosh --eval "rs.reconfig(rs.conf(), {force: true})"

# Reset and reinitialize
docker-compose down -v
docker-compose up -d
./setup_mongo_replicaset.sh
```

### Cassandra Node Not Joining

```bash
# Check node status
docker exec cassandra_node1 nodetool status

# Clear data and restart
docker-compose stop cassandra_node2
docker volume rm nosql_cassandra_node2_data
docker-compose up -d cassandra_node2
```

### CouchDB Connection Issues

```bash
# Check logs
docker-compose logs couchdb

# Verify service
curl -v http://localhost:5984/
```

## Performance Tuning

### MongoDB
- Adjust `wiredTiger.cacheSizeGB` in config files
- Increase `oplogSizeMB` for longer replication history
- Enable compression for storage efficiency

### Cassandra
- Tune JVM heap size (default: 1/4 of RAM)
- Adjust compaction strategy per table
- Configure appropriate replication factor

### CouchDB
- Increase `max_dbs_open` for many databases
- Tune compaction settings
- Configure appropriate view indexing

## Security Notes

⚠️ **For local development only!**

Production recommendations:
- Enable authentication and authorization
- Use SSL/TLS for connections
- Implement network segmentation
- Regular security updates
- Audit logging enabled

## Cleanup

```bash
# Stop containers
docker-compose down

# Remove all data
docker-compose down -v
```
