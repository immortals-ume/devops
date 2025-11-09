# MySQL Helm Chart

Production-ready MySQL Helm chart with monitoring, high availability, and security features.

## Features

- ✅ StatefulSet deployment for data persistence
- ✅ Configurable replication (primary-replica)
- ✅ Prometheus metrics via mysqld-exporter
- ✅ ServiceMonitor for Prometheus Operator
- ✅ NetworkPolicy for network security
- ✅ PodDisruptionBudget for high availability
- ✅ Configurable resources and storage
- ✅ Security contexts and RBAC
- ✅ Health probes (liveness/readiness)
- ✅ Custom MySQL configuration

## Prerequisites

- Kubernetes 1.24+
- Helm 3.8+
- PV provisioner support in the underlying infrastructure
- (Optional) Prometheus Operator for ServiceMonitor

## Installation

### Quick Start

```bash
# Install with default values
helm install mysql ./mysql -n db --create-namespace

# Install with custom values
helm install mysql ./mysql -n db \
  --create-namespace \
  --values values/values-production.yaml
```

### Using Environment-Specific Values

```bash
# Development
helm install mysql ./mysql -n db \
  --create-namespace \
  --values values/values-dev.yaml

# Production
helm install mysql ./mysql -n db \
  --create-namespace \
  --values values/values-production.yaml
```

## Configuration

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of MySQL instances | `1` |
| `image.repository` | MySQL image repository | `mysql` |
| `image.tag` | MySQL image tag | `8.4` |
| `auth.rootPassword` | Root password | `changeme` |
| `auth.database` | Default database name | `myapp` |
| `auth.username` | Application user | `myapp` |
| `auth.password` | Application password | `changeme` |
| `persistence.size` | PVC size | `20Gi` |
| `persistence.storageClass` | Storage class | `""` |
| `resources.requests.cpu` | CPU request | `500m` |
| `resources.requests.memory` | Memory request | `512Mi` |
| `monitoring.enabled` | Enable Prometheus exporter | `true` |
| `networkPolicy.enabled` | Enable NetworkPolicy | `true` |

### Full Configuration

See [values.yaml](values.yaml) for all available options.

## Usage Examples

### Connect to MySQL

```bash
# Get root password
export MYSQL_ROOT_PASSWORD=$(kubectl get secret mysql -n db -o jsonpath="{.data.mysql-root-password}" | base64 -d)

# Connect via kubectl
kubectl run -it --rm mysql-client --image=mysql:8.4 --restart=Never -- \
  mysql -h mysql.db.svc.cluster.local -u root -p${MYSQL_ROOT_PASSWORD}

# Port forward
kubectl port-forward -n db svc/mysql 3306:3306
mysql -h localhost -u root -p
```

### Create Database and User

```sql
CREATE DATABASE myapp;
CREATE USER 'myapp'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON myapp.* TO 'myapp'@'%';
FLUSH PRIVILEGES;
```

### Backup and Restore

```bash
# Backup
kubectl exec -n db mysql-0 -- \
  mysqldump -u root -p${MYSQL_ROOT_PASSWORD} --all-databases > backup.sql

# Restore
kubectl exec -i -n db mysql-0 -- \
  mysql -u root -p${MYSQL_ROOT_PASSWORD} < backup.sql
```

## Monitoring

### Prometheus Metrics

MySQL exporter exposes metrics on port 9104:

```bash
# Port forward to access metrics
kubectl port-forward -n db mysql-0 9104:9104

# View metrics
curl http://localhost:9104/metrics
```

### Key Metrics

- `mysql_up` - MySQL server availability
- `mysql_global_status_connections` - Total connections
- `mysql_global_status_queries` - Total queries
- `mysql_global_status_slow_queries` - Slow queries
- `mysql_global_status_threads_connected` - Active connections

### Grafana Dashboard

Import dashboard ID: 7362 (MySQL Overview)

## High Availability

### Replication Setup

Enable replication in values:

```yaml
replication:
  enabled: true

replicaCount: 3  # 1 primary + 2 replicas

configMap:
  serverId: 1
```

### PodDisruptionBudget

Ensures minimum availability during disruptions:

```yaml
podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

## Security

### Change Default Passwords

**IMPORTANT**: Change default passwords before production deployment!

```yaml
auth:
  rootPassword: "your-secure-root-password"
  password: "your-secure-app-password"
  replicationPassword: "your-secure-replication-password"
```

### NetworkPolicy

Restricts network access to MySQL:

```yaml
networkPolicy:
  enabled: true
  allowedNamespaces:
    - myapp
    - observability
```

### Security Context

Runs as non-root user:

```yaml
podSecurityContext:
  fsGroup: 999
  runAsUser: 999
  runAsGroup: 999
```

## Upgrading

### Upgrade Chart

```bash
# Upgrade to new version
helm upgrade mysql ./mysql -n db \
  --values values/values-production.yaml

# Check status
helm status mysql -n db
```

### Rollback

```bash
# Rollback to previous version
helm rollback mysql -n db

# Rollback to specific revision
helm rollback mysql 1 -n db
```

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status
kubectl get pods -n db

# View logs
kubectl logs -n db mysql-0

# Describe pod
kubectl describe pod -n db mysql-0
```

### Connection Issues

```bash
# Test connection from within cluster
kubectl run -it --rm mysql-test --image=mysql:8.4 --restart=Never -- \
  mysql -h mysql.db.svc.cluster.local -u root -p

# Check service
kubectl get svc -n db mysql

# Check endpoints
kubectl get endpoints -n db mysql
```

### Storage Issues

```bash
# Check PVC
kubectl get pvc -n db

# Describe PVC
kubectl describe pvc -n db data-mysql-0

# Check storage class
kubectl get storageclass
```

### Performance Issues

```bash
# Check resource usage
kubectl top pod -n db mysql-0

# View slow query log
kubectl exec -n db mysql-0 -- tail -f /var/log/mysql/slow.log

# Check connections
kubectl exec -n db mysql-0 -- mysql -u root -p${MYSQL_ROOT_PASSWORD} \
  -e "SHOW PROCESSLIST;"
```

## Uninstallation

```bash
# Uninstall release
helm uninstall mysql -n db

# Delete PVCs (WARNING: deletes all data)
kubectl delete pvc -n db -l app.kubernetes.io/name=mysql
```

## Environment-Specific Configurations

### Development (values-dev.yaml)
- Single instance
- Minimal resources (500m CPU, 512Mi RAM)
- Small storage (10Gi)
- Monitoring enabled
- No replication

### Production (values-production.yaml)
- Multiple replicas (3 instances)
- High resources (2 CPU, 4Gi RAM)
- Large storage (100Gi)
- Full monitoring with ServiceMonitor
- Replication enabled
- PodDisruptionBudget enabled
- NetworkPolicy enabled

## Support

For issues or questions:
- Check logs: `kubectl logs -n db mysql-0`
- Check events: `kubectl get events -n db`
- Review configuration: `helm get values mysql -n db`

## License

MIT License
