# Kubernetes Quick Reference Guide

## Deployment Commands

### Deploy Everything
```bash
cd k8s
./deploy.sh --all
```

### Deploy Specific Components
```bash
./deploy.sh --db                # Database stack only
./deploy.sh --cache             # Redis cache only
./deploy.sh --queue             # Kafka & Zookeeper only
./deploy.sh --observability     # Monitoring stack only
./deploy.sh --vault             # Vault only
./deploy.sh --app               # Application only
```

### Deploy Multiple Components
```bash
./deploy.sh --db --cache --observability
```

## Service Endpoints (Internal)

### Databases
```
postgres-primary.db.svc.cluster.local:5432
postgres-replica.db.svc.cluster.local:5432
mysql.db.svc.cluster.local:3306
mongodb-write.db.svc.cluster.local:27017
mongodb-read.db.svc.cluster.local:27017
h2.db.svc.cluster.local:8082
```

### Cache
```
redis-standalone.cache.svc.cluster.local:6379
redis-cluster.cache.svc.cluster.local:6379
redis-master.cache.svc.cluster.local:6379
```

### Queue
```
kafka-0.kafka.queue.svc.cluster.local:9092
kafka-1.kafka.queue.svc.cluster.local:9092
kafka-2.kafka.queue.svc.cluster.local:9092
zookeeper-0.zookeeper.queue.svc.cluster.local:2181
kafdrop.queue.svc.cluster.local:9000
```

### Observability
```
prometheus.observability.svc.cluster.local:9090
grafana.observability.svc.cluster.local:3000
loki.observability.svc.cluster.local:3100
tempo.observability.svc.cluster.local:3200
fluent-bit.observability.svc.cluster.local:24224
```

### Vault
```
vault.vault.svc.cluster.local:8200
```

## Port Forwarding

### Access Services Locally
```bash
# Grafana
kubectl port-forward -n observability svc/grafana 3000:3000
# Access: http://localhost:3000

# Prometheus
kubectl port-forward -n observability svc/prometheus 9090:9090
# Access: http://localhost:9090

# Kafdrop (Kafka UI)
kubectl port-forward -n queue svc/kafdrop 9000:9000
# Access: http://localhost:9000

# Vault
kubectl port-forward -n vault svc/vault 8200:8200
# Access: http://localhost:8200

# PostgreSQL
kubectl port-forward -n db svc/postgres-primary 5432:5432
# Connect: psql -h localhost -p 5432 -U postgres

# MySQL
kubectl port-forward -n db svc/mysql 3306:3306
# Connect: mysql -h localhost -P 3306 -u root -p

# MongoDB
kubectl port-forward -n db svc/mongodb-write 27017:27017
# Connect: mongosh mongodb://localhost:27017

# Redis
kubectl port-forward -n cache svc/redis-standalone 6379:6379
# Connect: redis-cli -h localhost -p 6379
```

## Common kubectl Commands

### Check Status
```bash
# All pods
kubectl get pods -A

# Specific namespace
kubectl get pods -n db
kubectl get pods -n cache
kubectl get pods -n queue
kubectl get pods -n observability

# Watch pods
kubectl get pods -A -w

# All services
kubectl get svc -A

# All PVCs
kubectl get pvc -A

# All StatefulSets
kubectl get statefulsets -A

# All Deployments
kubectl get deployments -A
```

### Logs
```bash
# View logs
kubectl logs <pod-name> -n <namespace>

# Follow logs
kubectl logs -f <pod-name> -n <namespace>

# Previous logs (after crash)
kubectl logs --previous <pod-name> -n <namespace>

# Logs from specific container
kubectl logs <pod-name> -n <namespace> -c <container-name>

# Logs from all pods with label
kubectl logs -l app=postgres -n db
```

### Describe Resources
```bash
# Describe pod
kubectl describe pod <pod-name> -n <namespace>

# Describe service
kubectl describe svc <service-name> -n <namespace>

# Describe PVC
kubectl describe pvc <pvc-name> -n <namespace>

# Describe StatefulSet
kubectl describe statefulset <statefulset-name> -n <namespace>
```

### Execute Commands in Pods
```bash
# PostgreSQL
kubectl exec -it postgres-primary-0 -n db -- psql -U postgres

# MySQL
kubectl exec -it mysql-0 -n db -- mysql -u root -p

# MongoDB
kubectl exec -it mongodb-write-0 -n db -- mongosh

# Redis
kubectl exec -it redis-standalone-<pod-id> -n cache -- redis-cli

# Shell access
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh
```

## Scaling

### Scale StatefulSets
```bash
# Scale MongoDB read replicas
kubectl scale statefulset mongodb-read -n db --replicas=3

# Scale Kafka brokers
kubectl scale statefulset kafka -n queue --replicas=5

# Scale Zookeeper
kubectl scale statefulset zookeeper -n queue --replicas=5

# Scale Redis cluster
kubectl scale statefulset redis-cluster -n cache --replicas=8
```

### Scale Deployments
```bash
# Scale Redis standalone
kubectl scale deployment redis-standalone -n cache --replicas=2

# Scale Grafana
kubectl scale deployment grafana -n observability --replicas=2
```

## Updates & Rollouts

### Update Image
```bash
# Update StatefulSet image
kubectl set image statefulset/postgres-primary -n db postgres=postgres:16.3-alpine

# Update Deployment image
kubectl set image deployment/grafana -n observability grafana=grafana/grafana:10.4.0
```

### Check Rollout Status
```bash
kubectl rollout status statefulset/postgres-primary -n db
kubectl rollout status deployment/grafana -n observability
```

### Rollback
```bash
kubectl rollout undo statefulset/postgres-primary -n db
kubectl rollout undo deployment/grafana -n observability
```

### Restart
```bash
kubectl rollout restart statefulset/postgres-primary -n db
kubectl rollout restart deployment/grafana -n observability
```

## Secrets Management

### View Secrets
```bash
kubectl get secrets -n db
kubectl describe secret postgres-secrets -n db
```

### Decode Secret
```bash
kubectl get secret postgres-secrets -n db -o jsonpath='{.data.postgres-user}' | base64 -d
```

### Create Secret
```bash
kubectl create secret generic my-secret -n db \
  --from-literal=username=admin \
  --from-literal=password=secret123
```

### Update Secret
```bash
# Encode value
echo -n 'new-password' | base64

# Edit secret
kubectl edit secret postgres-secrets -n db
```

## Backup & Restore

### PostgreSQL
```bash
# Backup
kubectl exec -n db postgres-primary-0 -- pg_dump -U postgres mydatabase > backup.sql

# Restore
kubectl exec -i -n db postgres-primary-0 -- psql -U postgres mydatabase < backup.sql
```

### MySQL
```bash
# Backup
kubectl exec -n db mysql-0 -- mysqldump -u root -p${MYSQL_ROOT_PASSWORD} mydatabase > backup.sql

# Restore
kubectl exec -i -n db mysql-0 -- mysql -u root -p${MYSQL_ROOT_PASSWORD} mydatabase < backup.sql
```

### MongoDB
```bash
# Backup
kubectl exec -n db mongodb-write-0 -- mongodump --out=/tmp/backup

# Copy backup
kubectl cp db/mongodb-write-0:/tmp/backup ./backup

# Restore
kubectl cp ./backup db/mongodb-write-0:/tmp/backup
kubectl exec -n db mongodb-write-0 -- mongorestore /tmp/backup
```

## Troubleshooting

### Pod Issues
```bash
# Check pod status
kubectl get pod <pod-name> -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Describe pod
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>

# Check previous logs (if crashed)
kubectl logs --previous <pod-name> -n <namespace>
```

### Network Issues
```bash
# Test DNS
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup postgres-primary.db.svc.cluster.local

# Test connectivity
kubectl run -it --rm debug --image=busybox --restart=Never -- telnet postgres-primary.db.svc.cluster.local 5432

# Check NetworkPolicy
kubectl describe networkpolicy -n db

# Check service endpoints
kubectl get endpoints -n db
```

### Storage Issues
```bash
# Check PVCs
kubectl get pvc -A

# Describe PVC
kubectl describe pvc <pvc-name> -n <namespace>

# Check PVs
kubectl get pv

# Check StorageClass
kubectl get storageclass
```

### Resource Issues
```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -A

# Describe node
kubectl describe node <node-name>

# Check resource quotas
kubectl get resourcequota -A
```

## Monitoring

### Prometheus Queries
```bash
# Port forward Prometheus
kubectl port-forward -n observability svc/prometheus 9090:9090

# Access: http://localhost:9090
```

Common queries:
```promql
# CPU usage
rate(container_cpu_usage_seconds_total[5m])

# Memory usage
container_memory_usage_bytes

# Disk usage
kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes

# Pod restarts
kube_pod_container_status_restarts_total
```

### Grafana Dashboards
```bash
# Port forward Grafana
kubectl port-forward -n observability svc/grafana 3000:3000

# Access: http://localhost:3000
# Default credentials: admin/admin (change in grafana-secrets.yaml)
```

### Loki Logs
```bash
# Port forward Loki
kubectl port-forward -n observability svc/loki 3100:3100

# Query logs
curl -G -s "http://localhost:3100/loki/api/v1/query" --data-urlencode 'query={namespace="db"}'
```

## Cleanup

### Delete Specific Components
```bash
# Delete database stack
kubectl delete -f db/ -n db

# Delete cache stack
kubectl delete -f cache/ -n cache

# Delete queue stack
kubectl delete -f queue/ -n queue

# Delete observability stack
kubectl delete -f observability/ -n observability

# Delete vault
kubectl delete -f vault/ -n vault
```

### Delete Namespaces (includes all resources)
```bash
kubectl delete namespace db
kubectl delete namespace cache
kubectl delete namespace queue
kubectl delete namespace observability
kubectl delete namespace vault
kubectl delete namespace myapp
```

### Delete PVCs (data will be lost)
```bash
kubectl delete pvc --all -n db
kubectl delete pvc --all -n cache
kubectl delete pvc --all -n queue
kubectl delete pvc --all -n observability
kubectl delete pvc --all -n vault
```

## Useful Aliases

Add to your `~/.bashrc` or `~/.zshrc`:

```bash
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kd='kubectl describe'
alias kl='kubectl logs'
alias kex='kubectl exec -it'
alias kpf='kubectl port-forward'
alias kgpa='kubectl get pods -A'
alias kgsa='kubectl get svc -A'
alias kgpvc='kubectl get pvc -A'
```

## Default Credentials

**Important**: Change these in production!

### Grafana
- Username: `admin`
- Password: Set in `observability/grafana-secrets.yaml`

### Vault
- Root Token: Set in `vault/vault-secrets.yaml`

### Databases
- PostgreSQL: Set in `db/postgres-secret.yaml`
- MySQL: Set in `db/mysql-secret.yaml`
- MongoDB: Set in `db/mongodb-secret.yaml`

## Resource Limits Summary

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
| Vault | 500m | 512Mi | 1 | 2Gi |

## Storage Sizes

| Component | Storage Size |
|-----------|--------------|
| PostgreSQL (per instance) | 20Gi |
| MySQL | 20Gi |
| MongoDB (per instance) | 20Gi |
| Redis | 10Gi |
| Kafka (per broker) | 20Gi |
| Zookeeper (per instance) | 10Gi |
| Prometheus | 50Gi |
| Grafana | 10Gi |
| Loki | 20Gi |
| Tempo | 20Gi |
| Vault | 10Gi |
