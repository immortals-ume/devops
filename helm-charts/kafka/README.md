# Kafka Helm Chart

Production-ready Apache Kafka Helm chart with Zookeeper, monitoring, and HA.

## Features

- ✅ Kafka cluster with Zookeeper ensemble
- ✅ StatefulSet deployments
- ✅ Configurable brokers and partitions
- ✅ NetworkPolicy for security
- ✅ PodDisruptionBudget for HA
- ✅ Persistent storage
- ✅ Kafdrop UI (optional)

## Installation

```bash
# Development
helm install kafka ./kafka -n queue \
  --create-namespace \
  --values values/values-dev.yaml

# Production
helm install kafka ./kafka -n queue \
  --create-namespace \
  --values values/values-production.yaml
```

## Usage

```bash
# Create topic
kubectl exec -n queue kafka-0 -- kafka-topics --create \
  --topic test-topic \
  --bootstrap-server localhost:9092 \
  --partitions 3 \
  --replication-factor 3

# List topics
kubectl exec -n queue kafka-0 -- kafka-topics --list \
  --bootstrap-server localhost:9092

# Produce messages
kubectl exec -it -n queue kafka-0 -- kafka-console-producer \
  --topic test-topic \
  --bootstrap-server localhost:9092

# Consume messages
kubectl exec -it -n queue kafka-0 -- kafka-console-consumer \
  --topic test-topic \
  --bootstrap-server localhost:9092 \
  --from-beginning
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `kafka.replicaCount` | Number of Kafka brokers | `3` |
| `zookeeper.replicaCount` | Number of Zookeeper nodes | `3` |
| `kafka.persistence.size` | Kafka storage size | `20Gi` |
| `zookeeper.persistence.size` | Zookeeper storage size | `10Gi` |

## Monitoring

Access Kafdrop UI:
```bash
kubectl port-forward -n queue svc/kafdrop 9000:9000
# Open http://localhost:9000
```

## License

MIT License
