# helm-app

Production-grade, multi-environment Helm chart for enterprise applications.

## Structure
- `Chart.yaml`: Helm chart definition
- `values-dev.yaml`: Dev environment values
- `values-sit.yaml`: SIT environment values
- `values-uat.yaml`: UAT environment values
- `values-preprod.yaml`: Preprod environment values
- `values-production.yaml`: Production environment values
- `templates/`: Kubernetes manifests (ConfigMap, Secret, Deployment, Service, Ingress, etc.)

## Usage

To deploy for a specific environment:

```sh
helm upgrade --install myapp ./helm-app -f helm-app/values-<env>.yaml
```
Replace `<env>` with `dev`, `sit`, `uat`, `preprod`, or `production`.

## CI/CD Integration

See `.github/workflows/helm-deploy.yaml` for a sample GitHub Actions pipeline for automated Helm deployments.

## Advanced Features & Modularity

This chart supports optional production-grade features:
- **PersistentVolumeClaim (PVC):** Enable with `persistence.enabled: true` and set `size`, `storageClass`.
- **HorizontalPodAutoscaler (HPA):** Enable with `hpa.enabled: true` and set `minReplicas`, `maxReplicas`, `targetCPUUtilizationPercentage`.
- **PodDisruptionBudget (PDB):** Enable with `pdb.enabled: true` and set `minAvailable` or `maxUnavailable`.
- **ServiceMonitor:** Enable with `serviceMonitor.enabled: true` for Prometheus Operator integration.
- **PrometheusRule:** Enable with `prometheusRule.enabled: true` and provide alert rules.

All features are disabled by default in values files. Enable and configure as needed per environment.

## Best Practices
- Use environment-specific values files for all deployments.
- Store secrets securely (do not commit real secrets).
- Use HPA and PDB for high availability and resilience in production.
- Use ServiceMonitor and PrometheusRule for observability and alerting.
- Use PVC for stateful workloads. 