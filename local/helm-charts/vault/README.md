# Vault Helm Chart

Production-ready HashiCorp Vault Helm chart for secrets management.

## Features

- ✅ StatefulSet deployment
- ✅ File storage backend
- ✅ UI enabled
- ✅ Telemetry for Prometheus
- ✅ NetworkPolicy for security
- ✅ PodDisruptionBudget for HA
- ✅ Configurable resources and storage

## Installation

```bash
# Development
helm install vault ./vault -n vault \
  --create-namespace \
  --values values/values-dev.yaml

# Production
helm install vault ./vault -n vault \
  --create-namespace \
  --values values/values-production.yaml
```

## Initialize Vault

```bash
# Initialize (first time only)
kubectl exec -n vault vault-0 -- vault operator init

# Save the unseal keys and root token!

# Unseal Vault (repeat with 3 different keys)
kubectl exec -n vault vault-0 -- vault operator unseal <key1>
kubectl exec -n vault vault-0 -- vault operator unseal <key2>
kubectl exec -n vault vault-0 -- vault operator unseal <key3>

# Login
kubectl exec -n vault vault-0 -- vault login <root-token>
```

## Usage

```bash
# Access Vault UI
kubectl port-forward -n vault svc/vault 8200:8200
# Open http://localhost:8200

# Store secret
kubectl exec -n vault vault-0 -- vault kv put secret/myapp password=secret123

# Read secret
kubectl exec -n vault vault-0 -- vault kv get secret/myapp

# Enable database secrets engine
kubectl exec -n vault vault-0 -- vault secrets enable database
```

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of Vault instances | `1` |
| `image.tag` | Vault image tag | `1.15.6` |
| `persistence.size` | Storage size | `10Gi` |
| `config.tlsDisable` | Disable TLS | `true` |
| `config.telemetry.enabled` | Enable Prometheus metrics | `true` |

## Monitoring

```bash
# Access metrics
kubectl port-forward -n vault vault-0 8200:8200
curl http://localhost:8200/v1/sys/metrics?format=prometheus
```

## High Availability

For HA setup, use Consul or integrated storage backend:

```yaml
replicaCount: 3

config:
  storage: "raft"
```

## Security

**IMPORTANT**: 
- Store unseal keys securely
- Rotate root token after initialization
- Enable TLS in production
- Use auto-unseal with cloud KMS

## License

MIT License
