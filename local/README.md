# Local Infrastructure - Phase 1

All local development and generic Kubernetes infrastructure.

## Structure

```
local/
├── docker-compose/     # Docker Compose for local development
├── kubernetes/         # Kubernetes manifests (works with any K8s)
├── helm-charts/        # Infrastructure Helm charts (7 charts)
├── helm-app/           # Application Helm chart
└── helmfile/           # Multi-service orchestration
```

## Quick Start

### 1. Docker Compose (Local Development)

```bash
cd local/docker-compose
make up-all
```

### 2. Kubernetes Deployment

```bash
cd local/kubernetes
./deploy.sh --all
```

### 3. Helm Charts

```bash
cd local/helm-charts
./deploy-all.sh --all --env dev
```

### 4. Helmfile

```bash
cd local/helmfile
helmfile -e dev apply
```

## Documentation

- [Docker Compose Setup](docker-compose/README.md)
- [Kubernetes Guide](kubernetes/README.md)
- [Helm Charts Guide](helm-charts/README.md)
- [Helmfile Guide](helmfile/README.md)

## Target Environments

- Local development (Docker Desktop, Minikube, Kind, K3s)
- On-premise Kubernetes
- Generic Kubernetes clusters
- Any K8s cluster (no cloud-specific dependencies)
