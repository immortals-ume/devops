# PostgreSQL Helm Chart

Production-grade PostgreSQL with primary-replica setup and monitoring.

## Features

- Primary-replica replication
- Prometheus metrics exporter
- ServiceMonitor for Prometheus Operator
- NetworkPolicy for security
- PodDisruptionBudget for HA
- Configurable resources and storage
- Security contexts

## Installation

```bash
helm install postgres ./helm-charts/postgres -n db --create-namespace
```

## Configuration

See `values.yaml` for all configuration options.

### Required Values

```yaml
secrets:
  postgresPassword: "base64-encoded-password"
  replicatorPassword: "base64-encoded-password"
```

### Example Custom Values

```yaml
primary:
  replicas: 1
  storage:
    size: 50Gi
    storageClass: fast-ssd
  resources:
    requests:
      cpu: 1
      memory: 2Gi
    limits:
      cpu: 4
      memory: 8Gi

replica:
  enabled: true
  replicas: 3
  storage:
    size: 50Gi
    storageClass: fast-ssd

monitoring:
  enabled: true
  serviceMonitor:
    enabled: true

networkPolicy:
  enabled: true
  allowedNamespaces:
    - myapp
    - backend
```

## Accessing PostgreSQL

```bash
# Port forward
kubectl port-forward -n db svc/postgres-primary 5432:5432

# Connect
psql -h localhost -U postgres -d postgres
```

## Backup

```bash
kubectl exec -n db postgres-primary-0 -- \
  pg_dump -U postgres mydatabase > backup.sql
```

## Restore

```bash
kubectl exec -i -n db postgres-primary-0 -- \
  psql -U postgres mydatabase < backup.sql
```
