# GCP Infrastructure

Infrastructure configurations for deploying to Google Cloud Platform.

## Architecture

- **GKE**: Google Kubernetes Engine
- **Cloud SQL**: PostgreSQL and MySQL managed databases
- **Memorystore**: Managed Redis
- **Pub/Sub**: Messaging service
- **VPC**: Virtual Private Cloud with subnets
- **Cloud Load Balancing**: Ingress and load balancing
- **Cloud Monitoring**: Logs and metrics
- **Secret Manager**: Secrets management

## Prerequisites

```bash
# Install gcloud CLI
brew install google-cloud-sdk  # macOS

# Initialize and authenticate
gcloud init
gcloud auth login

# Install kubectl
brew install kubectl

# Install Helm
brew install helm
```

## Quick Start

### 1. Provision Infrastructure

```bash
cd terraform/
terraform init
terraform plan
terraform apply
```

### 2. Configure kubectl

```bash
gcloud container clusters get-credentials my-cluster --region us-central1
```

### 3. Deploy Applications

```bash
# Using kubectl
kubectl apply -f k8s/

# Using Helm
helm install myapp helm/ -f helm/values-gcp.yaml
```

## Terraform Modules

- `vpc/`: VPC with subnets and firewall rules
- `gke/`: GKE cluster with node pools
- `cloudsql/`: Cloud SQL instances
- `memorystore/`: Redis instances
- `pubsub/`: Pub/Sub topics and subscriptions
- `iam/`: Service accounts and IAM bindings

## Cost Optimization

- Use Preemptible VMs for non-critical workloads
- Enable GKE cluster autoscaling
- Use Committed Use Discounts
- Implement proper resource labeling
- Set up Cloud Billing budgets and alerts

## Security

- Enable Binary Authorization
- Use Workload Identity for pod authentication
- Implement VPC Service Controls
- Enable encryption for Cloud SQL and storage
- Use Cloud Armor for DDoS protection
