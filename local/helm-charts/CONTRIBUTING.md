# Contributing to Helm Charts

## Chart Development Guidelines

### Structure

Each chart should follow this structure:

```
chart-name/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── templates/          # Kubernetes manifests
│   ├── _helpers.tpl    # Template helpers
│   ├── serviceaccount.yaml
│   ├── secret.yaml
│   ├── configmap.yaml
│   ├── statefulset.yaml or deployment.yaml
│   ├── service.yaml
│   ├── pdb.yaml
│   ├── networkpolicy.yaml
│   └── servicemonitor.yaml
└── README.md           # Chart documentation
```

### Best Practices

1. **Use semantic versioning** for chart versions
2. **Include all labels** using helpers
3. **Make everything configurable** via values.yaml
4. **Add resource limits** by default
5. **Include security contexts** for all pods
6. **Add probes** (liveness and readiness)
7. **Support monitoring** (ServiceMonitor)
8. **Add NetworkPolicy** for security
9. **Include PodDisruptionBudget** for HA
10. **Document all values** in README

### Testing

```bash
# Lint chart
helm lint helm-charts/chart-name

# Template rendering
helm template test helm-charts/chart-name

# Dry run
helm install test helm-charts/chart-name --dry-run --debug

# Install in test namespace
helm install test helm-charts/chart-name -n test --create-namespace

# Verify
kubectl get all -n test

# Cleanup
helm uninstall test -n test
kubectl delete namespace test
```

### Adding a New Chart

1. Create chart directory structure
2. Add Chart.yaml with metadata
3. Create values.yaml with defaults
4. Add templates with proper labels
5. Create _helpers.tpl for common functions
6. Add README.md with usage examples
7. Test thoroughly
8. Update main README.md

### Versioning

- **Patch** (1.0.X): Bug fixes, no breaking changes
- **Minor** (1.X.0): New features, backward compatible
- **Major** (X.0.0): Breaking changes

### Pull Request Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test your changes
5. Update documentation
6. Submit pull request
7. Address review comments

### Code Review Checklist

- [ ] Chart follows structure guidelines
- [ ] All values are documented
- [ ] Templates use helpers for labels
- [ ] Security contexts are configured
- [ ] Resource limits are set
- [ ] Probes are configured
- [ ] NetworkPolicy is included
- [ ] PodDisruptionBudget is included
- [ ] ServiceMonitor is included (if applicable)
- [ ] README is complete
- [ ] Chart lints successfully
- [ ] Chart installs successfully
- [ ] All tests pass

## Questions?

Open an issue or contact the maintainers.
