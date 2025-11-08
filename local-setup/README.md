# Local Development Setup

Complete infrastructure stack for local development with databases, caching, messaging, monitoring, and code quality tools.

## 📦 Components Overview

### Databases

#### SQL Databases (`db/`)
- **PostgreSQL 16.2** - Primary + Replica (ports 5432, 5433)
- **MySQL 8.4** - Primary + Replica (ports 3306, 3307)
- **MariaDB 11.4** - Primary + Replica (ports 3308, 3309)
- **SQL Server 2022** - Developer Edition (port 1433)
- **Oracle XE 21c** - Express Edition (port 1521)

#### NoSQL Databases (`nosql/`)
- **MongoDB 7.0** - 3-node replica set (ports 27017-27019)
- **Cassandra 5.0** - 2-node cluster (ports 9042-9043)
- **CouchDB 3.3** - Single instance with web UI (port 5984)

#### In-Memory Databases (`inmemory/`)
- **H2 2.2** - SQL in-memory database (ports 8082, 9092)
- **Apache Ignite 2.16** - Distributed computing (port 10800)
- **Hazelcast 5.3** - Distributed data grid (port 5701)
- **Memcached 1.6** - Key-value cache (port 11212)

### Caching & Messaging

#### Redis Cache (`cache/`)
- **Standalone** - Single instance (port 6379)
- **Cluster** - 6-node cluster (ports 7000-7005)
- **Sentinel** - HA with 3 sentinels (ports 6380-6382, 26379-26381)
- **Redis Commander** - Web UI (port 8081)

#### Message Brokers (`queue/`)
- **Kafka 7.5.3** - 3-broker cluster (ports 9092-9094)
- **Zookeeper 7.5.3** - Coordination service (port 2181)
- **Kafdrop** - Kafka Web UI (port 9000)
- **RabbitMQ 3.12** - AMQP broker (ports 5672, 15672)
- **ActiveMQ 5.18.3** - JMS broker (ports 61616, 8161)

### Observability & Security

#### Monitoring Stack (`observability/`)
- **Prometheus 2.48** - Metrics collection (port 9090)
- **Alertmanager 0.26** - Alert management (port 9093)
- **Grafana 10.2** - Visualization (port 3000)
- **Loki 2.9** - Log aggregation (port 3100)
- **Promtail 2.9** - Log shipper
- **Tempo 2.3** - Distributed tracing (ports 3200, 4317, 4318, 9411)
- **Jaeger 1.52** - Tracing UI (port 16686)
- **Node Exporter** - System metrics (port 9100)
- **cAdvisor** - Container metrics (port 8080)

#### Secrets Management (`vault/`)
- **HashiCorp Vault 1.15** - Secrets management (port 8200)
- **Vault UI** - Alternative web interface (port 8000)
- **Consul 1.17** - Service discovery (port 8500)

#### Code Quality (`sonarqube/`)
- **SonarQube 10.3** - Code analysis (port 9000)
- **PostgreSQL 15** - SonarQube database
- **SonarScanner CLI** - Code scanner

## 🚀 Quick Start

### Prerequisites

- Docker Desktop or Docker Engine + Docker Compose
- At least 16GB RAM available for Docker
- 50GB free disk space

### Start All Services

```bash
# From project root
make up-all

# Or start individual services
make up-db              # SQL databases
make up-nosql           # NoSQL databases
make up-inmemory        # In-memory databases
make up-cache           # Redis
make up-queue           # Message brokers
make up-observability   # Monitoring stack
make up-vault           # Secrets management
make up-sonarqube       # Code quality
```

### Stop All Services

```bash
make down
```

### Remove All Data

```bash
make clean
```

## 📋 Service Access

### Web Interfaces

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | - |
| Alertmanager | http://localhost:9093 | - |
| Jaeger | http://localhost:16686 | - |
| Kafdrop (Kafka) | http://localhost:9000 | - |
| RabbitMQ | http://localhost:15672 | admin/admin |
| ActiveMQ | http://localhost:8161 | admin/admin |
| Redis Commander | http://localhost:8081 | - |
| Vault | http://localhost:8200 | token: root |
| Consul | http://localhost:8500 | - |
| SonarQube | http://localhost:9000 | admin/admin |
| CouchDB | http://localhost:5984/_utils | admin/admin |
| H2 Console | http://localhost:8082 | sa/(empty) |
| cAdvisor | http://localhost:8080 | - |

### Database Connections

#### SQL Databases

**PostgreSQL:**
```
Host: localhost
Port: 5432 (primary), 5433 (replica)
User: root
Password: root
Database: myapp
```

**MySQL:**
```
Host: localhost
Port: 3306 (primary), 3307 (replica)
User: root
Password: root
Database: myapp
```

**MariaDB:**
```
Host: localhost
Port: 3308 (primary), 3309 (replica)
User: root
Password: root
Database: myapp
```

**SQL Server:**
```
Host: localhost
Port: 1433
User: sa
Password: YourStrong@Passw0rd
Database: myapp
```

**Oracle:**
```
Host: localhost
Port: 1521
User: myapp
Password: myapp
SID: MYAPP
```

#### NoSQL Databases

**MongoDB:**
```
Connection String: mongodb://admin:admin@localhost:27017,localhost:27018,localhost:27019/?replicaSet=rs0
```

**Cassandra:**
```
Host: localhost
Port: 9042
```

**CouchDB:**
```
URL: http://admin:admin@localhost:5984
```

#### In-Memory Databases

**H2:**
```
JDBC URL: jdbc:h2:tcp://localhost:9092/mem:testdb
User: sa
Password: (empty)
```

**Ignite:**
```
Host: localhost
Port: 10800
```

**Hazelcast:**
```
Host: localhost
Port: 5701
```

**Memcached:**
```
Host: localhost
Port: 11212
```

#### Cache

**Redis Standalone:**
```
Host: localhost
Port: 6379
```

**Redis Cluster:**
```
Nodes: localhost:7000-7005
```

**Redis Sentinel:**
```
Master: localhost:6380
Sentinels: localhost:26379-26381
```

#### Message Brokers

**Kafka:**
```
Bootstrap Servers: localhost:9092,localhost:9093,localhost:9094
```

**RabbitMQ:**
```
Host: localhost
Port: 5672 (AMQP)
Management: http://localhost:15672
User: admin
Password: admin
```

**ActiveMQ:**
```
OpenWire: tcp://localhost:61616
AMQP: tcp://localhost:5671
STOMP: tcp://localhost:61613
MQTT: tcp://localhost:1883
User: admin
Password: admin
```

## 🔧 Configuration

### Environment Variables

Each service has a `.env.example` file. Copy and customize:

```bash
# For each service
cd local-setup/db
cp .env.example .env
# Edit .env with your values

cd local-setup/nosql
cp .env.example .env
# Edit .env with your values

# Repeat for other services...
```

### Setup Scripts

#### Database Replication

```bash
# SQL databases
cd local-setup/db
make setup-mysql-replication
make setup-mariadb-replication

# NoSQL databases
cd local-setup/nosql
make setup-mongo
```

#### Redis Cluster

```bash
cd local-setup/cache
make setup-cluster
```

#### Vault Initialization

```bash
cd local-setup/vault
make init
```

## 📊 Monitoring & Observability

### Grafana Dashboards

Pre-configured datasources:
- Prometheus (metrics)
- Loki (logs)
- Tempo (traces)
- Jaeger (traces)

Import recommended dashboards:
- Node Exporter Full: 1860
- Docker Container & Host: 179
- PostgreSQL: 9628
- MySQL: 7362
- Redis: 11835

### Prometheus Targets

All services are automatically scraped:
- Databases (PostgreSQL, MySQL, Redis)
- Message brokers (Kafka)
- System metrics (Node Exporter)
- Container metrics (cAdvisor)
- Observability stack itself

### Log Aggregation

Promtail automatically collects logs from:
- Docker containers
- System logs
- Application logs

Query logs in Grafana using LogQL.

### Distributed Tracing

Send traces to Tempo via:
- OTLP gRPC: localhost:4317
- OTLP HTTP: localhost:4318
- Zipkin: localhost:9411
- Jaeger: localhost:14268

View traces in Jaeger UI or Grafana.

## 🧪 Testing

### Test Individual Services

```bash
# SQL databases
cd local-setup/db
make test-postgres
make test-mysql
make test-mariadb
make test-mssql
make test-oracle

# NoSQL databases
cd local-setup/nosql
make test-mongo
make test-cassandra
make test-couchdb

# In-memory databases
cd local-setup/inmemory
make test-h2
make test-ignite
make test-hazelcast
make test-memcached

# Cache
cd local-setup/cache
make test-standalone
make test-cluster
make test-sentinel

# Message brokers
cd local-setup/queue
make test-kafka
make test-rabbitmq
make test-activemq

# Observability
cd local-setup/observability
make test-prometheus
make test-loki
make test-tempo

# Vault
cd local-setup/vault
make test

# SonarQube
cd local-setup/sonarqube
make test
```

## 🔒 Security Notes

⚠️ **This setup is for LOCAL DEVELOPMENT ONLY!**

**Never use in production without:**
- Changing all default passwords
- Enabling SSL/TLS
- Implementing proper authentication
- Setting up network isolation
- Enabling audit logging
- Regular security updates
- Proper backup strategies
- Secrets management

## 📦 Backup & Restore

### Backup All Databases

```bash
# SQL databases
cd local-setup/db
./backup.sh

# NoSQL databases
cd local-setup/nosql
# See README for specific backup commands

# SonarQube
cd local-setup/sonarqube
# See README for backup commands
```

### Restore Databases

```bash
# SQL databases
cd local-setup/db
./restore.sh postgres postgres_backup_20240101_120000.sql
./restore.sh mysql mysql_backup_20240101_120000.sql

# See individual service READMEs for detailed restore procedures
```

## 🐛 Troubleshooting

### Services Won't Start

**Check Docker resources:**
```bash
docker info
docker stats
```

**Increase Docker memory:**
- Docker Desktop → Settings → Resources
- Minimum: 16GB RAM recommended

**Check system limits (Linux):**
```bash
# Required for Elasticsearch (SonarQube, Observability)
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536
```

### Port Conflicts

**Check what's using a port:**
```bash
lsof -i :9000  # Replace with your port
```

**Change port in docker-compose.yml:**
```yaml
ports:
  - "9001:9000"  # Change external port
```

### Database Connection Issues

**Check if service is running:**
```bash
docker-compose ps
```

**Check logs:**
```bash
docker-compose logs <service-name>
```

**Test connectivity:**
```bash
# PostgreSQL
docker exec postgres_primary psql -U root -c "SELECT 1"

# MySQL
docker exec mysql_primary mysql -u root -proot -e "SELECT 1"

# Redis
docker exec redis_standalone redis-cli ping
```

### Performance Issues

**Check resource usage:**
```bash
docker stats
```

**Adjust resource limits in docker-compose.yml:**
```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
```

## 📚 Documentation

Each service has detailed documentation in its README:

- [SQL Databases](db/README.md)
- [NoSQL Databases](nosql/README.md)
- [In-Memory Databases](inmemory/README.md)
- [Redis Cache](cache/README.md)
- [Message Brokers](queue/README.md)
- [Observability Stack](observability/README.md)
- [Secrets Management](vault/README.md)
- [Code Quality](sonarqube/README.md)

## 🛠️ Makefile Commands

### Root Level

```bash
make help              # Show all commands
make up-all            # Start all services
make down              # Stop all services
make clean             # Remove all volumes
```

### Service Level

Each service directory has its own Makefile:

```bash
cd local-setup/<service>
make help              # Show service-specific commands
make up                # Start service
make down              # Stop service
make logs              # View logs
make ps                # Show status
make test              # Test service
make clean             # Remove data
```

## 🔄 Updates & Maintenance

### Update Images

```bash
# Pull latest images
docker-compose pull

# Restart services
docker-compose up -d
```

### Clean Up Unused Resources

```bash
# Remove unused containers
docker container prune

# Remove unused images
docker image prune -a

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Clean everything
docker system prune -a --volumes
```

## 💡 Tips & Best Practices

### Resource Management

- Start only services you need
- Stop services when not in use
- Monitor resource usage regularly
- Clean up unused volumes periodically

### Development Workflow

1. Start required services: `make up-db up-cache`
2. Develop your application
3. Use observability stack for debugging
4. Run code quality checks with SonarQube
5. Stop services when done: `make down`

### Data Persistence

- Data persists in Docker volumes
- Use `make down` to stop without losing data
- Use `make clean` only when you want to reset everything

### Network Connectivity

All services are on isolated networks:
- `backend` - SQL databases
- `nosql` - NoSQL databases
- `inmemory` - In-memory databases
- `redis` - Redis cache
- `messaging` - Message brokers
- `observability` - Monitoring stack
- `secrets` - Vault and Consul
- `sonarqube` - SonarQube

Services can communicate within their networks using container names.

## 🤝 Contributing

When adding new services:

1. Create directory in `local-setup/`
2. Add `docker-compose.yml`
3. Add configuration files
4. Create comprehensive `README.md`
5. Add `Makefile` with standard commands
6. Add `.env.example`
7. Update this README
8. Update root `Makefile`

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For issues or questions:
1. Check service-specific README
2. Check Docker logs: `docker-compose logs <service>`
3. Verify system requirements
4. Check GitHub issues

## 🎯 What's Next?

- Cloud deployment configurations in `cloud/` directory
- Kubernetes manifests in `k8s/` directory
- Helm charts in `helm-app/` directory
- Terraform modules in `terraform/` directory

---

**Happy Coding! 🚀**
