# Azure Infrastructure

Infrastructure configurations for deploying to Microsoft Azure.

## Architecture

- **AKS**: Azure Kubernetes Service
- **Azure Database**: PostgreSQL and MySQL managed databases
- **Azure Cache for Redis**: Managed Redis
- **Azure Event Hubs**: Kafka-compatible messaging
- **VNet**: Virtual network with subnets
- **Application Gateway**: Ingress controller
- **Azure Monitor**: Logs and metrics
- **Key Vault**: Secrets management

## Prerequisites

```bash
# Install Azure CLI
brew install azure-cli  # macOS

# Login to Azure
az login

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
az aks get-credentials --resource-group myResourceGroup --name myAKSCluster
```

### 3. Deploy Applications

```bash
# Using kubectl
kubectl apply -f k8s/

# Using Helm
helm install myapp helm/ -f helm/values-azure.yaml
```

## Terraform Modules

- `vnet/`: Virtual network with subnets and NSGs
- `aks/`: AKS cluster with node pools
- `database/`: Azure Database for PostgreSQL/MySQL
- `redis/`: Azure Cache for Redis
- `eventhub/`: Event Hubs namespace
- `keyvault/`: Key Vault for secrets

## Cost Optimization

- Use Azure Reserved VM Instances
- Enable AKS cluster autoscaling
- Use Azure Hybrid Benefit if applicable
- Implement proper resource tagging
- Set up Azure Cost Management alerts

## Security

- Enable Azure Policy
- Use Managed Identities for authentication
- Implement Network Security Groups
- Enable encryption for databases and storage
- Use Azure Firewall for network protection
