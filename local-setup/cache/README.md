# Redis Cache - Local Setup

Complete Redis setup with standalone, cluster, and sentinel configurations for high availability and scalability.

## Configurations Included

### Redis Standalone
- **Port**: localhost:6379
- Single instance with persistence
- Perfect for development and testing
- 256MB memory limit

### Redis Cluster (6 nodes)
- **Ports**: 7000-7005
- 3 master nodes + 3 replica nodes
- Automatic sharding and failover
- High availability and scalability
- 128MB per node

### Redis Sentinel (High Availability)
- **Master**: localhost:6380
- **Replica 1**: localhost:6381
- **Replica 2**: localhost:6382
- **Sentinels**: localhost:26379-26381
- Automatic failover
- Master-replica replication

### Redis Commander (Web UI)
- **URL**: http://localhost:8081
- Web-based management interface
- Supports all Redis configurations

## Quick Start

### 1. Start All Redis Services

```bash
docker-compose up -d
```

### 2. Setup Redis Cluster

After containers are healthy:

```bash
./setup_cluster.sh
```

Sentinel configuration is automatic.

### 3. Access Redis Commander

Open http://localhost:8081 in your browser to manage all Redis instances.

## Connection Examples

### Standalone

```bash
# CLI
redis-cli -h localhost -p 6379

# Connection string
redis://localhost:6379
```

**Python:**
```python
import redis
r = redis.Redis(host='localhost', port=6379, decode_responses=True)
r.set('key', 'value')
print(r.get('key'))
```

### Cluster

```bash
# CLI
redis-cli -c -h localhost -p 7000

# Connection string
redis://localhost:7000,localhost:7001,localhost:7002
```

**Python:**
```python
from redis.cluster import RedisCluster
rc = RedisCluster(host='localhost', port=7000, decode_responses=True)
rc.set('key', 'value')
print(rc.get('key'))
```

### Sentinel

```bash
# CLI (connect to master via sentinel)
redis-cli -h localhost -p 26379 sentinel get-master-addr-by-name mymaster

# Connection string
redis-sentinel://localhost:26379,localhost:26380,localhost:26381/mymaster
```

**Python:**
```python
from redis.sentinel import Sentinel
sentinel = Sentinel([('localhost', 26379), ('localhost', 26380), ('localhost', 26381)])
master = sentinel.master_for('mymaster', decode_responses=True)
master.set('key', 'value')
print(master.get('key'))
```

## Testing

### Test Standalone

```bash
# Set and get value
docker exec redis_standalone redis-cli set test "Hello Redis"
docker exec redis_standalone redis-cli get test

# Check info
docker exec redis_standalone redis-cli info replication
```

### Test Cluster

```bash
# Set values (will be distributed across shards)
docker exec redis_cluster_1 redis-cli -c -p 7000 set key1 "value1"
docker exec redis_cluster_1 redis-cli -c -p 7000 set key2 "value2"
docker exec redis_cluster_1 redis-cli -c -p 7000 set key3 "value3"

# Get values
docker exec redis_cluster_1 redis-cli -c -p 7000 get key1

# Check cluster info
docker exec redis_cluster_1 redis-cli -p 7000 cluster info
docker exec redis_cluster_1 redis-cli -p 7000 cluster nodes
```

### Test Sentinel Failover

```bash
# Check current master
docker exec sentinel1 redis-cli -p 26379 sentinel get-master-addr-by-name mymaster

# Simulate master failure
docker stop redis_sentinel_master

# Wait for failover (5-10 seconds)
sleep 10

# Check new master
docker exec sentinel1 redis-cli -p 26379 sentinel get-master-addr-by-name mymaster

# Restart old master (becomes replica)
docker start redis_sentinel_master
```

## Monitoring

### Check Status

```bash
# All containers
docker-compose ps

# Standalone
docker exec redis_standalone redis-cli info stats

# Cluster
docker exec redis_cluster_1 redis-cli -p 7000 cluster info

# Sentinel
docker exec sentinel1 redis-cli -p 26379 sentinel masters
```

### Performance Metrics

```bash
# Standalone metrics
docker exec redis_standalone redis-cli info stats
docker exec redis_standalone redis-cli info memory
docker exec redis_standalone redis-cli info cpu

# Cluster metrics
docker exec redis_cluster_1 redis-cli -p 7000 info stats

# Slow queries
docker exec redis_standalone redis-cli slowlog get 10
```

## Configuration Files

- `redis_standalone.conf` - Standalone Redis configuration
- `redis_cluster.conf` - Cluster node configuration
- `redis_sentinel_master.conf` - Sentinel master configuration
- `redis_sentinel_replica.conf` - Sentinel replica configuration
- `sentinel.conf` - Sentinel monitoring configuration
- `setup_cluster.sh` - Cluster initialization script

## Common Operations

### Flush Data

```bash
# Standalone
docker exec redis_standalone redis-cli flushall

# Cluster (flush all nodes)
for port in 7000 7001 7002 7003 7004 7005; do
    docker exec redis_cluster_1 redis-cli -p $port flushall
done

# Sentinel master
docker exec redis_sentinel_master redis-cli flushall
```

### Backup Data

```bash
# Standalone
docker exec redis_standalone redis-cli bgsave
docker cp redis_standalone:/data/dump.rdb ./backups/standalone_dump.rdb

# Cluster nodes
for i in 1 2 3 4 5 6; do
    docker exec redis_cluster_$i redis-cli -p 700$((i-1)) bgsave
done
```

### Restore Data

```bash
# Stop Redis
docker-compose stop redis_standalone

# Copy backup
docker cp ./backups/standalone_dump.rdb redis_standalone:/data/dump.rdb

# Start Redis
docker-compose start redis_standalone
```

## Troubleshooting

### Cluster Not Forming

```bash
# Check node status
docker exec redis_cluster_1 redis-cli -p 7000 cluster nodes

# Reset cluster if needed
for port in 7000 7001 7002 7003 7004 7005; do
    docker exec redis_cluster_1 redis-cli -p $port cluster reset
done

# Re-run setup
./setup_cluster.sh
```

### Sentinel Not Detecting Master

```bash
# Check sentinel status
docker exec sentinel1 redis-cli -p 26379 sentinel masters

# Check sentinel logs
docker-compose logs sentinel1

# Reset sentinel
docker exec sentinel1 redis-cli -p 26379 sentinel reset mymaster
```

### Connection Issues

```bash
# Check if Redis is running
docker exec redis_standalone redis-cli ping

# Check network
docker network inspect cache_redis

# Check logs
docker-compose logs redis_standalone
```

## Performance Tuning

### Standalone
- Adjust `maxmemory` based on available RAM
- Use `maxmemory-policy` appropriate for use case
- Enable `appendonly` for durability

### Cluster
- Distribute keys evenly across shards
- Monitor slot distribution
- Adjust `cluster-node-timeout` for network latency

### Sentinel
- Set appropriate `down-after-milliseconds`
- Configure `parallel-syncs` based on load
- Monitor failover frequency

## Security Notes

⚠️ **For local development only!**

Production recommendations:
- Enable `requirepass` for authentication
- Use `protected-mode yes`
- Enable TLS/SSL encryption
- Implement network isolation
- Regular security updates
- Monitor access logs

## Use Cases

### Standalone
- Development and testing
- Simple caching
- Session storage
- Rate limiting

### Cluster
- Large datasets (> 1GB)
- High throughput applications
- Horizontal scaling
- Multi-tenant applications

### Sentinel
- High availability requirements
- Automatic failover
- Production deployments
- Mission-critical applications

## Cleanup

```bash
# Stop all containers
docker-compose down

# Remove all data
docker-compose down -v
```

## Integration Examples

### Spring Boot

```yaml
spring:
  redis:
    # Standalone
    host: localhost
    port: 6379
    
    # Cluster
    cluster:
      nodes:
        - localhost:7000
        - localhost:7001
        - localhost:7002
    
    # Sentinel
    sentinel:
      master: mymaster
      nodes:
        - localhost:26379
        - localhost:26380
        - localhost:26381
```

### Node.js

```javascript
const redis = require('redis');

// Standalone
const client = redis.createClient({
  host: 'localhost',
  port: 6379
});

// Cluster
const cluster = require('redis-clustr');
const clusterClient = new cluster({
  servers: [
    { host: 'localhost', port: 7000 },
    { host: 'localhost', port: 7001 },
    { host: 'localhost', port: 7002 }
  ]
});
```
