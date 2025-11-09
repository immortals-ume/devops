#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

check_helm() {
    if ! command -v helm &> /dev/null; then
        print_error "Helm is not installed. Please install Helm first."
        exit 1
    fi
    print_info "Helm is installed: $(helm version --short)"
}

check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed. Please install kubectl first."
        exit 1
    fi
    print_info "kubectl is installed"
}

deploy_chart() {
    local chart=$1
    local namespace=$2
    local release=$3
    local env=$4
    
    print_info "Deploying $chart ($env) to namespace $namespace..."
    
    local values_file="./helm-charts/$chart/values/values-${env}.yaml"
    
    if [ ! -f "$values_file" ]; then
        print_warn "Values file not found: $values_file, using default values"
        helm upgrade --install $release ./helm-charts/$chart \
            --namespace $namespace \
            --create-namespace \
            --wait \
            --timeout 10m
    else
        helm upgrade --install $release ./helm-charts/$chart \
            --namespace $namespace \
            --create-namespace \
            --values $values_file \
            --wait \
            --timeout 10m
    fi
    
    if [ $? -eq 0 ]; then
        print_info "$chart deployed successfully"
    else
        print_error "Failed to deploy $chart"
        return 1
    fi
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --all              Deploy all charts (default)"
    echo "  --db               Deploy database charts only"
    echo "  --cache            Deploy cache chart only"
    echo "  --queue            Deploy queue chart only"
    echo "  --observability    Deploy observability chart only"
    echo "  --vault            Deploy vault chart only"
    echo "  --env <env>        Environment: dev, sit, uat, preprod, production (default: dev)"
    echo "  --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --all --env production"
    echo "  $0 --db --env sit"
    echo "  $0 --observability --env uat"
}

main() {
    print_header "Helm Charts Deployment"
    echo ""
    
    check_helm
    check_kubectl
    echo ""
    
    # Default values
    DEPLOY_ALL=false
    DEPLOY_DB=false
    DEPLOY_CACHE=false
    DEPLOY_QUEUE=false
    DEPLOY_OBSERVABILITY=false
    DEPLOY_VAULT=false
    ENV="dev"
    
    # Parse arguments
    if [ $# -eq 0 ]; then
        DEPLOY_ALL=true
    else
        while [[ $# -gt 0 ]]; do
            case $1 in
                --all)
                    DEPLOY_ALL=true
                    shift
                    ;;
                --db)
                    DEPLOY_DB=true
                    shift
                    ;;
                --cache)
                    DEPLOY_CACHE=true
                    shift
                    ;;
                --queue)
                    DEPLOY_QUEUE=true
                    shift
                    ;;
                --observability)
                    DEPLOY_OBSERVABILITY=true
                    shift
                    ;;
                --vault)
                    DEPLOY_VAULT=true
                    shift
                    ;;
                --env)
                    ENV="$2"
                    shift 2
                    ;;
                --help)
                    show_usage
                    exit 0
                    ;;
                *)
                    print_error "Unknown option: $1"
                    show_usage
                    exit 1
                    ;;
            esac
        done
    fi
    
    # Validate environment
    if [[ ! "$ENV" =~ ^(dev|sit|uat|preprod|production)$ ]]; then
        print_error "Invalid environment: $ENV"
        print_error "Valid environments: dev, sit, uat, preprod, production"
        exit 1
    fi
    
    print_info "Deploying to environment: $ENV"
    echo ""
    
    # Deploy charts
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_DB" = true ]; then
        print_header "Deploying Database Stack"
        deploy_chart "postgres" "db" "postgres" "$ENV"
        deploy_chart "mysql" "db" "mysql" "$ENV"
        deploy_chart "mongodb" "db" "mongodb" "$ENV"
        echo ""
    fi
    
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_CACHE" = true ]; then
        print_header "Deploying Cache Stack"
        deploy_chart "redis" "cache" "redis" "$ENV"
        echo ""
    fi
    
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_QUEUE" = true ]; then
        print_header "Deploying Queue Stack"
        deploy_chart "kafka" "queue" "kafka" "$ENV"
        echo ""
    fi
    
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_OBSERVABILITY" = true ]; then
        print_header "Deploying Observability Stack"
        deploy_chart "observability" "observability" "observability" "$ENV"
        echo ""
    fi
    
    if [ "$DEPLOY_ALL" = true ] || [ "$DEPLOY_VAULT" = true ]; then
        print_header "Deploying Vault"
        deploy_chart "vault" "vault" "vault" "$ENV"
        echo ""
    fi
    
    print_header "Deployment Summary"
    echo ""
    print_info "Environment: $ENV"
    print_info "Deployed releases:"
    helm list -A
    echo ""
    print_info "Pod status:"
    kubectl get pods -A
    echo ""
    
    print_info "Deployment completed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Check pod status: kubectl get pods -A -w"
    echo "  2. Check services: kubectl get svc -A"
    echo "  3. Access Grafana: kubectl port-forward -n observability svc/grafana 3000:3000"
    echo "  4. Access Prometheus: kubectl port-forward -n observability svc/prometheus 9090:9090"
}

main "$@"
