#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if kubectl is installed
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    print_info "kubectl is installed"
}

# Function to check cluster connectivity
check_cluster() {
    if ! kubectl cluster-info &> /dev/null; then
        print_error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi
    print_info "Connected to Kubernetes cluster"
}

# Function to create namespaces
create_namespaces() {
    print_info "Creating namespaces..."
    kubectl apply -f myapp/namespaces.yaml
    
    print_info "Labeling namespaces for NetworkPolicies..."
    kubectl label namespace db name=db --overwrite
    kubectl label namespace cache name=cache --overwrite
    kubectl label namespace queue name=queue --overwrite
    kubectl label namespace observability name=observability --overwrite
    kubectl label namespace vault name=vault --overwrite
    kubectl label namespace myapp name=myapp --overwrite
    kubectl label namespace kube-system name=kube-system --overwrite
}

# Function to deploy database stack
deploy_db() {
    print_info "Deploying Database stack..."
    
    # PostgreSQL
    print_info "  - PostgreSQL (Primary + Replicas)"
    kubectl apply -f db/postgres-configmap.yaml
    kubectl apply -f db/postgres-secret.yaml
    kubectl apply -f db/postgres-primary-statefulset.yaml
    kubectl apply -f db/postgres-replica-statefulset.yaml
    
    # MySQL
    print_info "  - MySQL"
    kubectl apply -f db/mysql-configmap.yaml
    kubectl apply -f db/mysql-secret.yaml
    kubectl apply -f db/mysql-deployment.yaml
    
    # MongoDB
    print_info "  - MongoDB (Write + Read replicas)"
    kubectl apply -f db/mongodb-configmap.yaml
    kubectl apply -f db/mongodb-secret.yaml
    kubectl apply -f db/mongodb-write-deployment.yaml
    kubectl apply -f db/mongodb-read-deployment.yaml
    
    # H2
    print_info "  - H2 (Development only)"
    kubectl apply -f db/h2-deployment.yaml
    
    # Network Policy
    print_info "  - Network Policy"
    kubectl apply -f db/networkpolicy.yaml
    
    print_info "Database stack deployed"
}

# Function to deploy cache stack
deploy_cache() {
    print_info "Deploying Cache stack (Redis)..."
    
    # Standalone Redis
    print_info "  - Redis Standalone"
    kubectl apply -f cache/redis-standalone-configmap.yaml
    kubectl apply -f cache/redis-standalone-deployment.yaml
    
    # Redis Cluster
    print_info "  - Redis Cluster (6 nodes)"
    kubectl apply -f cache/redis-cluster-configmap.yaml
    kubectl apply -f cache/redis-cluster-statefulset.yaml
    
    # Redis Sentinel
    print_info "  - Redis Sentinel"
    kubectl apply -f cache/redis-sentinel-configmap.yaml
    kubectl apply -f cache/redis-sentinel-statefulset.yaml
    
    # Network Policy
    print_info "  - Network Policy"
    kubectl apply -f cache/networkpolicy.yaml
    
    print_info "Cache stack deployed"
}

# Function to deploy queue stack
deploy_queue() {
    print_info "Deploying Queue stack (Kafka)..."
    
    # Zookeeper
    print_info "  - Zookeeper (3 nodes)"
    kubectl apply -f queue/zookeeper-statefulset.yaml
    
    # Wait for Zookeeper to be ready
    print_info "  - Waiting for Zookeeper to be ready..."
    kubectl wait --for=condition=ready pod -l app=zookeeper -n queue --timeout=300s || true
    
    # Kafka
    print_info "  - Kafka (3 brokers)"
    kubectl apply -f queue/kafka-configmap.yaml
    kubectl apply -f queue/kafka-statefulset.yaml
    
    # Kafdrop
    print_info "  - Kafdrop (Kafka UI)"
    kubectl apply -f queue/kafdrop-deployment.yaml
    
    # Network Policy
    print_info "  - Network Policy"
    kubectl apply -f queue/networkpolicy.yaml
    
    print_info "Queue stack deployed"
}

# Function to deploy observability stack
deploy_observability() {
    print_info "Deploying Observability stack..."
    
    # Prometheus
    print_info "  - Prometheus"
    kubectl apply -f observability/prometheus-configmap.yaml
    kubectl apply -f observability/prometheus-deployment.yaml
    
    # Grafana
    print_info "  - Grafana"
    kubectl apply -f observability/grafana-secrets.yaml
    kubectl apply -f observability/grafana-deployment.yaml
    
    # Loki
    print_info "  - Loki"
    kubectl apply -f observability/loki-configmap.yaml
    kubectl apply -f observability/loki-deployment.yaml
    
    # Fluent-bit
    print_info "  - Fluent-bit (Log collector)"
    kubectl apply -f observability/fluent-bit-configmap.yaml
    kubectl apply -f observability/fluent-bit-deployment.yaml
    
    # Tempo
    print_info "  - Tempo (Distributed tracing)"
    kubectl apply -f observability/tempo-deployment.yaml
    
    # ServiceMonitors (if Prometheus Operator is installed)
    if kubectl get crd servicemonitors.monitoring.coreos.com &> /dev/null; then
        print_info "  - ServiceMonitors"
        kubectl apply -f observability/servicemonitors.yaml
    else
        print_warn "  - Prometheus Operator not found, skipping ServiceMonitors"
    fi
    
    # Network Policy
    print_info "  - Network Policy"
    kubectl apply -f observability/networkpolicy.yaml
    
    print_info "Observability stack deployed"
}

# Function to deploy vault
deploy_vault() {
    print_info "Deploying Vault..."
    kubectl apply -f vault/vault-secrets.yaml
    kubectl apply -f vault/vault-configmap.yaml
    kubectl apply -f vault/vault-deployment.yaml
    kubectl apply -f vault/networkpolicy.yaml
    print_info "Vault deployed"
}

# Function to deploy application
deploy_app() {
    print_info "Deploying Application..."
    kubectl apply -f myapp/enterprise-app.yaml
    print_info "Application deployed"
}

# Function to show status
show_status() {
    print_info "Deployment Status:"
    echo ""
    print_info "Pods:"
    kubectl get pods -A
    echo ""
    print_info "Services:"
    kubectl get svc -A
    echo ""
    print_info "PVCs:"
    kubectl get pvc -A
}

# Main deployment function
main() {
    print_info "Starting Kubernetes Infrastructure Deployment"
    echo ""
    
    # Check prerequisites
    check_kubectl
    check_cluster
    echo ""
    
    # Parse arguments
    DEPLOY_ALL=false
    DEPLOY_DB=false
    DEPLOY_CACHE=false
    DEPLOY_QUEUE=false
    DEPLOY_OBSERVABILITY=false
    DEPLOY_VAULT=false
    DEPLOY_APP=false
    
    if [ $# -eq 0 ]; then
        DEPLOY_ALL=true
    else
        for arg in "$@"; do
            case $arg in
                --all)
                    DEPLOY_ALL=true
                    ;;
                --db)
                    DEPLOY_DB=true
                    ;;
                --cache)
                    DEPLOY_CACHE=true
                    ;;
                --queue)
                    DEPLOY_QUEUE=true
                    ;;
                --observability)
                    DEPLOY_OBSERVABILITY=true
                    ;;
                --vault)
                    DEPLOY_VAULT=true
                    ;;
                --app)
                    DEPLOY_APP=true
                    ;;
                --help)
                    echo "Usage: $0 [OPTIONS]"
                    echo ""
                    echo "Options:"
                    echo "  --all              Deploy all components (default)"
                    echo "  --db               Deploy database stack only"
                    echo "  --cache            Deploy cache stack only"
                    echo "  --queue            Deploy queue stack only"
                    echo "  --observability    Deploy observability stack only"
                    echo "  --vault            Deploy vault only"
                    echo "  --app              Deploy application only"
                    echo "  --help             Show this help message"
                    echo ""
                    echo "Examples:"
                    echo "  $0                 # Deploy everything"
                    echo "  $0 --db --cache    # Deploy only database and cache"
                    echo "  $0 --observability # Deploy only observability stack"
                    exit 0
                    ;;
                *)
                    print_error "Unknown option: $arg"
                    echo "Use --help for usage information"
                    exit 1
                    ;;
            esac
        done
    fi
    
    # Create namespaces first
    create_namespaces
    echo ""
    
    # Deploy components
    if [ "$DEPLOY_ALL" = true ]; then
        deploy_db
        echo ""
        deploy_cache
        echo ""
        deploy_queue
        echo ""
        deploy_observability
        echo ""
        deploy_vault
        echo ""
        print_warn "Skipping application deployment. Use --app to deploy the application."
    else
        [ "$DEPLOY_DB" = true ] && deploy_db && echo ""
        [ "$DEPLOY_CACHE" = true ] && deploy_cache && echo ""
        [ "$DEPLOY_QUEUE" = true ] && deploy_queue && echo ""
        [ "$DEPLOY_OBSERVABILITY" = true ] && deploy_observability && echo ""
        [ "$DEPLOY_VAULT" = true ] && deploy_vault && echo ""
        [ "$DEPLOY_APP" = true ] && deploy_app && echo ""
    fi
    
    # Show status
    echo ""
    show_status
    echo ""
    
    print_info "Deployment completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Wait for all pods to be ready: kubectl get pods -A -w"
    echo "  2. Check service endpoints: kubectl get svc -A"
    echo "  3. Access Grafana: kubectl port-forward -n observability svc/grafana 3000:3000"
    echo "  4. Access Prometheus: kubectl port-forward -n observability svc/prometheus 9090:9090"
    echo "  5. Access Kafdrop: kubectl port-forward -n queue svc/kafdrop 9000:9000"
    echo "  6. Access Vault: kubectl port-forward -n vault svc/vault 8200:8200"
}

# Run main function
main "$@"
