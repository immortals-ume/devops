# Helm Charts for Infrastructure Components

Production-ready Helm charts for deploying complete infrastructure stack.

## Available Charts

| Chart | Description | Version |
|-------|-------------|---------|
| postgres | PostgreSQL with primary-replica setup | 1.0.0 |
| mysql | MySQL with monitoring | 1.0.0 |
| mongodb | MongoDB with write/read separation | 1.0.0 |
| redis | Redis (standalone/cluster/sentinel) | 1.0.0 |
| kafka | Kafka with Zookeeper and Kafdrop | 1.0.0 |
| observability | Prometheus, Grafana, Loki, Tempo | 1.0.0 |
| vault | HashiCorp Vault | 1.0.0 |

## Quick Start

### Install a Chart

```bash
# PostgreSQL
helm install postgres ./helm-charts/postgres -n db --create-namespace

# MySQL
helm install mysql ./helm-charts/mysql -n db --create-namespace

# MongoDB
helm install mongodb ./helm-charts/mongodb -n db --create-namespace

# Redis
helm install redis ./helm-charts/redis -n cache --create-namespace

# Kafka
helm install kafka ./helm-charts/kafka -n queue --create-namespace

# Observability
helm install observability ./helm-charts/observability -n observability --create-namespace

# Vault
helm install vault ./helm-charts/vault -n vault --create-namespace
```

### Install with Custom Values

```bash
helm install postgres ./helm-charts/postgres -n db \
  --create-namespace \
  -f custom-values.yaml
```

### Upgrade a Release

```bash
helm upgrade postgres ./helm-charts/postgres -n db
```

### Uninstall a Release

```bash
helm uninstall postgres -n db
```

## Configuration

Each chart has a `values.yaml` file with configurable options. See individual chart directories for details.

### Common Configuration Options

All charts support:
- Resource requests and limits
- Storage size and class
- Monitoring (ServiceMonitor)
- NetworkPolicy
- PodDisruptionBudget
- Security contexts
- Affinity rules

## Examples

### PostgreSQL with Custom Storage

```yaml
# custom-postgres-values.yaml
primary:
  storage:
    size: 50Gi
    storageClass: fast-ssd

replica:
  replicas: 3
  storage:
    size: 50Gi
    storageClass: fast-ssd

secrets:
  postgresPassword: "bXlzZWNyZXRwYXNzd29yZA=="
  replicatorPassword: "cmVwbGljYXRvcnBhc3N3b3Jk"
```

```bash
helm install postgres ./helm-charts/postgres -n db \
  -f custom-postgres-values.yaml
```

### Redis Cluster Mode

```yaml
# redis-cluster-values.yaml
mode: cluster

cluster:
  enabled: true
  replicas: 6
  storage:
    size: 20Gi
```

```bash
helm install redis ./helm-charts/redis -n cache \
  -f redis-cluster-values.yaml
```

### Observability with Ingress

```yaml
# observability-values.yaml
prometheus:
  ingress:
    enabled: true
    host: prometheus.example.com

grafana:
  ingress:
    enabled: true
    host: grafana.example.com
  adminPassword: "YWRtaW5wYXNzd29yZA=="
```

```bash
helm install observability ./helm-charts/observability -n observability \
  -f observability-values.yaml
```

## Package Charts

```bash
# Package all charts
for chart in postgres mysql mongodb redis kafka observability vault; do
  helm package helm-charts/$chart
done

# Create index
helm repo index .
```

## Publish to Chart Repository

```bash
# Add to Helm repository
helm repo add myrepo https://charts.example.com
helm repo update

# Install from repository
helm install postgres myrepo/postgres -n db
```

## Development

### Lint Charts

```bash
helm lint helm-charts/postgres
helm lint helm-charts/mysql
helm lint helm-charts/mongodb
helm lint helm-charts/redis
helm lint helm-charts/kafka
helm lint helm-charts/observability
helm lint helm-charts/vault
```

### Template Rendering

```bash
# Render templates
helm template postgres ./helm-charts/postgres -n db

# Render with custom values
helm template postgres ./helm-charts/postgres -n db \
  -f custom-values.yaml
```

### Dry Run

```bash
helm install postgres ./helm-charts/postgres -n db --dry-run --debug
```

## Dependencies

Some charts may have dependencies on other charts. Install dependencies:

```bash
cd helm-charts/observability
helm dependency update
```

## Best Practices

1. **Always use custom values files** - Don't modify values.yaml directly
2. **Store secrets securely** - Use Sealed Secrets or External Secrets Operator
3. **Test in staging first** - Always test chart upgrades in non-production
4. **Use specific versions** - Pin chart versions in production
5. **Monitor deployments** - Use Helm hooks for validation
6. **Backup before upgrade** - Always backup data before upgrading

## Troubleshooting

### Check Release Status

```bash
helm list -A
helm status postgres -n db
```

### View Release History

```bash
helm history postgres -n db
```

### Rollback Release

```bash
helm rollback postgres 1 -n db
```

### Get Values

```bash
# Get all values
helm get values postgres -n db

# Get all values including defaults
helm get values postgres -n db --all
```

## Support

For issues or questions, check:
- Chart-specific README in each chart directory
- Kubernetes documentation
- Helm documentation
