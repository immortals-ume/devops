# In-Memory Databases - Local Setup

High-performance in-memory data stores for caching, distributed computing, and fast data access.

## Databases Included

### H2 Database 2.2
- **Web Console**: http://localhost:8082
- **TCP Server**: localhost:9092
- Lightweight SQL database with in-memory mode
- Perfect for testing and development

### Apache Ignite 2.16
- **Thin Client**: localhost:10800
- **REST API**: localhost:8080
- **Discovery**: localhost:47500
- Distributed in-memory computing platform
- SQL support with ACID transactions

### Hazelcast 5.3
- **Member Port**: localhost:5701
- **Health Check**: http://localhost:5701/hazelcast/health
- Distributed in-memory data grid
- Built-in clustering and replication

### Memcached 1.6
- **Port**: localhost:11212
- Simple key-value cache
- High-performance, distributed memory object caching

## Quick Start

### Start All In-Memory Databases

```bash
docker-compose up -d
```

### Verify Services

```bash
# Check all containers
docker-compose ps

# H2 Console
open http://localhost:8082

# Hazelcast Health
curl http://localhost:5701/hazelcast/health/ready

# Memcached
echo "stats" | nc localhost 11212
```

## Usage Examples

### H2 Database

**JDBC Connection:**
```
jdbc:h2:tcp://localhost:9092/mem:testdb
User: sa
Password: (empty)
```

**Web Console:**
1. Open http://localhost:8082
2. Select "Generic H2 (Server)"
3. JDBC URL: `jdbc:h2:tcp://localhost:9092/mem:testdb`
4. Click "Connect"

### Apache Ignite

**Java Example:**
```java
import org.apache.ignite.Ignition;
import org.apache.ignite.client.ClientCache;
import org.apache.ignite.client.IgniteClient;
import org.apache.ignite.configuration.ClientConfiguration;

ClientConfiguration cfg = new ClientConfiguration()
    .setAddresses("localhost:10800");

try (IgniteClient client = Ignition.startClient(cfg)) {
    ClientCache<Integer, String> cache = client.getOrCreateCache("myCache");
    cache.put(1, "Hello Ignite");
    System.out.println(cache.get(1));
}
```

**SQL Example:**
```bash
docker exec ignite_inmemory /opt/ignite/bin/sqlline.sh -u jdbc:ignite:thin://localhost:10800
```

### Hazelcast

**Java Example:**
```java
import com.hazelcast.client.HazelcastClient;
import com.hazelcast.client.config.ClientConfig;
import com.hazelcast.core.HazelcastInstance;
import com.hazelcast.map.IMap;

ClientConfig config = new ClientConfig();
config.getNetworkConfig().addAddress("localhost:5701");

HazelcastInstance client = HazelcastClient.newHazelcastClient(config);
IMap<String, String> map = client.getMap("myMap");
map.put("key", "value");
System.out.println(map.get("key"));
```

**REST API:**
```bash
# Get cluster state
curl http://localhost:5701/hazelcast/rest/management/cluster/state

# Put value
curl -X POST http://localhost:5701/hazelcast/rest/maps/myMap/key1 \
  -d "value1"

# Get value
curl http://localhost:5701/hazelcast/rest/maps/myMap/key1
```

### Memcached

**Python Example:**
```python
import memcache

mc = memcache.Client(['localhost:11212'])
mc.set("key", "value")
print(mc.get("key"))
```

**Telnet Commands:**
```bash
telnet localhost 11212

# Set value
set mykey 0 0 5
hello
STORED

# Get value
get mykey
VALUE mykey 0 5
hello
END

# Stats
stats
```

## Testing Performance

### H2 Benchmark

```sql
-- Create table
CREATE TABLE benchmark (
  id INT PRIMARY KEY,
  data VARCHAR(255)
);

-- Insert test data
INSERT INTO benchmark 
SELECT x, 'test_' || x 
FROM SYSTEM_RANGE(1, 100000);

-- Query performance
SELECT COUNT(*) FROM benchmark WHERE id < 50000;
```

### Ignite Benchmark

```bash
docker exec ignite_inmemory /opt/ignite/bin/control.sh --baseline
```

### Hazelcast Benchmark

```bash
# Check cluster stats
curl http://localhost:5701/hazelcast/health/cluster-state
```

### Memcached Benchmark

```bash
# Using memcached-tool
docker exec memcached_inmemory sh -c 'echo "stats" | nc localhost 11211'
```

## Configuration Files

- `ignite_config.xml` - Apache Ignite configuration
- `hazelcast.yaml` - Hazelcast configuration

## Environment Variables

Create `.env` file:

```env
# Hazelcast
HZ_CLUSTER_NAME=dev
```

## Monitoring

### H2 Database

```bash
# Check active connections
docker exec h2_inmemory sh -c 'echo "SELECT * FROM INFORMATION_SCHEMA.SESSIONS;" | java -cp /opt/h2/bin/h2*.jar org.h2.tools.Shell -url jdbc:h2:tcp://localhost:9092/mem:testdb'
```

### Apache Ignite

```bash
# Cluster state
docker exec ignite_inmemory /opt/ignite/bin/control.sh --state

# Cache list
docker exec ignite_inmemory /opt/ignite/bin/control.sh --cache list

# Baseline topology
docker exec ignite_inmemory /opt/ignite/bin/control.sh --baseline
```

### Hazelcast

```bash
# Health check
curl http://localhost:5701/hazelcast/health

# Cluster state
curl http://localhost:5701/hazelcast/rest/management/cluster/state

# Member list
docker exec hazelcast_inmemory hz-cli -t dev@localhost:5701
```

### Memcached

```bash
# Statistics
echo "stats" | nc localhost 11212

# Items
echo "stats items" | nc localhost 11212

# Slabs
echo "stats slabs" | nc localhost 11212
```

## Use Cases

### H2
- Unit testing with in-memory database
- Embedded database for applications
- Quick prototyping

### Apache Ignite
- Distributed caching
- In-memory SQL queries
- Stream processing
- Distributed computing

### Hazelcast
- Session clustering
- Distributed caching
- Pub/sub messaging
- Distributed locks

### Memcached
- Simple key-value caching
- Session storage
- Query result caching
- Rate limiting

## Performance Tuning

### H2
- Use in-memory mode for maximum speed
- Disable logging for better performance
- Adjust cache size

### Apache Ignite
- Tune data region size in config
- Enable persistence if needed
- Configure appropriate backup count

### Hazelcast
- Adjust JVM heap size
- Configure eviction policies
- Set appropriate backup count

### Memcached
- Increase memory limit (-m flag)
- Adjust max connections (-c flag)
- Monitor hit/miss ratio

## Troubleshooting

### H2 Connection Issues

```bash
# Check if server is running
docker exec h2_inmemory ps aux | grep h2

# Restart container
docker-compose restart h2
```

### Ignite Not Starting

```bash
# Check logs
docker-compose logs ignite

# Increase memory
# Edit docker-compose.yml: JVM_OPTS: "-Xms1g -Xmx2g"
```

### Hazelcast Cluster Issues

```bash
# Check member status
docker exec hazelcast_inmemory hz-cli -t dev@localhost:5701

# Clear data
docker-compose restart hazelcast
```

### Memcached Connection Refused

```bash
# Check if running
docker exec memcached_inmemory sh -c 'echo "version" | nc localhost 11211'

# Restart
docker-compose restart memcached
```

## Security Notes

⚠️ **For local development only!**

Production recommendations:
- Enable authentication where supported
- Use network isolation
- Implement access controls
- Regular security updates
- Monitor access logs

## Cleanup

```bash
# Stop containers
docker-compose down

# Remove all data
docker-compose down -v
```

## Integration Examples

### Spring Boot with H2

```yaml
spring:
  datasource:
    url: jdbc:h2:tcp://localhost:9092/mem:testdb
    driver-class-name: org.h2.Driver
  h2:
    console:
      enabled: true
```

### Spring Boot with Hazelcast

```yaml
spring:
  hazelcast:
    config: classpath:hazelcast-client.yaml
```

### Node.js with Memcached

```javascript
const Memcached = require('memcached');
const memcached = new Memcached('localhost:11212');

memcached.set('key', 'value', 3600, (err) => {
  memcached.get('key', (err, data) => {
    console.log(data);
  });
});
```
