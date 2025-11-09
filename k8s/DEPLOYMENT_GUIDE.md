# Kubernetes Deployment Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Pre-Deployment Checklist](#pre-deployment-checklist)
3. [Deployment Steps](#deployment-steps)
4. [Post-Deployment Verification](#post-deployment-verification)
5. [Configuration](#configuration)
6. [Troubleshooting](#troubleshooting)

## Prerequisites

### Required Tools
- **kubectl** (v1.24+): Kubernetes command-line tool
- **Kubernetes cluster** (v1.24+): Running cluster with sufficient resources
- **StorageClass**: Configured for dynamic PV provisioning

### Optional Tools
- **Helm** (v3+): For Helm chart deployments
- **Ingress Controller**: For external access (nginx recommended)
- **Prometheus Operator**: For ServiceMonitor support
- **Argo Rollouts**: For advanced deployment strategies

### Cluster Requirements

#### Minimum Resources
- **Nodes**: 3+ nodes (for HA)
- **CPU**: 20+ cores total
- **Memory**: 40+ GB total
- **Storage**: 500+ GB available

#### Recommended Resources
- **Nodes**: 5+ nodes
- **CPU**: 40+ cores total
- **Memory**: 80+ GB total
- **Storage**: 1+ TB available

### Network Requirements
- **Pod Network**: Configured (Calico, Flannel, etc.)
- **Service Network**: Configured
- **DNS**: CoreDNS or kube-dns running
- **LoadBalancer**: Optional (for external access)

## Pre-Deployment Checklist

### 1. Cluster Validation
```bash
# Check cluster connectivity
kubectl cluster-info

# Check nodes
kubectl get nodes

# Check node resources
kubectl top nodes

# Check StorageClass
kubectl get storageclass

# Check DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default
```

### 2. Namespace Preparation
```bash
# Create namespaces
kubectl apply -f myapp/namespaces.yaml

# Label namespaces
kubectl label namespace db name=db
kubectl label namespace cache name=cache
kubectl label namespace queue name=queue
kubectl label namespace observability name=observability
kubectl label namespace vault name=vault
kubectl label namespace myapp name=myapp
kubectl label namespace kube-system name=kube-system
```

### 3. Secrets Configuration

**IMPORTANT**: Replace all placeholder secrets before deployment!

#### PostgreSQL Secrets
```bash
# Generate base64 encoded passwords
echo -n 'your-postgres-password' | base64
echo -n 'your-replicator-password' | base64

# Edit secret file
vi db/postgres-secret.yaml
```

#### MySQL Secrets
```bash
# Generate base64 encoded passwords
echo -n 'your-root-password' | base64
echo -n 'your-user' | base64
echo -n 'your-user-password' | base64

# Edit secret file
vi db/mysql-secret.yaml
```

#### MongoDB Secrets
```bash
# Generate base64 encoded passwords
echo -n 'your-root-password' | base64
echo -n 'your-user' | base64
echo -n 'your-user-password' | base64

# Edit secret file
vi db/mongodb-secret.yaml
```

#### Grafana Secrets
```bash
# Generate base64 encoded credentials
echo -n 'admin' | base64
echo -n 'your-admin-password' | base64

# Edit secret file
vi observability/grafana-secrets.yaml
```

#### Vault Secrets
```bash
# Generate base64 encoded token
echo -n 'your-root-token' | base64

# Edit secret file
vi vault/vault-secrets.yaml
```

### 4. Resource Sizing Review

Review and adjust resource limits in manifests based on your workload:

- `db/postgres-primary-statefulset.yaml`
- `db/postgres-replica-statefulset.yaml`
- `db/mysql-deployment.yaml`
- `db/mongodb-write-deployment.yaml`
- `db/mongodb-read-deployment.yaml`
- `cache/redis-standalone-deployment.yaml`
- `cache/redis-cluster-statefulset.yaml`
- `queue/kafka-statefulset.yaml`
- `queue/zookeeper-statefulset.yaml`
- `observability/prometheus-deployment.yaml`
- `observability/grafana-deployment.yaml`

### 5. Storage Sizing Review

Review and adjust PVC sizes based on your data requirements:

| Component | Default Size | Adjust In |
|-----------|--------------|-----------|
| PostgreSQL | 20Gi | postgres-*-statefulset.yaml |
| MySQL | 20Gi | mysql-deployment.yaml |
| MongoDB | 20Gi | mongodb-*-deployment.yaml |
| Redis | 10Gi | redis-*-deployment.yaml |
| Kafka | 20Gi | kafka-statefulset.yaml |
| Zookeeper | 10Gi | zookeeper-statefulset.yaml |
| Prometheus | 50Gi | prometheus-deployment.yaml |
| Grafana | 10Gi | grafana-deployment.yaml |
| Loki | 20Gi | loki-deployment.yaml |
| Tempo | 20Gi | tempo-deployment.yaml |
| Vault | 10Gi | vault-deployment.yaml |

## Deployment Steps

### Option 1: Automated Deployment (Recommended)

```bash
# Deploy everything
./deploy.sh --all

# Or deploy specific components
./deploy.sh --db --cache --observability
```

### Option 2: Manual Deployment

#### Step 1: Deploy Database Stack
```bash
# PostgreSQL
kubectl apply -f db/postgres-configmap.yaml
kubectl apply -f db/postgres-secret.yaml
kubectl apply -f db/postgres-primary-statefulset.yaml

# Wait for primary to be ready
kubectl wait --for=condition=ready pod/postgres-primary-0 -n db --timeout=300s

# Deploy replicas
kubectl apply -f db/postgres-replica-statefulset.yaml

# MySQL
kubectl apply -f db/mysql-configmap.yaml
kubectl apply -f db/mysql-secret.yaml
kubectl apply -f db/mysql-deployment.yaml

# MongoDB
kubectl apply -f db/mongodb-configmap.yaml
kubectl apply -f db/mongodb-secret.yaml
kubectl apply -f db/mongodb-write-deployment.yaml
kubectl apply -f db/mongodb-read-deployment.yaml

# H2 (optional, dev only)
kubectl apply -f db/h2-deployment.yaml

# Network Policy
kubectl apply -f db/networkpolicy.yaml
```

#### Step 2: Deploy Cache Stack
```bash
# Redis Standalone
kubectl apply -f cache/redis-standalone-configmap.yaml
kubectl apply -f cache/redis-standalone-deployment.yaml

# Redis Cluster
kubectl apply -f cache/redis-cluster-configmap.yaml
kubectl apply -f cache/redis-cluster-statefulset.yaml

# Wait for Redis cluster pods
kubectl wait --for=condition=ready pod -l app=redis-cluster -n cache --timeout=300s

# Initialize Redis cluster (run once)
kubectl apply -f cache/redis-cluster-statefulset.yaml | grep "Job"

# Redis Sentinel (optional)
kubectl apply -f cache/redis-sentinel-configmap.yaml
kubectl apply -f cache/redis-sentinel-statefulset.yaml

# Network Policy
kubectl apply -f cache/networkpolicy.yaml
```

#### Step 3: Deploy Queue Stack
```bash
# Zookeeper
kubectl apply -f queue/zookeeper-statefulset.yaml

# Wait for Zookeeper
kubectl wait --for=condition=ready pod -l app=zookeeper -n queue --timeout=300s

# Kafka
kubectl apply -f queue/kafka-configmap.yaml
kubectl apply -f queue/kafka-statefulset.yaml

# Wait for Kafka
kubectl wait --for=condition=ready pod -l app=kafka -n queue --timeout=300s

# Kafdrop (Kafka UI)
kubectl apply -f queue/kafdrop-deployment.yaml

# Network Policy
kubectl apply -f queue/networkpolicy.yaml
```

#### Step 4: Deploy Observability Stack
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

# Fluent-bit
kubectl apply -f observability/fluent-bit-configmap.yaml
kubectl apply -f observability/fluent-bit-deployment.yaml

# Tempo
kubectl apply -f observability/tempo-deployment.yaml

# ServiceMonitors (if Prometheus Operator installed)
kubectl apply -f observability/servicemonitors.yaml

# Network Policy
kubectl apply -f observability/networkpolicy.yaml
```

#### Step 5: Deploy Vault
```bash
kubectl apply -f vault/vault-secrets.yaml
kubectl apply -f vault/vault-configmap.yaml
kubectl apply -f vault/vault-deployment.yaml
kubectl apply -f vault/networkpolicy.yaml

# Wait for Vault
kubectl wait --for=condition=ready pod -l app=vault -n vault --timeout=300s

# Initialize Vault (first time only)
kubectl exec -n vault vault-0 -- vault operator init
```

#### Step 6: Deploy Application (Optional)
```bash
kubectl apply -f myapp/enterprise-app.yaml
```

## Post-Deployment Verification

### 1. Check Pod Status
```bash
# All pods should be Running
kubectl get pods -A

# Check specific namespaces
kubectl get pods -n db
kubectl get pods -n cache
kubectl get pods -n queue
kubectl get pods -n observability
kubectl get pods -n vault
```

### 2. Check Services
```bash
# All services should have endpoints
kubectl get svc -A
kubectl get endpoints -A
```

### 3. Check PVCs
```bash
# All PVCs should be Bound
kubectl get pvc -A
```

### 4. Check Logs
```bash
# Check for errors in logs
kubectl logs -l app=postgres-primary -n db --tail=50
kubectl logs -l app=mysql -n db --tail=50
kubectl logs -l app=mongodb-write -n db --tail=50
kubectl logs -l app=redis-standalone -n cache --tail=50
kubectl logs -l app=kafka -n queue --tail=50
kubectl logs -l app=prometheus -n observability --tail=50
```

### 5. Test Database Connectivity

#### PostgreSQL
```bash
kubectl run -it --rm psql-test --image=postgres:16.2-alpine --restart=Never -- \
  psql -h postgres-primary.db.svc.cluster.local -U postgres -c "SELECT version();"
```

#### MySQL
```bash
kubectl run -it --rm mysql-test --image=mysql:8.4 --restart=Never -- \
  mysql -h mysql.db.svc.cluster.local -u root -p -e "SELECT VERSION();"
```

#### MongoDB
```bash
kubectl run -it --rm mongo-test --image=mongo:7.0 --restart=Never -- \
  mongosh mongodb://mongodb-write.db.svc.cluster.local:27017 --eval "db.version()"
```

#### Redis
```bash
kubectl run -it --rm redis-test --image=redis:7.2-alpine --restart=Never -- \
  redis-cli -h redis-standalone.cache.svc.cluster.local PING
```

### 6. Test Kafka
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
```

### 7. Access Monitoring

#### Prometheus
```bash
kubectl port-forward -n observability svc/prometheus 9090:9090
# Access: http://localhost:9090
```

#### Grafana
```bash
kubectl port-forward -n observability svc/grafana 3000:3000
# Access: http://localhost:3000
# Login: admin / <your-password>
```

#### Kafdrop
```bash
kubectl port-forward -n queue svc/kafdrop 9000:9000
# Access: http://localhost:9000
```

### 8. Verify Metrics Collection
```bash
# Check Prometheus targets
kubectl port-forward -n observability svc/prometheus 9090:9090
# Navigate to: http://localhost:9090/targets

# All targets should be UP
```

### 9. Verify Log Collection
```bash
# Check Loki
kubectl port-forward -n observability svc/loki 3100:3100

# Query logs
curl -G -s "http://localhost:3100/loki/api/v1/query" \
  --data-urlencode 'query={namespace="db"}' | jq
```

## Configuration

### Ingress Setup (Optional)

If you have an Ingress controller installed:

```yaml
# grafana-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: grafana-ingress
  namespace: observability
spec:
  ingressClassName: nginx
  rules:
    - host: grafana.yourdomain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: grafana
                port:
                  number: 3000
```

Apply:
```bash
kubectl apply -f grafana-ingress.yaml
```

### TLS/SSL Setup (Optional)

Using cert-manager:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: grafana-tls
  namespace: observability
spec:
  secretName: grafana-tls
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
  dnsNames:
    - grafana.yourdomain.com
```

### Backup Configuration

#### PostgreSQL Backup CronJob
```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: postgres-backup
  namespace: db
spec:
  schedule: "0 2 * * *"  # Daily at 2 AM
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup
              image: postgres:16.2-alpine
              command:
                - /bin/sh
                - -c
                - pg_dump -h postgres-primary -U postgres mydatabase > /backup/backup-$(date +%Y%m%d).sql
              volumeMounts:
                - name: backup
                  mountPath: /backup
          volumes:
            - name: backup
              persistentVolumeClaim:
                claimName: postgres-backup
          restartPolicy: OnFailure
```

## Troubleshooting

### Common Issues

#### 1. Pods Stuck in Pending
**Cause**: Insufficient resources or PVC provisioning issues

**Solution**:
```bash
# Check node resources
kubectl top nodes

# Check PVC status
kubectl get pvc -A

# Describe pod for details
kubectl describe pod <pod-name> -n <namespace>
```

#### 2. CrashLoopBackOff
**Cause**: Application errors or misconfiguration

**Solution**:
```bash
# Check logs
kubectl logs <pod-name> -n <namespace>

# Check previous logs
kubectl logs --previous <pod-name> -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'
```

#### 3. Network Connectivity Issues
**Cause**: NetworkPolicy restrictions or DNS issues

**Solution**:
```bash
# Test DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  nslookup postgres-primary.db.svc.cluster.local

# Test connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  telnet postgres-primary.db.svc.cluster.local 5432

# Check NetworkPolicy
kubectl describe networkpolicy -n db
```

#### 4. Storage Issues
**Cause**: StorageClass not configured or insufficient storage

**Solution**:
```bash
# Check StorageClass
kubectl get storageclass

# Check PV provisioning
kubectl get pv

# Describe PVC
kubectl describe pvc <pvc-name> -n <namespace>
```

#### 5. Permission Denied Errors
**Cause**: Security context or volume permissions

**Solution**:
```bash
# Check pod security context
kubectl get pod <pod-name> -n <namespace> -o yaml | grep -A 10 securityContext

# Check init container logs
kubectl logs <pod-name> -n <namespace> -c init-permissions
```

### Getting Help

1. **Check Documentation**: Review README.md and QUICK_REFERENCE.md
2. **Check Logs**: Always start with pod logs
3. **Check Events**: Kubernetes events provide valuable information
4. **Describe Resources**: Use `kubectl describe` for detailed information
5. **Community Support**: Kubernetes Slack, Stack Overflow, GitHub Issues

## Rollback Procedures

### Rollback StatefulSet
```bash
kubectl rollout undo statefulset/<name> -n <namespace>
```

### Rollback Deployment
```bash
kubectl rollout undo deployment/<name> -n <namespace>
```

### Complete Rollback
```bash
# Delete all resources
kubectl delete -f db/ -n db
kubectl delete -f cache/ -n cache
kubectl delete -f queue/ -n queue
kubectl delete -f observability/ -n observability
kubectl delete -f vault/ -n vault

# Restore from backup
# (Follow backup restore procedures)
```

## Maintenance Windows

### Recommended Maintenance Schedule
- **Daily**: Check pod status and logs
- **Weekly**: Review resource usage and metrics
- **Monthly**: Update images and apply security patches
- **Quarterly**: Review and optimize resource allocations

### Maintenance Checklist
- [ ] Backup all databases
- [ ] Check for image updates
- [ ] Review security advisories
- [ ] Test disaster recovery procedures
- [ ] Review and update documentation
- [ ] Check certificate expiration
- [ ] Review and optimize costs
- [ ] Update monitoring dashboards

## Support Contacts

- **Kubernetes Documentation**: https://kubernetes.io/docs/
- **Project Repository**: [Your repository URL]
- **Issue Tracker**: [Your issue tracker URL]
- **Team Contact**: [Your team contact]

## Appendix

### A. Resource Calculation

Total resources required for full deployment:

**CPU**:
- Database: 6 cores (3 services × 2 cores)
- Cache: 2 cores
- Queue: 6 cores (3 Kafka + 3 Zookeeper)
- Observability: 8 cores
- Vault: 1 core
- **Total**: ~23 cores

**Memory**:
- Database: 12 GB
- Cache: 2 GB
- Queue: 9 GB
- Observability: 12 GB
- Vault: 2 GB
- **Total**: ~37 GB

**Storage**:
- Database: 120 GB
- Cache: 30 GB
- Queue: 90 GB
- Observability: 80 GB
- Vault: 10 GB
- **Total**: ~330 GB

### B. Network Ports

| Service | Port | Protocol | Purpose |
|---------|------|----------|---------|
| PostgreSQL | 5432 | TCP | Database |
| MySQL | 3306 | TCP | Database |
| MongoDB | 27017 | TCP | Database |
| Redis | 6379 | TCP | Cache |
| Kafka | 9092 | TCP | Message Queue |
| Zookeeper | 2181 | TCP | Coordination |
| Prometheus | 9090 | TCP | Metrics |
| Grafana | 3000 | TCP | Visualization |
| Loki | 3100 | TCP | Logs |
| Tempo | 3200 | TCP | Traces |
| Vault | 8200 | TCP | Secrets |
| Kafdrop | 9000 | TCP | Kafka UI |

### C. Security Hardening

1. **Enable Pod Security Standards**
2. **Use Network Policies** (already configured)
3. **Enable Audit Logging**
4. **Use Secrets Management** (Vault or External Secrets)
5. **Enable TLS for all services**
6. **Regular security scans**
7. **Implement RBAC policies**
8. **Use private container registries**
9. **Enable resource quotas**
10. **Implement admission controllers**
