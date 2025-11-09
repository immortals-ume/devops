# Redis Helm Chart

Production-ready Redis Helm chart with support for standalone, cluster, and sentinel modes.

## Features

- Multiple deployment modes: standalone, cluster, sentinel
- Prometheus metrics exporter
- ServiceMonitor for Prometheus Operator
- NetworkPolicy for security
- PodDisruptionBudget for high availability
- Configurable resources and storage
- Environment-specific configurations

## Installation

### Standalone Mode (Development)

```bash
helm install redis ./helm-charts/redis -n cache \
  --create-namespace \
  --values ./helm-charts/redis/values/values-dev.yaml
```

### Cluster Mode (Production)

```bash
helm install redis ./helm-charts/redis -n cache \
  --create-namespace \
  --values ./helm-charts/redis/values/values-production.yaml
```

## Configuration

### Deployment Modes

#### Standalone
Single Redis instance with persistence. Suitable for development and testing.

```yaml
mode: standalone
standalone:
  enabled: true
  replicas: 1
```

#### Cluster
Redis Cluster with 6 nodes (3 masters + 3 replicas). Suitable for production.

```yaml
mode: cluster
cluster:
  enabled: true
  replicas: 6
```

#### Sentinel
Redis with Sentinel for automatic failover. Suitable for high availability.

```yaml
mode: sentinel
sentinel:
  enabled: true
  replicas: 3
```

### Resource Configuration

```yaml
standalone:
  resources:
    requests:
      cpu: 250m
      memory: 256Mi
    limits:
      cpu: 1
      memory: 512Mi
  storage:
    size: 10Gi
    storageClass: "fast-ssd"
```

### Monitoring

```yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
    interval: 30s
```

### Network Policy

```yaml
networkPolicy:
  enabled: true
  allowedNamespaces:
    - myapp
    - observability
```

## Upgrade

```bash
# Upgrade to new version
helm upgrade redis ./helm-charts/redis -n cache \
  --values ./helm-charts/redis/values/values-production.yaml

# Rollback if needed
helm rollback redis -n cache
```

## Uninstall

```bash
helm uninstall redis -n cache
```

## Testing

```bash
# Lint chart
helm lint ./helm-charts/redis

# Dry run
helm install redis ./helm-charts/redis -n cache \
  --dry-run --debug

# Test connection
kubectl run -it --rm redis-test --image=redis:7.2-alpine --restart=Never -- \
  redis-cli -h redis-standalone.cache.svc.cluster.local PING
```

## Environment-Specific Values

- `values-dev.yaml` - Development (standalone, minimal resources)
- `values-sit.yaml` - System Integration Testing (standalone, moderate resources)
- `values-uat.yaml` - User Acceptance Testing (cluster, production-like)
- `values-preprod.yaml` - Pre-Production (cluster, production-equivalent)
- `values-production.yaml` - Production (cluster, full HA)

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n cache -l app.kubernetes.io/name=redis
```

### View Logs
```bash
kubectl logs -n cache -l app.kubernetes.io/name=redis
```

### Test Connection
```bash
kubectl run -it --rm redis-test --image=redis:7.2-alpine --restart=Never -- \
  redis-cli -h redis-standalone.cache.svc.cluster.local PING
```

### Check Metrics
```bash
kubectl port-forward -n cache svc/redis-standalone 9121:9121
curl http://localhost:9121/metrics
```
