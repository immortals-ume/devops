# Helmfile - Multi-Service Deployment Orchestration

Production-grade Helmfile setup for managing multiple services across different environments.

## Overview

This Helmfile configuration provides:
- ✅ Multi-environment support (dev, sit, uat, preprod, production)
- ✅ Modular structure (init, infrastructure, apps)
- ✅ Dependency management between services
- ✅ Environment-specific configurations
- ✅ Infrastructure and application orchestration

## Structure

```
helmfile/
├── helmfile.yaml                    # Main orchestration file
├── helmfile-init.yaml              # Namespace initialization
├── helmfile-infrastructure.yaml    # Infrastructure services
├── helmfile-apps.yaml              # Application services
├── values/                         # Application values
│   ├── backend-dev.yaml
│   ├── backend-production.yaml
│   ├── frontend-dev.yaml
│   ├── frontend-production.yaml
│   ├── worker-production.yaml
│   └── admin-production.yaml
└── README.md
```

## Prerequisites

```bash
# Install Helmfile
brew install helmfile

# Install Helm
brew install helm

# Install helm-diff plugin (recommended)
helm plugin install https://github.com/databus23/helm-diff
```

## Quick Start

### Deploy Everything

```bash
# Deploy to development
helmfile -e dev apply

# Deploy to production
helmfile -e production apply

# Dry run (see what will be deployed)
helmfile -e production diff
```

### Deploy Specific Components

```bash
# Deploy only infrastructure
helmfile -f helmfile-infrastructure.yaml -e production apply

# Deploy only applications
helmfile -f helmfile-apps.yaml -e production apply

# Deploy specific service
helmfile -e production -l app=backend apply
```

## Environments

### Available Environments

- **dev** - Development environment
- **sit** - System Integration Testing
- **uat** - User Acceptance Testing
- **preprod** - Pre-Production
- **production** - Production environment

### Environment Configuration

Each environment can have different:
- Resource allocations
- Replica counts
- Autoscaling settings
- Monitoring configurations
- Network policies

## Deployment Order

Helmfile automatically manages dependencies:

1. **Init** (helmfile-init.yaml)
   - Creates namespaces
   - Sets up labels

2. **Infrastructure** (helmfile-infrastructure.yaml)
   - PostgreSQL
   - MySQL
   - MongoDB
   - Redis
   - Kafka
   - Observability stack
   - Vault

3. **Applications** (helmfile-apps.yaml)
   - Backend API (depends on postgres, redis)
   - Frontend UI (depends on backend)
   - Worker (depends on postgres, kafka)
   - Admin Panel (depends on backend)

## Usage Examples

### Example 1: Deploy Full Stack to Development

```bash
# Deploy everything
helmfile -e dev apply

# Verify deployment
helmfile -e dev status

# Check specific service
kubectl get pods -n myapp
```

### Example 2: Deploy to Production with Confirmation

```bash
# Show what will change
helmfile -e production diff

# Apply changes interactively
helmfile -e production apply --interactive

# Or apply with confirmation
helmfile -e production apply
```

### Example 3: Update Single Service

```bash
# Update backend only
helmfile -e production -l app=backend apply

# Update with new image tag
helmfile -e production -l app=backend \
  --set image.tag=v1.1.0 apply
```

### Example 4: Rollback

```bash
# List releases
helmfile -e production list

# Rollback specific service
helm rollback backend -n myapp

# Or use helmfile sync to restore to defined state
helmfile -e production sync
```

## Service Configurations

### Backend API

**Development:**
- 1 replica
- Minimal resources (250m CPU, 256Mi RAM)
- Debug logging
- No autoscaling

**Production:**
- 4 replicas
- High resources (1 CPU, 2Gi RAM)
- Info logging
- HPA enabled (4-20 replicas)
- PDB enabled
- ServiceMonitor enabled
- Prometheus alerts

### Frontend UI

**Development:**
- 1 replica
- Minimal resources
- Local ingress

**Production:**
- 3 replicas
- HPA enabled (3-10 replicas)
- TLS enabled
- CDN integration ready

### Worker Service

**Production:**
- 3 replicas
- HPA enabled (3-15 replicas)
- Kafka consumer
- Database access

### Admin Panel

**Production:**
- 2 replicas
- Basic auth enabled
- TLS enabled
- Restricted access

## Advanced Features

### Selective Deployment

```bash
# Deploy only databases
helmfile -f helmfile-infrastructure.yaml \
  -l tier=database apply

# Deploy only web tier
helmfile -f helmfile-apps.yaml \
  -l tier=web apply
```

### Environment Variables

```bash
# Override values
helmfile -e production \
  --set backend.image.tag=v2.0.0 \
  apply

# Use custom values file
helmfile -e production \
  --state-values-file custom-values.yaml \
  apply
```

### Secrets Management

```bash
# Use sealed secrets
helmfile -e production \
  --set secrets.enabled=true \
  apply

# Use external secrets operator
helmfile -e production \
  --set externalSecrets.enabled=true \
  apply
```

## Monitoring Deployment

### Check Status

```bash
# List all releases
helmfile -e production list

# Check status
helmfile -e production status

# Get release info
helm list -A
```

### View Logs

```bash
# Backend logs
kubectl logs -n myapp -l app=backend -f

# All app logs
kubectl logs -n myapp -l tier=api -f
```

### Check Health

```bash
# Check pods
kubectl get pods -n myapp

# Check services
kubectl get svc -n myapp

# Check ingress
kubectl get ingress -n myapp
```

## Troubleshooting

### Common Issues

**1. Dependency not ready**
```bash
# Check if dependencies are running
kubectl get pods -n db
kubectl get pods -n cache

# Wait for dependencies
helmfile -e production apply --wait
```

**2. Values file not found**
```bash
# Verify values files exist
ls -la helmfile/values/

# Use correct environment
helmfile -e production list
```

**3. Helm diff fails**
```bash
# Install helm-diff plugin
helm plugin install https://github.com/databus23/helm-diff

# Update plugin
helm plugin update diff
```

**4. Release conflicts**
```bash
# List existing releases
helm list -A

# Delete conflicting release
helm uninstall <release-name> -n <namespace>

# Reapply
helmfile -e production apply
```

## Best Practices

1. **Always use environments** - Never deploy without specifying environment
2. **Use diff before apply** - Review changes before applying
3. **Test in dev first** - Validate changes in development
4. **Use labels** - Organize services with labels
5. **Manage secrets properly** - Use sealed secrets or external secrets
6. **Version control** - Keep helmfile and values in git
7. **Document changes** - Update README when adding services
8. **Monitor deployments** - Watch pods and logs during deployment
9. **Use dependencies** - Define service dependencies correctly
10. **Backup before major changes** - Export current state

## CI/CD Integration

### GitHub Actions

```yaml
name: Deploy with Helmfile
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install Helmfile
        run: |
          wget https://github.com/roboll/helmfile/releases/download/v0.150.0/helmfile_linux_amd64
          chmod +x helmfile_linux_amd64
          sudo mv helmfile_linux_amd64 /usr/local/bin/helmfile
      
      - name: Deploy
        run: |
          cd helmfile
          helmfile -e production diff
          helmfile -e production apply
```

### GitLab CI

```yaml
deploy:
  stage: deploy
  image: alpine/helm:latest
  before_script:
    - apk add --no-cache curl
    - curl -L https://github.com/roboll/helmfile/releases/download/v0.150.0/helmfile_linux_amd64 -o /usr/local/bin/helmfile
    - chmod +x /usr/local/bin/helmfile
  script:
    - cd helmfile
    - helmfile -e production diff
    - helmfile -e production apply
  only:
    - main
```

## Cleanup

```bash
# Destroy all releases in environment
helmfile -e dev destroy

# Destroy specific service
helmfile -e dev -l app=backend destroy

# Delete namespaces
kubectl delete namespace myapp db cache queue observability vault
```

## Support

For issues or questions:
1. Check helmfile logs: `helmfile -e <env> --debug apply`
2. Verify Helm releases: `helm list -A`
3. Check Kubernetes resources: `kubectl get all -n <namespace>`
4. Review values files for correct configuration

## References

- [Helmfile Documentation](https://github.com/roboll/helmfile)
- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## License

MIT License
