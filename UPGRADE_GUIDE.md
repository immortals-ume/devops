# Upgrade Guide

Complete guide for upgrading infrastructure components in Kubernetes and Helm.

## Table of Contents

1. [Pre-Upgrade Checklist](#pre-upgrade-checklist)
2. [Helm Chart Upgrades](#helm-chart-upgrades)
3. [Kubernetes Manifest Upgrades](#kubernetes-manifest-upgrades)
4. [Database Upgrades](#database-upgrades)
5. [Rollback Procedures](#rollback-procedures)
6. [Troubleshooting](#troubleshooting)

## Pre-Upgrade Checklist

### 1. Backup Everything

```bash
# Backup PostgreSQL
kubectl exec -n db postgres-primary-0 -- pg_dumpall -U postgres > postgres-backup-$(date +%Y%m%d).sql

# Backup MySQL
kubectl exec -n db mysql-0 -- mysqldump -u root -p --all-databases > mysql-backup-$(date +%Y%m%d).sql

# Backup MongoDB
kubectl exec -n db mongodb-write-0 -- mongodump --out=/tmp/backup
kubectl cp db/mongodb-write-0:/tmp/backup ./mongodb-backup-$(date +%Y%m%d)

# Backup Redis (if using persistence)
kubectl exec -n cache redis-standalone-0 -- redis-cli BGSAVE
```

### 2. Check Current State

```bash
# List all Helm releases
helm list -A

# Check pod status
kubectl get pods -A

# Check resource usage
kubectl top nodes
kubectl top pods -A

# Check PVC status
kubectl get pvc -A
```

### 3. Review Release Notes

- Check changelog for breaking changes
- Review new features and deprecations
- Verify compatibility with your Kubernetes version

### 4. Test in Non-Production First

Always test upgrades in this order:
1. Development
2. SIT
3. UAT
4. Pre-Production
5. Production

## Helm Chart Upgrades

### Upgrade Single Chart

```bash
# Upgrade with same values
helm upgrade redis ./helm-charts/redis -n cache

# Upgrade with new values
helm upgrade redis ./helm-charts/redis -n cache \
  --values ./helm-charts/redis/values/values-production.yaml

# Upgrade with specific version
helm upgrade redis ./helm-charts/redis -n cache \
  --version 1.1.0

# Dry run first
helm upgrade redis ./helm-charts/redis -n cache \
  --dry-run --debug
```

### Upgrade All Charts

```bash
# Using deploy script
cd helm-charts
./deploy-all.sh --all --env production

# Or manually
helm upgrade postgres ./helm-charts/postgres -n db
helm upgrade mysql ./helm-charts/mysql -n db
helm upgrade mongodb ./helm-charts/mongodb -n db
helm upgrade redis ./helm-charts/redis -n cache
helm upgrade kafka ./helm-charts/kafka -n queue
helm upgrade observability ./helm-charts/observability -n observability
helm upgrade vault ./helm-charts/vault -n vault
```

### Upgrade with Zero Downtime

```bash
# For StatefulSets (databases)
helm upgrade postgres ./helm-charts/postgres -n db \
  --set updateStrategy.type=RollingUpdate \
  --wait

# For Deployments
helm upgrade redis ./helm-charts/redis -n cache \
  --set strategy.type=RollingUpdate \
  --set strategy.rollingUpdate.maxUnavailable=0 \
  --wait
```

### Monitor Upgrade Progress

```bash
# Watch pods during upgrade
kubectl get pods -n cache -w

# Check rollout status
kubectl rollout status statefulset/redis-cluster -n cache

# View events
kubectl get events -n cache --sort-by='.lastTimestamp'
```

## Kubernetes Manifest Upgrades

### Upgrade K8s Resources

```bash
# Apply updated manifests
kubectl apply -f k8s/db/postgres-primary-statefulset.yaml
kubectl apply -f k8s/cache/redis-standalone-deployment.yaml

# Or use deploy script
cd k8s
./deploy.sh --db --cache
```

### Rolling Update for StatefulSets

```bash
# Update StatefulSet
kubectl apply -f k8s/db/postgres-primary-statefulset.yaml

# Watch rollout
kubectl rollout status statefulset/postgres-primary -n db

# Pause rollout if issues
kubectl rollout pause statefulset/postgres-primary -n db

# Resume rollout
kubectl rollout resume statefulset/postgres-primary -n db
```

### Update ConfigMaps and Secrets

```bash
# Update ConfigMap
kubectl apply -f k8s/db/postgres-configmap.yaml

# Restart pods to pick up changes
kubectl rollout restart statefulset/postgres-primary -n db

# Or delete pods one by one
kubectl delete pod postgres-primary-0 -n db
# Wait for pod to be ready before deleting next
```

## Database Upgrades

### PostgreSQL Version Upgrade

```bash
# 1. Backup database
kubectl exec -n db postgres-primary-0 -- pg_dumpall -U postgres > backup.sql

# 2. Update image version in values
# Edit: helm-charts/postgres/values/values-production.yaml
# Change: image.tag: "16.2" to "17.0"

# 3. Upgrade with Helm
helm upgrade postgres ./helm-charts/postgres -n db \
  --values ./helm-charts/postgres/values/values-production.yaml

# 4. Verify version
kubectl exec -n db postgres-primary-0 -- psql -U postgres -c "SELECT version();"
```

### MySQL Version Upgrade

```bash
# 1. Backup database
kubectl exec -n db mysql-0 -- mysqldump -u root -p --all-databases > backup.sql

# 2. Update image version
# Edit values file: image.tag: "8.4" to "9.0"

# 3. Upgrade
helm upgrade mysql ./helm-charts/mysql -n db \
  --values ./helm-charts/mysql/values/values-production.yaml

# 4. Run mysql_upgrade if needed
kubectl exec -n db mysql-0 -- mysql_upgrade -u root -p
```

### MongoDB Version Upgrade

```bash
# 1. Backup database
kubectl exec -n db mongodb-write-0 -- mongodump --out=/tmp/backup

# 2. Upgrade one minor version at a time
# 7.0 -> 7.1 -> 7.2 (never skip versions)

# 3. Update image version
# Edit values file: image.tag: "7.0" to "7.1"

# 4. Upgrade
helm upgrade mongodb ./helm-charts/mongodb -n db \
  --values ./helm-charts/mongodb/values/values-production.yaml

# 5. Verify version
kubectl exec -n db mongodb-write-0 -- mongosh --eval "db.version()"
```

### Redis Upgrade

```bash
# 1. Backup data (if using persistence)
kubectl exec -n cache redis-standalone-0 -- redis-cli BGSAVE

# 2. Update image version
# Edit values file: image.tag: "7.2" to "7.4"

# 3. Upgrade
helm upgrade redis ./helm-charts/redis -n cache \
  --values ./helm-charts/redis/values/values-production.yaml

# 4. Verify version
kubectl exec -n cache redis-standalone-0 -- redis-cli INFO server | grep redis_version
```

## Rollback Procedures

### Helm Rollback

```bash
# View release history
helm history redis -n cache

# Rollback to previous version
helm rollback redis -n cache

# Rollback to specific revision
helm rollback redis 3 -n cache

# Rollback with wait
helm rollback redis -n cache --wait --timeout 10m
```

### Kubernetes Rollback

```bash
# Rollback StatefulSet
kubectl rollout undo statefulset/postgres-primary -n db

# Rollback to specific revision
kubectl rollout undo statefulset/postgres-primary -n db --to-revision=2

# View rollout history
kubectl rollout history statefulset/postgres-primary -n db
```

### Database Restore from Backup

#### PostgreSQL Restore

```bash
# 1. Stop application connections
kubectl scale deployment myapp -n myapp --replicas=0

# 2. Drop and recreate database
kubectl exec -n db postgres-primary-0 -- psql -U postgres -c "DROP DATABASE myapp;"
kubectl exec -n db postgres-primary-0 -- psql -U postgres -c "CREATE DATABASE myapp;"

# 3. Restore from backup
kubectl cp backup.sql db/postgres-primary-0:/tmp/backup.sql
kubectl exec -n db postgres-primary-0 -- psql -U postgres < /tmp/backup.sql

# 4. Restart application
kubectl scale deployment myapp -n myapp --replicas=3
```

#### MySQL Restore

```bash
# 1. Stop application
kubectl scale deployment myapp -n myapp --replicas=0

# 2. Restore from backup
kubectl cp backup.sql db/mysql-0:/tmp/backup.sql
kubectl exec -n db mysql-0 -- mysql -u root -p < /tmp/backup.sql

# 3. Restart application
kubectl scale deployment myapp -n myapp --replicas=3
```

#### MongoDB Restore

```bash
# 1. Stop application
kubectl scale deployment myapp -n myapp --replicas=0

# 2. Restore from backup
kubectl cp mongodb-backup db/mongodb-write-0:/tmp/backup
kubectl exec -n db mongodb-write-0 -- mongorestore /tmp/backup

# 3. Restart application
kubectl scale deployment myapp -n myapp --replicas=3
```

## Troubleshooting

### Upgrade Stuck

```bash
# Check pod status
kubectl get pods -n cache

# Describe pod for issues
kubectl describe pod redis-cluster-0 -n cache

# Check events
kubectl get events -n cache --sort-by='.lastTimestamp'

# View logs
kubectl logs redis-cluster-0 -n cache

# Force delete stuck pod
kubectl delete pod redis-cluster-0 -n cache --force --grace-period=0
```

### Image Pull Errors

```bash
# Check image pull status
kubectl describe pod redis-cluster-0 -n cache | grep -A 10 Events

# Verify image exists
docker pull redis:7.2-alpine

# Check image pull secrets
kubectl get secrets -n cache
```

### PVC Issues

```bash
# Check PVC status
kubectl get pvc -n cache

# Describe PVC
kubectl describe pvc redis-cluster-data-redis-cluster-0 -n cache

# Check StorageClass
kubectl get storageclass

# Check PV
kubectl get pv
```

### Resource Constraints

```bash
# Check node resources
kubectl top nodes

# Check pod resources
kubectl top pods -n cache

# Describe node
kubectl describe node <node-name>

# Check resource quotas
kubectl get resourcequota -n cache
```

### Configuration Issues

```bash
# Check ConfigMap
kubectl get configmap redis-standalone-config -n cache -o yaml

# Check Secret
kubectl get secret redis-secret -n cache -o yaml

# Verify environment variables
kubectl exec -n cache redis-standalone-0 -- env
```

## Best Practices

### 1. Always Backup First
Never upgrade without a recent backup.

### 2. Test in Non-Production
Always test upgrades in dev/staging first.

### 3. Read Release Notes
Check for breaking changes and new features.

### 4. Use Dry Run
Always do a dry run before actual upgrade.

```bash
helm upgrade redis ./helm-charts/redis -n cache --dry-run --debug
```

### 5. Monitor During Upgrade
Watch pods and logs during the upgrade process.

### 6. Have Rollback Plan
Know how to rollback before starting upgrade.

### 7. Upgrade During Maintenance Window
Schedule upgrades during low-traffic periods.

### 8. Upgrade One Component at a Time
Don't upgrade everything at once.

### 9. Document Everything
Keep notes of what was upgraded and when.

### 10. Verify After Upgrade
Test functionality after upgrade completes.

## Upgrade Schedule

### Recommended Schedule

- **Minor Updates**: Monthly
- **Security Patches**: As soon as available
- **Major Versions**: Quarterly (after thorough testing)

### Maintenance Windows

- **Development**: Anytime
- **SIT/UAT**: During business hours
- **Pre-Production**: Off-peak hours
- **Production**: Scheduled maintenance windows only

## Post-Upgrade Verification

```bash
# 1. Check all pods are running
kubectl get pods -A

# 2. Verify services
kubectl get svc -A

# 3. Test database connections
kubectl run -it --rm psql-test --image=postgres:16.2-alpine --restart=Never -- \
  psql -h postgres-primary.db.svc.cluster.local -U postgres -c "SELECT 1;"

# 4. Check metrics
kubectl port-forward -n observability svc/prometheus 9090:9090
# Visit: http://localhost:9090/targets

# 5. Check logs for errors
kubectl logs -n cache -l app=redis-standalone --tail=100

# 6. Run application tests
# (Your application-specific tests)
```

## Support

For issues during upgrades:
1. Check this guide
2. Review pod logs and events
3. Consult Helm/Kubernetes documentation
4. Contact your DevOps team
5. Open an issue in the repository

## Version History

- **v1.0.0** (2024-11-09): Initial upgrade guide
