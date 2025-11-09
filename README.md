# DevOps Infrastructure Repository

A comprehensive collection of infrastructure-as-code configurations for modern application development and deployment. This repository provides ready-to-use Docker Compose configurations for databases, caching, message queues, observability tools, and secrets management.

## Overview

This repository contains Docker Compose configurations for various infrastructure components commonly used in modern application development and deployment. It's designed to help developers and DevOps engineers quickly set up development, testing, and production environments with best practices already implemented.

## Repository Structure

```
.
├── local-setup/            # Local development environment
│   ├── db/                 # SQL databases (PostgreSQL, MySQL, MariaDB, MSSQL, Oracle)
│   ├── nosql/              # NoSQL databases (MongoDB, Cassandra, CouchDB)
│   ├── inmemory/           # In-memory databases (H2, Ignite, Hazelcast, Memcached)
│   ├── cache/              # Redis caching (standalone, cluster, sentinel)
│   ├── queue/              # Message queues (Kafka)
│   ├── observability/      # Monitoring stack (Prometheus, Grafana, Loki, Tempo)
│   └── vault/              # HashiCorp Vault for secrets
├── cloud/                  # Cloud infrastructure
│   ├── aws/                # AWS infrastructure (EKS, RDS, ElastiCache, MSK)
│   ├── azure/              # Azure infrastructure (AKS, Azure DB, Cache, Event Hubs)
│   └── gcp/                # GCP infrastructure (GKE, Cloud SQL, Memorystore, Pub/Sub)
├── k8s/                    # Kubernetes manifests
├── helm-app/               # Helm charts
├── helmfile/               # Helmfile configurations
└── terraform/              # Terraform modules
```

## Prerequisites

- Docker and Docker Compose installed
- Git for version control
- Basic understanding of containerization concepts
- Kubernetes cluster (with LoadBalancer support, e.g., cloud provider or MetalLB)
- kubectl configured for your cluster
- (Optional) Helm
- (Optional) Terraform

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/infra-devops.git
   cd infra-devops
   ```

2. Create a `.env` file with necessary environment variables (see `.env.example` if available)

3. Start the desired infrastructure component:
   ```bash
   # Quick start with Makefile
   make up-all              # Start all local services
   make up-db               # Start SQL databases only
   make up-nosql            # Start NoSQL databases only
   make up-inmemory         # Start in-memory databases only
   make up-cache            # Start Redis cache
   make up-queue            # Start Kafka
   make up-observability    # Start monitoring stack
   make up-vault            # Start Vault

   # Or use docker-compose directly
   cd local-setup/db && docker-compose up -d
   cd local-setup/nosql && docker-compose up -d
   cd local-setup/cache && docker-compose up -d
   ```

## Component Details

### SQL Databases (local-setup/db/)
- **PostgreSQL 16.2**: Primary-replica setup (ports 5432, 5433)
- **MySQL 8.4**: Primary-replica with GTID (ports 3306, 3307)
- **MariaDB 11.4**: Primary-replica with GTID (ports 3308, 3309)
- **SQL Server 2022**: Developer edition (port 1433)
- **Oracle XE 21c**: Express edition (port 1521)

### NoSQL Databases (local-setup/nosql/)
- **MongoDB 7.0**: 3-node replica set (ports 27017-27019)
- **Cassandra 5.0**: 2-node cluster (ports 9042-9043)
- **CouchDB 3.3**: Single instance with web UI (port 5984)

### In-Memory Databases (local-setup/inmemory/)
- **H2 2.2**: SQL in-memory database (ports 8082, 9092)
- **Apache Ignite 2.16**: Distributed computing (port 10800)
- **Hazelcast 5.3**: Distributed data grid (port 5701)
- **Memcached 1.6**: Key-value cache (port 11212)

### Observability

- **Zipkin**: Distributed tracing system
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization and dashboarding
- **Loki**: Log aggregation
- **Fluent-bit**: Log forwarding
- **Tempo**: Trace data storage and querying

### Message Queues

- **Kafka**: Distributed event streaming platform
- **Zookeeper**: Coordination service for Kafka
- **Kafdrop**: Web UI for Kafka monitoring

### Redis Caching

- **Standalone**: Simple Redis instance with persistence
- **Cluster**: 6-node Redis cluster for high availability and sharding
- **Sentinel**: Redis with sentinel for automatic failover

### Secrets Management

- **HashiCorp Vault**: Secrets management with UI enabled

## Configuration

Most services can be configured through environment variables. Create a `.env` file in the root directory with the necessary variables. Example:

```
# Database
MYSQL_ROOT_PASSWORD=your_root_password
MYSQL_DATABASE=your_database
MYSQL_USER=your_user
MYSQL_PASSWORD=your_password

# Kafka
KAFKA_BROKER_ID=1
KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092

# Grafana
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin
```

## Usage Examples

### Setting up a complete development environment

```bash
# Start all services at once
make up-all

# Or start services individually
make up-db                # SQL databases
make up-nosql             # NoSQL databases
make up-cache             # Redis
make up-queue             # Kafka
make up-observability     # Monitoring stack
```

### Setting up database replication

```bash
# SQL databases
cd local-setup/db
make setup-mysql-replication
make setup-mariadb-replication

# NoSQL databases
cd local-setup/nosql
make setup-mongo
```

## Setup

### 1. Local Development (Docker Compose)
- Navigate to local-setup directory:
  ```sh
  cd local-setup
  ```
- Copy `.env.example` to `.env` in each subdirectory and customize:
  ```sh
  cp db/.env.example db/.env
  cp nosql/.env.example nosql/.env
  # Edit .env files as needed
  ```
- Start services:
  ```sh
  # From project root
  make up-all
  
  # Or individually
  cd local-setup/db && make up
  cd local-setup/nosql && make up
  ```

### 2. Kubernetes (Production/Cloud)

#### Quick Start with Deployment Script

The easiest way to deploy the entire infrastructure:

```sh
cd k8s
./deploy.sh --all
```

Or deploy specific components:

```sh
./deploy.sh --db --cache              # Deploy only database and cache
./deploy.sh --observability           # Deploy only monitoring stack
./deploy.sh --queue                   # Deploy only Kafka
```

#### Manual Deployment

- Ensure your cluster supports PersistentVolumes (cloud provider or local storage provisioner)
- Apply namespaces first:
  ```sh
  kubectl apply -f k8s/myapp/namespaces.yaml
  ```
- Label namespaces for NetworkPolicies:
  ```sh
  kubectl label namespace db name=db
  kubectl label namespace cache name=cache
  kubectl label namespace queue name=queue
  kubectl label namespace observability name=observability
  kubectl label namespace vault name=vault
  kubectl label namespace myapp name=myapp
  ```
- Apply each stack:
  ```sh
  # Database
  kubectl apply -f k8s/db/postgres-configmap.yaml
  kubectl apply -f k8s/db/postgres-secret.yaml
  kubectl apply -f k8s/db/postgres-primary-statefulset.yaml
  kubectl apply -f k8s/db/postgres-replica-statefulset.yaml
  kubectl apply -f k8s/db/mysql-configmap.yaml
  kubectl apply -f k8s/db/mysql-secret.yaml
  kubectl apply -f k8s/db/mysql-deployment.yaml
  kubectl apply -f k8s/db/mongodb-configmap.yaml
  kubectl apply -f k8s/db/mongodb-secret.yaml
  kubectl apply -f k8s/db/mongodb-write-deployment.yaml
  kubectl apply -f k8s/db/mongodb-read-deployment.yaml
  kubectl apply -f k8s/db/networkpolicy.yaml
  
  # Cache
  kubectl apply -f k8s/cache/redis-standalone-configmap.yaml
  kubectl apply -f k8s/cache/redis-standalone-deployment.yaml
  kubectl apply -f k8s/cache/redis-cluster-configmap.yaml
  kubectl apply -f k8s/cache/redis-cluster-statefulset.yaml
  kubectl apply -f k8s/cache/networkpolicy.yaml
  
  # Queue
  kubectl apply -f k8s/queue/zookeeper-statefulset.yaml
  kubectl apply -f k8s/queue/kafka-configmap.yaml
  kubectl apply -f k8s/queue/kafka-statefulset.yaml
  kubectl apply -f k8s/queue/kafdrop-deployment.yaml
  kubectl apply -f k8s/queue/networkpolicy.yaml
  
  # Observability
  kubectl apply -f k8s/observability/prometheus-configmap.yaml
  kubectl apply -f k8s/observability/prometheus-deployment.yaml
  kubectl apply -f k8s/observability/grafana-secrets.yaml
  kubectl apply -f k8s/observability/grafana-deployment.yaml
  kubectl apply -f k8s/observability/loki-configmap.yaml
  kubectl apply -f k8s/observability/loki-deployment.yaml
  kubectl apply -f k8s/observability/fluent-bit-configmap.yaml
  kubectl apply -f k8s/observability/fluent-bit-deployment.yaml
  kubectl apply -f k8s/observability/tempo-deployment.yaml
  kubectl apply -f k8s/observability/networkpolicy.yaml
  
  # Vault
  kubectl apply -f k8s/vault/vault-secrets.yaml
  kubectl apply -f k8s/vault/vault-configmap.yaml
  kubectl apply -f k8s/vault/vault-deployment.yaml
  kubectl apply -f k8s/vault/networkpolicy.yaml
  
  # Application (optional)
  kubectl apply -f k8s/myapp/enterprise-app.yaml
  ```

#### Verify Deployment

```sh
# Check all pods
kubectl get pods -A

# Check services
kubectl get svc -A

# Check PVCs
kubectl get pvc -A

# Access services via port-forward
kubectl port-forward -n observability svc/grafana 3000:3000
kubectl port-forward -n observability svc/prometheus 9090:9090
kubectl port-forward -n queue svc/kafdrop 9000:9000
```

See [k8s/README.md](k8s/README.md) for detailed documentation.

### 3. Observability
- Prometheus: http://<prometheus-loadbalancer-ip>:9090
- Grafana: http://<grafana-loadbalancer-ip>:3000 (default admin credentials in k8s/observability/grafana-secrets.yaml)
- Loki, Fluent Bit, Tempo: see k8s/observability/

### 4. Terraform
- See `terraform/` for infrastructure as code examples and state management best practices.

## Security & Best Practices
- **Secrets:** Use Kubernetes Secrets or SealedSecrets. Never commit real secrets to version control.
- **NetworkPolicy:** Restrict inter-service communication. Example below.
- **RBAC:** Use least-privilege roles for service accounts.
- **Resource Limits:** All pods have CPU/memory requests and limits.
- **Probes:** Liveness/readiness probes for all critical services.
- **Backups:** Use provided scripts and automate with CronJobs.
- **Monitoring:** Use Prometheus/Grafana dashboards and alerting.
- **Disaster Recovery:** Document and test restore procedures.

## Example: Kubernetes NetworkPolicy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-namespace-internal
  namespace: db
spec:
  podSelector: {}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: db
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              name: db
```
- Adjust `namespace` and `matchLabels` as needed for each stack.
- Apply with: `kubectl apply -f <networkpolicy-file>.yaml`

## Troubleshooting
- Check pod status: `kubectl get pods -A`
- View logs: `kubectl logs <pod> -n <namespace>`
- Check service endpoints: `kubectl get svc -A`
- For LoadBalancer issues, ensure your cluster supports it (cloud or MetalLB).
- For database connection issues, verify secrets and service endpoints.

## Production Deployment Checklist
- [x] All manifests organized by stack in `k8s/`
- [x] Namespaces, ConfigMaps, and Secrets templated
- [x] Resource requests/limits and probes set
- [x] NetworkPolicies in place
- [x] Monitoring and alerting enabled
- [x] Backups and disaster recovery documented
- [x] CI/CD pipeline for automated deployment

---
For further help, see the `k8s/` directory for modular, production-ready manifests and templates for all major stacks.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

