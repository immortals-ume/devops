# Kubernetes Infrastructure Setup

Production-ready Kubernetes manifests for deploying a complete infrastructure stack including databases, caching, message queues, observability, and secrets management.

## Overview

This directory contains upgraded, production-grade Kubernetes manifests with:

- **ServiceAccounts & RBAC** for proper access control
- **NetworkPolicies** for network segmentation
- **PodSecurityContext** for enhanced security
- **Resource limits & requests** for proper resource management
- **Liveness & Readiness probes** for health monitoring
- **PodDisruptionBudgets (PDB)** for high availability
- **HorizontalPodAutoscalers (HPA)** for auto-scaling
- **Prometheus exporters** for metrics collection
- **Init containers** for proper initialization
- **Anti-affinity rules** for pod distribution

## Directory Structure

```
k8s/
├── db/                    # Database services (PostgreSQL, MySQL, MongoDB)
├── cache/                 # Redis caching (standalone, cluster, sentinel)
├── queue/                 # Kafka & Zookeeper
├── observability/         # Prometheus, Grafana, Loki, Tempo, Fluent-bit
├── vault/                 # HashiCorp Vault
└── myapp/                 # Application deployments
```

## Prerequisites

- Kubernetes cluster (v1.24+)
- kubectl configured
- StorageClass configured for PersistentVolumes
- (Optional) Ingress controller (nginx)
- (Optional) Prometheus Operator for ServiceMonitors
- (Optional) Argo Rollouts for advanced deployments

## Quick Start

### 1. Create Namespaces

```bash
kubectl apply -f myapp/namespaces.yaml
```

This creates:
- `db` - Database services
- `cache` - Redis caching
- `queue` - Kafka & Zookeeper
- `observability` - Monitoring stack
- `vault` - Secrets management
- `myapp` - Application workloads

### 2. Label Namespaces (for NetworkPolicies)

```bash
kubectl label namespace db name=db
kubectl label namespace cache name=cache
kubectl label namespace queue name=queue
kubectl label namespace observability name=observability
kubectl label namespace vault name=vault
kubectl label namespace myapp name=myapp
kubectl label namespace kube-system name=kube-system
```

### 3. Deploy Infrastructure Components

#### Database Stack

```bash
# PostgreSQL (Primary + Replicas)
kubectl apply -f db/postgres-configmap.yaml
kubectl apply -f db/postgres-secret.yaml
kubectl apply -f db/postgres-primary-statefulset.yaml
kubectl apply -f db/postgres-replica-statefulset.yaml

# MySQL
kubectl apply -f db/mysql-configmap.yaml
kubectl apply -f db/mysql-secret.yaml
kubectl apply -f db/mysql-deployment.yaml

# MongoDB (Write + Read replicas)
kubectl apply -f db/mongodb-configmap.yaml
kubectl apply -f db/mongodb-secret.yaml
kubectl apply -f db/mongodb-write-deployment.yaml
kubectl apply -f db/mongodb-read-deployment.yaml

# H2 (Development only)
kubectl apply -f db/h2-deployment.yaml

# Network Policy
kubectl apply -f db/networkpolicy.yaml
```

#### Cache Stack (Redis)

```bash
# Standalone Redis
kubectl apply -f cache/redis-standalone-configmap.yaml
kubectl apply -f cache/redis-standalone-deployment.yaml

# Redis Cluster (6 nodes)
kubectl apply -f cache/redis-cluster-configmap.yaml
kubectl apply -f cache/redis-cluster-statefulset.yaml

# Redis Sentinel (HA setup)
kubectl apply -f cache/redis-sentinel-configmap.yaml
kubectl apply -f cache/redis-sentinel-statefulset.yaml

# Network Policy
kubectl apply -f cache/networkpolicy.yaml
```

#### Queue Stack (Kafka)

```bash
# Zookeeper (3 nodes)
kubectl apply -f queue/zookeeper-statefulset.yaml

# Kafka (3 brokers)
kubectl apply -f queue/kafka-configmap.yaml
kubectl apply -f queue/kafka-statefulset.yaml

# Kafdrop (Kafka UI)
kubectl apply -f queue/kafdrop-deployment.yaml

# Network Policy
kubectl apply -f queue/networkpolicy.yaml
```

#### Observability Stack

```bash
# Prometheus
kubectl apply -f observability/prometheus-configmap.yaml
kubectl apply -f observability/prometheus-deployment.yaml

# Grafana
kubectl apply -f observability/grafana-secrets.yaml
kubectl apply -f observability/grafana-deployment.yaml

# Loki
kubectl apply -f observability/loki-configmap.yaml
kubectl apply -f observability/loki-deployment.yaml

# Fluent-bit (Log collector)
kubectl apply -f observability/fluent-bit-configmap.yaml
kubectl apply -f observability/fluent-bit-deployment.yaml

# Tempo (Distributed tracing)
kubectl apply -f observability/tempo-deployment.yaml

# Network Policy
kubectl apply -f observability/networkpolicy.yaml
```

#### Vault (Secrets Management)

```bash
kubectl apply -f vault/vault-secrets.yaml
kubectl apply -f vault/vault-configmap.yaml
kubectl apply -f vault/vault-deployment.yaml
kubectl apply -f vault/networkpolicy.yaml
```

### 4. Deploy Application

```bash
kubectl apply -f myapp/enterprise-app.yaml
```

## Configuration

### Secrets Management

All secrets use base64 encoding. To encode a secret:

```bash
echo -n 'your-password' | base64
```

**Important:** Replace placeholder secrets in production with:
- Kubernetes Secrets (encrypted at rest)
- SealedSecrets (Bitnami)
- External Secrets Operator
- HashiCorp Vault integration

### Resource Sizing

Default resource allocations:

| Component | CPU Request | Memory Request | CPU Limit | Memory Limit |
|-----------|-------------|----------------|-----------|--------------|
| PostgreSQL | 500m | 512Mi | 2 | 2Gi |
| MySQL | 500m | 512Mi | 2 | 2Gi |
| MongoDB | 500m | 512Mi | 2 | 2Gi |
| Redis | 250m | 256Mi | 1 | 512Mi |
| Kafka | 1 | 1Gi | 2 | 2Gi |
| Zookeeper | 500m | 512Mi | 1 | 1Gi |
| Prometheus | 500m | 1Gi | 2 | 4Gi |
| Grafana | 250m | 512Mi | 1 | 2Gi |
| Loki | 500m | 512Mi | 2 | 2Gi |
| Tempo | 500m | 512Mi | 2 | 2Gi |

Adjust based on your workload requirements.

### Storage

Default PVC sizes:

- PostgreSQL: 20Gi per instance
- MySQL: 20Gi
- MongoDB: 20Gi per instance
- Redis: 10Gi
- Kafka: 20Gi per broker
- Zookeeper: 10Gi per instance
- Prometheus: 50Gi
- Grafana: 10Gi
- Loki: 20Gi
- Tempo: 20Gi
- Vault: 10Gi

## High Availability Features

### PodDisruptionBudgets (PDB)

All critical services have PDBs to ensure minimum availability during:
- Node maintenance
- Cluster upgrades
- Voluntary disruptions

### HorizontalPodAutoscalers (HPA)

MongoDB read replicas auto-scale based on:
- CPU utilization (70%)
- Memory utilization (80%)

### Anti-Affinity Rules

StatefulSets use pod anti-affinity to distribute pods across nodes for:
- PostgreSQL
- MySQL
- MongoDB
- Redis Cluster
- Kafka
- Zookeeper

## Monitoring & Observability

### Prometheus Metrics

All services expose metrics via sidecars:

- **PostgreSQL**: postgres-exporter (port 9187)
- **MySQL**: mysqld-exporter (port 9104)
- **MongoDB**: mongodb-exporter (port 9216)
- **Redis**: redis-exporter (port 9121)
- **Kafka**: kafka-exporter (port 9308)

### Grafana Dashboards

Access Grafana at: `http://grafana.local` (configure Ingress)

Pre-configured datasources:
- Prometheus (metrics)
- Loki (logs)
- Tempo (traces)

### Log Aggregation

Fluent-bit DaemonSet collects logs from all pods and forwards to Loki.

## Network Security

### NetworkPolicies

Each namespace has NetworkPolicy rules:

- **db**: Allows traffic from `myapp` and `observability` namespaces
- **cache**: Allows traffic from `myapp` and `observability` namespaces
- **queue**: Allows traffic from `myapp` and `observability` namespaces
- **observability**: Allows traffic from all namespaces (for metrics scraping)
- **vault**: Allows traffic from `myapp` and `observability` namespaces

All namespaces allow:
- DNS resolution (kube-system)
- Internal pod-to-pod communication

## Accessing Services

### Internal Access (within cluster)

Services are accessible via DNS:

```
<service-name>.<namespace>.svc.cluster.local:<port>
```

Examples:
- PostgreSQL Primary: `postgres-primary.db.svc.cluster.local:5432`
- MySQL: `mysql.db.svc.cluster.local:3306`
- MongoDB Write: `mongodb-write.db.svc.cluster.local:27017`
- Redis: `redis-standalone.cache.svc.cluster.local:6379`
- Kafka: `kafka-0.kafka.queue.svc.cluster.local:9092`
- Prometheus: `prometheus.observability.svc.cluster.local:9090`
- Grafana: `grafana.observability.svc.cluster.local:3000`

### External Access

Configure Ingress resources for external access:

```bash
# Add to /etc/hosts for local testing
echo "127.0.0.1 grafana.local prometheus.local kafdrop.local vault.local" | sudo tee -a /etc/hosts
```

Or use LoadBalancer services in cloud environments.

## Maintenance

### Backup Procedures

#### PostgreSQL

```bash
# Backup
kubectl exec -n db postgres-primary-0 -- pg_dump -U postgres mydatabase > backup.sql

# Restore
kubectl exec -i -n db postgres-primary-0 -- psql -U postgres mydatabase < backup.sql
```

#### MySQL

```bash
# Backup
kubectl exec -n db mysql-0 -- mysqldump -u root -p${MYSQL_ROOT_PASSWORD} mydatabase > backup.sql

# Restore
kubectl exec -i -n db mysql-0 -- mysql -u root -p${MYSQL_ROOT_PASSWORD} mydatabase < backup.sql
```

#### MongoDB

```bash
# Backup
kubectl exec -n db mongodb-write-0 -- mongodump --out=/tmp/backup

# Restore
kubectl exec -n db mongodb-write-0 -- mongorestore /tmp/backup
```

### Scaling

#### Scale StatefulSets

```bash
# Scale MongoDB read replicas
kubectl scale statefulset mongodb-read -n db --replicas=3

# Scale Kafka brokers
kubectl scale statefulset kafka -n queue --replicas=5

# Scale Zookeeper
kubectl scale statefulset zookeeper -n queue --replicas=5
```

#### Scale Deployments

```bash
# Scale Redis standalone
kubectl scale deployment redis-standalone -n cache --replicas=2
```

### Updates & Rollouts

```bash
# Update image
kubectl set image statefulset/postgres-primary -n db postgres=postgres:16.3-alpine

# Check rollout status
kubectl rollout status statefulset/postgres-primary -n db

# Rollback if needed
kubectl rollout undo statefulset/postgres-primary -n db
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -A
kubectl describe pod <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace>
```

### Check Services

```bash
kubectl get svc -A
kubectl describe svc <service-name> -n <namespace>
```

### Check PVCs

```bash
kubectl get pvc -A
kubectl describe pvc <pvc-name> -n <namespace>
```

### Network Connectivity

```bash
# Test from a pod
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
# Inside the pod:
nslookup postgres-primary.db.svc.cluster.local
telnet postgres-primary.db.svc.cluster.local 5432
```

### Common Issues

1. **Pods stuck in Pending**: Check PVC provisioning and node resources
2. **CrashLoopBackOff**: Check logs and resource limits
3. **Network connectivity issues**: Verify NetworkPolicies and DNS
4. **Storage issues**: Check StorageClass and PV provisioning

## Security Best Practices

1. **Use Secrets Management**: Replace base64 secrets with proper secret management
2. **Enable RBAC**: Use ServiceAccounts with minimal permissions
3. **Network Segmentation**: Keep NetworkPolicies enabled
4. **Resource Limits**: Always set resource requests and limits
5. **Security Contexts**: Run containers as non-root users
6. **Image Security**: Use specific image tags, not `latest`
7. **Regular Updates**: Keep images and Kubernetes version updated
8. **Audit Logging**: Enable Kubernetes audit logs
9. **Pod Security Standards**: Implement Pod Security Admission
10. **TLS/SSL**: Enable encryption for all external communications

## Production Checklist

- [ ] Replace all placeholder secrets
- [ ] Configure proper StorageClass
- [ ] Set up backup automation
- [ ] Configure monitoring alerts
- [ ] Enable TLS for external services
- [ ] Review and adjust resource limits
- [ ] Test disaster recovery procedures
- [ ] Configure log retention policies
- [ ] Set up CI/CD pipelines
- [ ] Document runbooks for operations
- [ ] Enable audit logging
- [ ] Configure network policies
- [ ] Test high availability scenarios
- [ ] Set up cost monitoring
- [ ] Configure auto-scaling policies

## Advanced Features

### Blue-Green Deployments

See `myapp/advanced/bluegreen-rollout.yaml` for Argo Rollouts configuration.

### Canary Deployments

See `myapp/advanced/canary-rollout.yaml` for progressive delivery.

### Custom Metrics HPA

See `myapp/advanced/hpa-custom-metrics.yaml` for custom metrics scaling.

## Support & Documentation

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Operator](https://prometheus-operator.dev/)
- [Argo Rollouts](https://argoproj.github.io/argo-rollouts/)
- [HashiCorp Vault](https://www.vaultproject.io/docs)

## License

MIT License - See LICENSE file for details
