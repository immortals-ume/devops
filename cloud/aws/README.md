# AWS Infrastructure

Infrastructure configurations for deploying to Amazon Web Services.

## Architecture

- **EKS**: Managed Kubernetes cluster
- **RDS**: PostgreSQL and MySQL managed databases
- **ElastiCache**: Redis cluster
- **MSK**: Managed Kafka
- **VPC**: Network isolation with public/private subnets
- **ALB**: Application Load Balancer for ingress
- **CloudWatch**: Logs and metrics
- **Secrets Manager**: Secrets management

## Prerequisites

```bash
# Install AWS CLI
brew install awscli  # macOS

# Configure credentials
aws configure

# Install eksctl
brew install eksctl

# Install kubectl
brew install kubectl
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
aws eks update-kubeconfig --region us-east-1 --name my-cluster
```

### 3. Deploy Applications

```bash
# Using kubectl
kubectl apply -f k8s/

# Using Helm
helm install myapp helm/ -f helm/values-aws.yaml
```

## Terraform Modules

- `vpc/`: VPC with public/private subnets, NAT gateway
- `eks/`: EKS cluster with node groups
- `rds/`: RDS instances with multi-AZ
- `elasticache/`: Redis cluster
- `msk/`: Kafka cluster
- `iam/`: IAM roles and policies

## Cost Optimization

- Use Spot instances for non-critical workloads
- Enable cluster autoscaling
- Use RDS reserved instances for production
- Implement proper resource tagging
- Set up AWS Cost Explorer alerts

## Security

- Enable VPC Flow Logs
- Use AWS Secrets Manager for sensitive data
- Implement least-privilege IAM policies
- Enable encryption for RDS and ElastiCache
- Use AWS WAF for application protection
