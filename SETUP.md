# Infrastructure DevOps - Setup Guide

Complete setup guide for local development infrastructure and cloud deployment.

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start](#quick-start)
3. [Local Development Setup](#local-development-setup)
4. [Configuration](#configuration)
5. [Testing](#testing)
6. [Cloud Deployment](#cloud-deployment)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Software

- **Docker Desktop** (macOS/Windows) or **Docker Engine** (Linux)
  - Version: 20.10 or higher
  - Memory: 16GB minimum allocated to Docker
  - Disk: 50GB free space

- **Docker Compose**
  - Version: 2.0 or higher
  - Usually included with Docker Desktop

- **Git**
  - Version: 2.30 or higher

### System Requirements

**macOS:**
```bash
# Install Docker Desktop
brew install --cask docker

# Verify installation
docker --version
docker-compose --version
```

**Linux:**
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Configure system limits (required for Elasticsearch)
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=65536" | sudo tee -a /etc/sysctl.conf
```

**Windows:**
```powershell
# Install Docker Desktop from https://www.docker.com/products/docker-desktop
# Enable WSL 2 backend
# Allocate at least 16GB RAM in Docker Desktop settings
```

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/infra-devops.git
cd infra-devops
```

### 2. Start All Services

```bash
# Start everything
make up-all

# Or start specific services
make up-db              # SQL databases
make up-cache           # Redis
make up-queue           # Kafka, RabbitMQ, ActiveMQ
make up-observability   # Prometheus, Grafana, Loki
```

### 3. Verify Services

```bash
# Check running containers
docker ps

# Check service health
docker-compose ps
```

### 4. Access Web Interfaces

Open your browser and visit:

- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Kafdrop**: http://localhost:9000
- **RabbitMQ**: http://localhost:15672 (admin/admin)
- **SonarQube**: http://localhost:9000 (admin/admin)
- **Vault**: http://localhost:8200 (token: root)

## Local Development Setup

### Step-by-Step Setup

#### 1. SQL Databases

```bash
cd local-setup/db

# Copy environment template
cp .env.example .env

# Edit .env with your values (optional)
nano .env

# Start databases
make up

# Setup replication
make setup-mysql-replication
make setup-mariadb-replication

# Test connections
make test-postgres
make test-mysql
make test-mariadb
```

**Connection Details:**
- PostgreSQL: `localhost:5432` (user: root, password: root)
- MySQL: `localhost:3306` (user: root, password: root)
- MariaDB: `localhost:3308` (user: root, password: root)
- SQL Server: `localhost:1433` (user: sa, password: YourStrong@Passw0rd)
- Oracle: `localhost:1521` (user: myapp, password: myapp)

#### 2. NoSQL Databases

```bash
cd local-setup/nosql

# Copy environment template
cp .env.example .env

# Start databases
make up

# Setup MongoDB replica set
make setup-mongo

# Test connections
make test-mongo
make test-cassandra
make test-couchdb
```

**Connection Details:**
- MongoDB: `mongodb://admin:admin@localhost:27017,localhost:27018,localhost:27019/?replicaSet=rs0`
- Cassandra: `localhost:9042`
- CouchDB: `http://admin:admin@localhost:5984`

#### 3. Redis Cache

```bash
cd local-setup/cache

# Start Redis
make up

# Setup cluster
make setup-cluster

# Test Redis
make test-standalone
make test-cluster
make test-sentinel
```

**Connection Details:**
- Standalone: `localhost:6379`
- Cluster: `localhost:7000-7005`
- Sentinel: `localhost:6380` (master)
- Web UI: http://localhost:8081

#### 4. Message Brokers

```bash
cd local-setup/queue

# Copy environment template
cp .env.example .env

# Start message brokers
make up

# Create test Kafka topic
make create-topic

# Test brokers
make test-kafka
make test-rabbitmq
make test-activemq
```

**Connection Details:**
- Kafka: `localhost:9092,localhost:9093,localhost:9094`
- RabbitMQ: `localhost:5672` (admin/admin)
- ActiveMQ: `tcp://localhost:61616` (admin/admin)

#### 5. Observability Stack

```bash
cd local-setup/observability

# Copy environment template
cp .env.example .env

# Start monitoring stack
make up

# Test services
make test-prometheus
make test-loki
make test-tempo
```

**Access Points:**
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- Alertmanager: http://localhost:9093
- Jaeger: http://localhost:16686

#### 6. Secrets Management

```bash
cd local-setup/vault

# Copy environment template
cp .env.example .env

# Start Vault
make up

# Initialize with sample secrets
make init

# Test Vault
make test
```

**Access:**
- Vault UI: http://localhost:8200 (token: root)
- Consul UI: http://localhost:8500

#### 7. Code Quality

```bash
cd local-setup/sonarqube

# Copy environment template
cp .env.example .env

# Start SonarQube
make up

# Wait for startup (2-3 minutes)
make logs

# Test SonarQube
make test
```

**Access:**
- SonarQube: http://localhost:9000 (admin/admin)

## Configuration

### Environment Variables

Each service has a `.env.example` file. Copy and customize:

```bash
# Example for databases
cd local-setup/db
cp .env.example .env

# Edit with your preferred values
nano .env
```

### Custom Configuration Files

Services use configuration files in their directories:

```
local-setup/
├── db/
│   ├── postgresql.conf          # PostgreSQL settings
│   ├── mysql_primary.cnf        # MySQL primary config
│   └── mariadb_primary.cnf      # MariaDB primary config
├── cache/
│   ├── redis_standalone.conf    # Redis standalone
│   └── redis_cluster.conf       # Redis cluster
├── observability/
│   ├── prometheus/prometheus.yml
│   ├── grafana/provisioning/
│   └── loki/loki.yml
└── vault/
    └── config/vault.hcl
```

Edit these files to customize service behavior.

### Resource Limits

Adjust Docker resource limits in `docker-compose.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '2.0'
      memory: 2G
    reservations:
      cpus: '1.0'
      memory: 1G
```

## Testing

### Test All Services

```bash
# From project root
cd local-setup/db && make test-postgres
cd local-setup/nosql && make test-mongo
cd local-setup/cache && make test-standalone
cd local-setup/queue && make test-kafka
cd local-setup/observability && make test-prometheus
cd local-setup/vault && make test
cd local-setup/sonarqube && make test
```

### Integration Testing

**Test Database Replication:**
```bash
cd local-setup/db

# PostgreSQL
docker exec postgres_primary psql -U root -d myapp -c "CREATE TABLE test (id SERIAL, data TEXT);"
docker exec postgres_primary psql -U root -d myapp -c "INSERT INTO test (data) VALUES ('test');"
docker exec postgres_replica psql -U root -d myapp -c "SELECT * FROM test;"

# MySQL
docker exec mysql_primary mysql -u root -proot -e "USE myapp; CREATE TABLE test (id INT, data VARCHAR(255));"
docker exec mysql_primary mysql -u root -proot -e "USE myapp; INSERT INTO test VALUES (1, 'test');"
docker exec mysql_replica mysql -u root -proot -e "USE myapp; SELECT * FROM test;"
```

**Test Message Queue:**
```bash
cd local-setup/queue

# Kafka
docker exec kafka1 kafka-console-producer --bootstrap-server localhost:9092 --topic test-topic
# Type messages and press Ctrl+D

docker exec kafka1 kafka-console-consumer --bootstrap-server localhost:9092 --topic test-topic --from-beginning
```

**Test Monitoring:**
```bash
# Send test metrics to Prometheus
curl -X POST http://localhost:9090/api/v1/query -d 'query=up'

# Send test logs to Loki
curl -X POST http://localhost:3100/loki/api/v1/push \
  -H 'Content-Type: application/json' \
  -d '{"streams":[{"stream":{"job":"test"},"values":[["'$(date +%s)000000000'","test log"]]}]}'
```

## Cloud Deployment

### AWS Deployment

```bash
cd cloud/aws/terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name my-cluster

# Deploy applications
kubectl apply -f ../k8s/
```

### Azure Deployment

```bash
cd cloud/azure/terraform

# Login to Azure
az login

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply

# Configure kubectl
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster

# Deploy applications
kubectl apply -f ../k8s/
```

### GCP Deployment

```bash
cd cloud/gcp/terraform

# Authenticate
gcloud auth login
gcloud config set project my-project

# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply infrastructure
terraform apply

# Configure kubectl
gcloud container clusters get-credentials my-cluster --region us-central1

# Deploy applications
kubectl apply -f ../k8s/
```

## Troubleshooting

### Common Issues

#### Docker Not Starting

```bash
# Check Docker status
docker info

# Restart Docker
# macOS: Restart Docker Desktop
# Linux:
sudo systemctl restart docker
```

#### Port Already in Use

```bash
# Find process using port
lsof -i :9000

# Kill process
kill -9 <PID>

# Or change port in docker-compose.yml
ports:
  - "9001:9000"
```

#### Insufficient Memory

```bash
# Check Docker memory
docker info | grep Memory

# Increase in Docker Desktop:
# Settings → Resources → Memory → 16GB

# Linux: Edit /etc/docker/daemon.json
{
  "default-ulimits": {
    "memlock": {
      "Hard": -1,
      "Name": "memlock",
      "Soft": -1
    }
  }
}
```

#### Services Not Healthy

```bash
# Check service logs
docker-compose logs <service-name>

# Check health status
docker inspect <container-name> | grep Health

# Restart service
docker-compose restart <service-name>
```

#### Database Connection Failed

```bash
# Check if database is running
docker ps | grep postgres

# Check database logs
docker-compose logs postgres_primary

# Test connection
docker exec postgres_primary psql -U root -c "SELECT 1"

# Verify network
docker network inspect <network-name>
```

#### Elasticsearch Bootstrap Checks Failed

```bash
# Linux only - increase vm.max_map_count
sudo sysctl -w vm.max_map_count=262144

# Make permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### Getting Help

1. **Check service logs:**
   ```bash
   docker-compose logs -f <service-name>
   ```

2. **Check service README:**
   ```bash
   cat local-setup/<service>/README.md
   ```

3. **Verify configuration:**
   ```bash
   docker-compose config
   ```

4. **Reset service:**
   ```bash
   cd local-setup/<service>
   make clean
   make up
   ```

### Clean Start

If everything fails, reset completely:

```bash
# Stop all services
make down

# Remove all volumes (WARNING: deletes all data)
make clean

# Remove all Docker resources
docker system prune -a --volumes

# Start fresh
make up-all
```

## Next Steps

After setup:

1. **Configure monitoring** - Import Grafana dashboards
2. **Setup alerts** - Configure Alertmanager
3. **Initialize Vault** - Store your secrets
4. **Run code analysis** - Setup SonarQube projects
5. **Test integrations** - Connect your applications

## Security Checklist

Before using in production:

- [ ] Change all default passwords
- [ ] Enable SSL/TLS for all services
- [ ] Configure proper authentication
- [ ] Setup network isolation
- [ ] Enable audit logging
- [ ] Implement backup strategy
- [ ] Configure secrets management
- [ ] Setup monitoring and alerting
- [ ] Review security policies
- [ ] Update all images to latest versions

## Additional Resources

- [Local Setup Documentation](local-setup/README.md)
- [Cloud Deployment Guide](cloud/README.md)
- [Kubernetes Manifests](k8s/README.md)
- [Helm Charts](helm-app/README.md)
- [Terraform Modules](terraform/README.md)

## Support

For issues or questions:
1. Check service-specific README
2. Review troubleshooting section
3. Check Docker logs
4. Verify system requirements
5. Create GitHub issue

---

**Happy Infrastructure Building! 🚀**
