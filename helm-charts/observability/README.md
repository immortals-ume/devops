# Observability Helm Chart

Complete observability stack with Prometheus, Grafana, and Loki.

## Features

- ✅ Prometheus for metrics collection
- ✅ Grafana for visualization
- ✅ Loki for log aggregation
- ✅ Tempo for distributed tracing (optional)
- ✅ Fluent-bit for log forwarding (optional)
- ✅ Pre-configured datasources
- ✅ NetworkPolicy for security

## Installation

```bash
# Development
helm install observability ./observability -n observability \
  --create-namespace \
  --values values/values-dev.yaml

# Production
helm install observability ./observability -n observability \
  --create-namespace \
  --values values/values-production.yaml
```

## Access Services

```bash
# Grafana
kubectl port-forward -n observability svc/observability-grafana 3000:3000
# Open http://localhost:3000 (admin/admin)

# Prometheus
kubectl port-forward -n observability svc/observability-prometheus 9090:9090
# Open http://localhost:9090

# Loki
kubectl port-forward -n observability svc/observability-loki 3100:3100
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `prometheus.replicaCount` | Prometheus replicas | `1` |
| `grafana.replicaCount` | Grafana replicas | `1` |
| `grafana.adminPassword` | Grafana admin password | `admin` |
| `loki.replicaCount` | Loki replicas | `1` |
| `prometheus.persistence.size` | Prometheus storage | `50Gi` |

## Grafana Dashboards

Import popular dashboards:
- Node Exporter: 1860
- PostgreSQL: 9628
- MySQL: 7362
- MongoDB: 2583
- Redis: 11835
- Kafka: 7589

## Querying Logs

```bash
# Query Loki
curl -G -s "http://localhost:3100/loki/api/v1/query" \
  --data-urlencode 'query={namespace="db"}'
```

## License

MIT License
