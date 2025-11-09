# Helm Charts Values Guide

## Overview

Each Helm chart has environment-specific values files for different deployment scenarios:
- **dev** - Development environment
- **sit** - System Integration Testing
- **uat** - User Acceptance Testing
- **preprod** - Pre-Production
- **production** - Production environment

## Directory Structure

```
helm-charts/
├── postgres/values/
│   ├── values-dev.yaml
│   ├── values-sit.yaml
│   ├── values-uat.yaml
│   ├── values-preprod.yaml
│   └── values-production.yaml
├── mysql/values/
├── mongodb/values/
├── redis/values/
├── kafka/values/
├── observability/values/
└── vault/values/
```

## Environment Characteristics

### Development (dev)
- **Purpose**: Local development and testing
- **Resources**: Minimal (250m CPU, 256Mi RAM)
- **Replicas**: Single instance
- **Storage**: Small (5-10Gi)
- **HA**: Disabled
- **Monitoring**: Basic
- **Secrets**: Simple (CHANGE IN PRODUCTION!)

### SIT (System Integration Testing)
- **Purpose**: Integration testing
- **Resources**: Moderate (500m CPU, 512Mi RAM)
- **Replicas**: 1-2 instances
- **Storage**: Medium (20Gi)
- **HA**: Basic (PDB enabled)
- **Monitoring**: Enabled
- **Secrets**: Test credentials

### UAT (User Acceptance Testing)
- **Purpose**: User testing and validation
- **Resources**: Production-like (1 CPU, 2Gi RAM)
- **Replicas**: 2-3 instances
- **Storage**: Medium-Large (50Gi)
- **HA**: Enabled
- **Monitoring**: Full monitoring
- **Secrets**: UAT-specific

### Pre-Production (preprod)
- **Purpose**: Final testing before production
- **Resources**: Production-equivalent (2 CPU, 4Gi RAM)
- **Replicas**: Production-like (2-3 instances)
- **Storage**: Large (100Gi)
- **HA**: Full HA setup
- **Monitoring**: Production-grade
- **Secrets**: Production-like (CHANGE!)

### Production
- **Purpose**: Live production workloads
- **Resources**: High (4-8 CPU, 8-16Gi RAM)
- **Replicas**: Multiple (3-5 instances)
- **Storage**: Very Large (200Gi+)
- **HA**: Full HA with PDB, anti-affinity
- **Monitoring**: Complete observability
- **Secrets**: **MUST BE CHANGED!**

## Deployment Examples

### Deploy to Development

```bash
# Single chart
helm install postgres ./helm-charts/postgres -n db \
  --create-namespace \
  --values ./helm-charts/postgres/values/values-dev.yaml

# All charts
cd helm-charts
./deploy-all.sh --all --env dev
```

### Deploy to Production

```bash
# Single chart
helm install postgres ./helm-charts/postgres -n db \
  --create-namespace \
  --values ./helm-charts/postgres/values/values-production.yaml

# All charts
cd helm-charts
./deploy-all.sh --all --env production
```

### Deploy Specific Components

```bash
# Database stack to SIT
./deploy-all.sh --db --env sit

# Observability to UAT
./deploy-all.sh --observability --env uat

# Cache to Production
./deploy-all.sh --cache --env production
```

## Resource Comparison

### PostgreSQL

| Environment | CPU Request | Memory Request | Storage | Replicas |
|-------------|-------------|----------------|---------|----------|
| dev | 250m | 256Mi | 10Gi | 1 primary |
| sit | 500m | 512Mi | 20Gi | 1 primary + 1 replica |
| uat | 1 | 2Gi | 50Gi | 1 primary + 2 replicas |
| preprod | 2 | 4Gi | 100Gi | 1 primary + 2 replicas |
| production | 4 | 8Gi | 200Gi | 1 primary + 3 replicas |

### Redis

| Environment | Mode | Replicas | CPU | Memory | Storage |
|-------------|------|----------|-----|--------|---------|
| dev | standalone | 1 | 100m | 128Mi | 5Gi |
| sit | standalone | 1 | 250m | 256Mi | 10Gi |
| uat | cluster | 6 | 500m | 512Mi | 20Gi |
| preprod | cluster | 6 | 500m | 512Mi | 20Gi |
| production | cluster | 6 | 500m | 512Mi | 20Gi |

### Kafka

| Environment | Brokers | Zookeepers | CPU | Memory | Storage |
|-------------|---------|------------|-----|--------|---------|
| dev | 1 | 1 | 500m | 512Mi | 10Gi |
| sit | 3 | 3 | 1 | 1Gi | 20Gi |
| uat | 3 | 3 | 1 | 2Gi | 50Gi |
| preprod | 3 | 3 | 2 | 4Gi | 100Gi |
| production | 5 | 5 | 2 | 4Gi | 100Gi |

## Customization

### Override Specific Values

```bash
# Override storage size
helm install postgres ./helm-charts/postgres -n db \
  --values ./helm-charts/postgres/values/values-production.yaml \
  --set primary.storage.size=500Gi

# Override replicas
helm install postgres ./helm-charts/postgres -n db \
  --values ./helm-charts/postgres/values/values-production.yaml \
  --set replica.replicas=5
```

### Create Custom Values File

```yaml
# custom-postgres.yaml
# Inherit from production
primary:
  storage:
    size: 500Gi
    storageClass: "ultra-fast-ssd"
  resources:
    requests:
      cpu: 8
      memory: 32Gi

replica:
  replicas: 5
```

Deploy:
```bash
helm install postgres ./helm-charts/postgres -n db \
  --values ./helm-charts/postgres/values/values-production.yaml \
  --values custom-postgres.yaml
```

## Security Best Practices

### 1. Change All Secrets

**CRITICAL**: All default secrets MUST be changed for non-dev environments!

```bash
# Generate secure password
openssl rand -base64 32

# Encode to base64
echo -n 'your-secure-password' | base64

# Update values file
vi helm-charts/postgres/values/values-production.yaml
```

### 2. Use External Secrets

For production, use:
- **Sealed Secrets** (Bitnami)
- **External Secrets Operator**
- **HashiCorp Vault** integration
- **Cloud provider secrets** (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager)

### 3. Enable NetworkPolicies

Ensure NetworkPolicies are enabled in all environments:

```yaml
networkPolicy:
  enabled: true
  allowedNamespaces:
    - myapp
    - observability
```

### 4. Use TLS/SSL

Enable TLS for production:

```yaml
ingress:
  enabled: true
  className: nginx
  host: app.example.com
  tls:
    - secretName: app-tls
      hosts:
        - app.example.com
```

## Monitoring Configuration

### Development
```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: false  # No Prometheus Operator
```

### Production
```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 15s
```

## High Availability

### Development
```yaml
podDisruptionBudget:
  enabled: false

replica:
  enabled: false
```

### Production
```yaml
podDisruptionBudget:
  enabled: true
  minAvailable: 2

replica:
  enabled: true
  replicas: 3

affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app.kubernetes.io/name
              operator: In
              values:
                - postgres
        topologyKey: "kubernetes.io/hostname"
```

## Upgrade Procedures

### Upgrade to New Environment

```bash
# Upgrade from dev to sit
helm upgrade postgres ./helm-charts/postgres -n db \
  --values ./helm-charts/postgres/values/values-sit.yaml

# Upgrade to production
helm upgrade postgres ./helm-charts/postgres -n db \
  --values ./helm-charts/postgres/values/values-production.yaml
```

### Rollback

```bash
# Rollback to previous version
helm rollback postgres -n db

# Rollback to specific revision
helm rollback postgres 3 -n db
```

## Validation

### Pre-Deployment Checks

```bash
# Lint chart
helm lint ./helm-charts/postgres

# Dry run
helm install postgres ./helm-charts/postgres -n db \
  --values ./helm-charts/postgres/values/values-production.yaml \
  --dry-run --debug

# Template rendering
helm template postgres ./helm-charts/postgres -n db \
  --values ./helm-charts/postgres/values/values-production.yaml
```

### Post-Deployment Checks

```bash
# Check release status
helm status postgres -n db

# Check pods
kubectl get pods -n db

# Check services
kubectl get svc -n db

# Check PVCs
kubectl get pvc -n db

# View logs
kubectl logs -l app.kubernetes.io/name=postgres -n db
```

## Troubleshooting

### Issue: Pods Not Starting

```bash
# Check events
kubectl get events -n db --sort-by='.lastTimestamp'

# Describe pod
kubectl describe pod postgres-primary-0 -n db

# Check logs
kubectl logs postgres-primary-0 -n db
```

### Issue: Storage Problems

```bash
# Check PVC status
kubectl get pvc -n db

# Describe PVC
kubectl describe pvc postgres-primary-data-postgres-primary-0 -n db

# Check StorageClass
kubectl get storageclass
```

### Issue: Network Connectivity

```bash
# Test DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  nslookup postgres-primary.db.svc.cluster.local

# Test connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  telnet postgres-primary.db.svc.cluster.local 5432
```

### Issue: Performance Problems

```bash
# Check resource usage
kubectl top pods -n db

# Check node resources
kubectl top nodes

# View detailed metrics
kubectl describe node <node-name>
```

### Issue: Secrets Not Loading

```bash
# Check secret exists
kubectl get secrets -n db

# Describe secret
kubectl describe secret postgres-secret -n db

# Verify secret data (base64 encoded)
kubectl get secret postgres-secret -n db -o yaml
```

## Migration Between Environments

### Data Migration

```bash
# Export from dev
kubectl exec -n db postgres-primary-0 -- \
  pg_dump -U postgres mydb > backup.sql

# Import to sit
kubectl exec -i -n db postgres-primary-0 -- \
  psql -U postgres mydb < backup.sql
```

### Configuration Migration

```bash
# Compare values files
diff helm-charts/postgres/values/values-dev.yaml \
     helm-charts/postgres/values/values-sit.yaml

# Merge configurations
yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
  values-base.yaml values-production.yaml > values-merged.yaml
```

## Cost Optimization

### Development/Testing Environments

- Use smaller instance types
- Enable autoscaling with lower minimums
- Schedule downtime for non-business hours
- Use spot/preemptible instances where possible
- Share resources across teams

### Production Environment

- Right-size based on actual usage metrics
- Use reserved instances for predictable workloads
- Enable horizontal pod autoscaling
- Implement proper resource limits
- Monitor and optimize storage usage

## Compliance and Governance

### Audit Logging

```yaml
# Enable audit logs for production
audit:
  enabled: true
  logLevel: "INFO"
  destination: "stdout"
```

### Backup Configuration

```yaml
backup:
  enabled: true
  schedule: "0 2 * * *"  # Daily at 2 AM
  retention: 30  # Keep 30 days
  storageClass: "standard"
```

### Disaster Recovery

```yaml
# Production DR configuration
replication:
  enabled: true
  mode: "async"
  remoteCluster:
    enabled: true
    endpoint: "dr-cluster.example.com"
```

## Additional Resources

### Documentation Links

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [PostgreSQL Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/postgresql)
- [Redis Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/redis)
- [Kafka Helm Chart](https://github.com/bitnami/charts/tree/main/bitnami/kafka)

### Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Helm chart documentation
3. Check Kubernetes cluster logs
4. Contact your DevOps team

## Quick Reference

### Common Commands

```bash
# List all releases
helm list -A

# Get release values
helm get values postgres -n db

# History
helm history postgres -n db

# Uninstall
helm uninstall postgres -n db

# Package chart
helm package ./helm-charts/postgres

# Update dependencies
helm dependency update ./helm-charts/postgres
```

### Environment Variables

```bash
# Set default namespace
export HELM_NAMESPACE=db

# Set default environment
export DEPLOY_ENV=production

# Use in deployment
helm install postgres ./helm-charts/postgres \
  --values ./helm-charts/postgres/values/values-${DEPLOY_ENV}.yaml
```

---

**Last Updated**: November 2025  
**Version**: 1.0  
**Maintainer**: DevOps Team