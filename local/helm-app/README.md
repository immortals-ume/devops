# Helm App - Production-Ready Application Chart

Comprehensive Helm chart for deploying enterprise applications with best practices.

## Features

- ✅ Multi-environment support (dev, sit, uat, preprod, production)
- ✅ Security hardening (non-root, read-only filesystem, security contexts)
- ✅ High availability (HPA, PDB, pod anti-affinity)
- ✅ Observability (ServiceMonitor, PrometheusRule, health probes)
- ✅ Network security (NetworkPolicy)
- ✅ Flexible configuration (ConfigMap, Secrets, env vars)
- ✅ Persistence (PVC support)
- ✅ Jobs & CronJobs (migrations, backups)
- ✅ Init containers & Sidecars
- ✅ Ingress with TLS

## Quick Start

```bash
# Install with default values
helm install myapp ./helm-app -n myapp --create-namespace

# Install for production
helm install myapp ./helm-app -n myapp \
  --create-namespace \
  -f helm-app/values-production.yaml

# Upgrade
helm upgrade myapp ./helm-app -n myapp \
  --set image.tag=v1.1.0
```

## Configuration

### Key Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `nginx` |
| `image.tag` | Image tag | `1.25-alpine` |
| `service.port` | Service port | `80` |
| `autoscaling.enabled` | Enable HPA | `false` |
| `persistence.enabled` | Enable PVC | `false` |
| `serviceMonitor.enabled` | Enable monitoring | `false` |

See `values.yaml` for all available options.

## Examples

### Web Application
```yaml
replicaCount: 3
image:
  repository: myapp
  tag: v1.0.0
ingress:
  enabled: true
  hosts:
    - host: app.example.com
autoscaling:
  enabled: true
  minReplicas: 3
  maxReplicas: 10
```

### API with Database
```yaml
secrets:
  enabled: true
  data:
    dbPassword: changeme
initContainers:
  - name: wait-for-db
    image: busybox
    command: ['sh', '-c', 'until nc -z db 5432; do sleep 2; done']
```

### Scheduled Jobs
```yaml
cronJobs:
  enabled: true
  list:
    - name: backup
      schedule: "0 2 * * *"
      image: backup-tool:latest
      command: ["backup.sh"]
```

## Best Practices

1. Use specific image tags (not `latest`)
2. Set resource limits
3. Enable health probes
4. Use secrets for sensitive data
5. Enable HPA for production
6. Use PDB for availability
7. Enable monitoring
8. Use NetworkPolicy
9. Run as non-root
10. Use read-only filesystem

## Troubleshooting

```bash
# Check pods
kubectl get pods -n myapp

# View logs
kubectl logs -n myapp <pod-name>

# Check HPA
kubectl get hpa -n myapp

# Test service
kubectl run -it --rm debug --image=busybox --restart=Never -- \
  wget -O- http://myapp.myapp.svc.cluster.local
```

## License

MIT License
