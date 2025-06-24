# DevOps Infrastructure Repository

A comprehensive collection of infrastructure-as-code configurations for modern application development and deployment. This repository provides ready-to-use Docker Compose configurations for databases, caching, message queues, observability tools, and secrets management.

## Overview

This repository contains Docker Compose configurations for various infrastructure components commonly used in modern application development and deployment. It's designed to help developers and DevOps engineers quickly set up development, testing, and production environments with best practices already implemented.

## Repository Structure

```
.
├── db/                     # Database configurations
│   ├── docker-compose-pg.yaml      # PostgreSQL with primary-replica setup
│   └── docker-compose-sql.yaml     # MySQL, MongoDB, and H2 databases
├── observability/          # Monitoring and observability tools
│   ├── docker-compose-observability.yaml  # Prometheus, Grafana, Loki, etc.
│   └── docker-compose-sonar.yaml          # SonarQube for code quality
├── queue/                  # Message queue systems
│   └── docker-compose-kafka.yaml   # Kafka with Zookeeper and Kafdrop
├── redis/                  # Redis caching solutions
│   ├── cluster/            # Redis cluster configuration
│   ├── sentinel/           # Redis sentinel for high availability
│   └── docker-compose.redis.yaml   # Standalone Redis
└── vault/                  # Secrets management
    └── docker-compose-vault.yaml   # HashiCorp Vault
```

## Prerequisites

- Docker and Docker Compose installed
- Git for version control
- Basic understanding of containerization concepts

## Getting Started

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/infra-devops.git
   cd infra-devops
   ```

2. Create a `.env` file with necessary environment variables (see `.env.example` if available)

3. Start the desired infrastructure component:
   ```bash
   # For databases
   docker-compose -f db/docker-compose-pg.yml up -d

   # For observability
   docker-compose -f observability/docker-compose.yaml up -d

   # For message queues
   docker-compose -f queue/docker-compose.yaml up -d

   # For Redis (standalone)
   docker-compose -f redis/docker-compose.yaml up -d

   # For Vault
   docker-compose -f vault/docker-compose.yaml up -d
   ```

## Component Details

### Databases

#### PostgreSQL
- Primary-replica setup for high availability
- Configured with proper replication settings
- Accessible on ports 5432 (primary) and 5433 (replica)

#### MySQL, MongoDB, and H2
- MySQL: Relational database with proper configuration
- MongoDB: NoSQL database with read/write separation
- H2: Lightweight in-memory database for testing

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
# Start PostgreSQL database
docker-compose -f db/docker-compose-pg.yml up -d

# Start Redis for caching
docker-compose -f redis/docker-compose.yaml up -d

# Start Kafka for messaging
docker-compose -f queue/docker-compose.yaml up -d

# Start observability stack
docker-compose -f observability/docker-compose.yaml up -d
```

### Setting up a high-availability Redis cluster

```bash
# Start Redis cluster
docker-compose -f redis/cluster/docker-compose.yml up -d

# Initialize the cluster (run this after all nodes are up)
docker exec -it redis-7000 redis-cli --cluster create 127.0.0.1:7000 127.0.0.1:7001 127.0.0.1:7002 127.0.0.1:7003 127.0.0.1:7004 127.0.0.1:7005 --cluster-replicas 1
```


## License

This project is licensed under the MIT License - see the LICENSE file for details.

