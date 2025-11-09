# MongoDB Helm Chart

Production-ready MongoDB Helm chart with replica sets, monitoring, and security.

## Features

- ✅ StatefulSet deployment with replica sets
- ✅ Prometheus metrics via mongodb-exporter
- ✅ ServiceMonitor for Prometheus Operator
- ✅ NetworkPolicy for security
- ✅ PodDisruptionBudget for HA
- ✅ Configurable resources and storage
- ✅ RBAC and security contexts

## Installation

```bash
# Development
helm install mongodb ./mongodb -n db \
  --create-namespace \
  --values values/values-dev.yaml

# Production
helm install mongodb ./mongodb -n db \
  --create-namespace \
  --values values/values-production.yaml
```

## Usage

```bash
# Get root password
export MONGODB_ROOT_PASSWORD=$(kubectl get secret mongodb -n db -o jsonpath="{.data.mongodb-root-password}" | base64 -d)

# Connect
kubectl run -it --rm mongo-client --image=mongo:7.0 --restart=Never -- \
  mongosh mongodb://root:${MONGODB_ROOT_PASSWORD}@mongodb-0.mongodb.db.svc.cluster.local:27017/admin

# Port forward
kubectl port-forward -n db svc/mongodb 27017:27017
mongosh mongodb://root:password@localhost:27017/admin
```

## Monitoring

```bash
# Access metrics
kubectl port-forward -n db mongodb-0 9216:9216
curl http://localhost:9216/metrics
```

Grafana Dashboard ID: 2583 (MongoDB Overview)

## Configuration

Key parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `auth.rootPassword` | Root password | `changeme` |
| `persistence.size` | Storage size | `20Gi` |
| `monitoring.enabled` | Enable metrics | `true` |
| `replicaSet.enabled` | Enable replica set | `false` |

## Backup

```bash
# Backup
kubectl exec -n db mongodb-0 -- mongodump --out=/tmp/backup

# Restore
kubectl exec -n db mongodb-0 -- mongorestore /tmp/backup
```

## License

MIT License
