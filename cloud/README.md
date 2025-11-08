# Cloud Infrastructure

This directory contains infrastructure-as-code configurations for deploying to major cloud providers.

## Cloud Providers

### AWS
- EKS (Elastic Kubernetes Service)
- RDS (Relational Database Service)
- ElastiCache (Redis)
- MSK (Managed Streaming for Kafka)
- CloudWatch for monitoring

### Azure
- AKS (Azure Kubernetes Service)
- Azure Database for PostgreSQL/MySQL
- Azure Cache for Redis
- Azure Event Hubs
- Azure Monitor

### GCP
- GKE (Google Kubernetes Engine)
- Cloud SQL
- Memorystore (Redis)
- Pub/Sub
- Cloud Monitoring

## Directory Structure

```
cloud/
├── aws/
│   ├── terraform/      # AWS infrastructure provisioning
│   ├── k8s/            # Kubernetes manifests for EKS
│   └── helm/           # Helm charts for AWS-specific configs
├── azure/
│   ├── terraform/      # Azure infrastructure provisioning
│   ├── k8s/            # Kubernetes manifests for AKS
│   └── helm/           # Helm charts for Azure-specific configs
└── gcp/
    ├── terraform/      # GCP infrastructure provisioning
    ├── k8s/            # Kubernetes manifests for GKE
    └── helm/           # Helm charts for GCP-specific configs
```

## Getting Started

Each cloud provider directory contains:
- **terraform/**: Infrastructure provisioning (VPC, clusters, databases, etc.)
- **k8s/**: Kubernetes manifests optimized for that cloud provider
- **helm/**: Helm charts with cloud-specific values

See individual cloud provider READMEs for detailed setup instructions.

## Common Prerequisites

- Cloud provider CLI installed and configured
- Terraform >= 1.5.0
- kubectl
- Helm 3.x
- Valid cloud provider credentials

## Best Practices

- Use separate state backends for each environment
- Enable cloud provider managed services where possible
- Implement proper IAM/RBAC policies
- Use cloud-native monitoring and logging
- Enable encryption at rest and in transit
- Implement proper backup and disaster recovery
