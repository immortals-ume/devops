#!/bin/bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    print_header "Checking Prerequisites"
    
    # Check kubectl
    if command -v kubectl &> /dev/null; then
        print_success "kubectl is installed: $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    else
        print_error "kubectl is not installed"
    fi
    
    # Check helm
    if command -v helm &> /dev/null; then
        print_success "Helm is installed: $(helm version --short)"
    else
        print_warning "Helm is not installed (optional for k8s manifests)"
    fi
    
    # Check cluster connectivity
    if kubectl cluster-info &> /dev/null; then
        print_success "Connected to Kubernetes cluster"
    else
        print_error "Cannot connect to Kubernetes cluster"
    fi
    
    echo ""
}

# Validate Helm charts
validate_helm_charts() {
    print_header "Validating Helm Charts"
    
    CHARTS=("postgres" "mysql" "mongodb" "redis" "kafka" "observability" "vault")
    
    for chart in "${CHARTS[@]}"; do
        print_info "Validating $chart chart..."
        
        # Check Chart.yaml exists
        if [ -f "helm-charts/$chart/Chart.yaml" ]; then
            print_success "  Chart.yaml exists"
        else
            print_error "  Chart.yaml missing"
        fi
        
        # Check values.yaml exists
        if [ -f "helm-charts/$chart/values.yaml" ]; then
            print_success "  values.yaml exists"
        else
            print_error "  values.yaml missing"
        fi
        
        # Check templates directory
        if [ -d "helm-charts/$chart/templates" ]; then
            template_count=$(find "helm-charts/$chart/templates" -name "*.yaml" -o -name "*.tpl" | wc -l)
            if [ "$template_count" -gt 0 ]; then
                print_success "  Templates directory has $template_count files"
            else
                print_error "  Templates directory is empty"
            fi
        else
            print_error "  Templates directory missing"
        fi
        
        # Check environment values files
        for env in dev sit uat preprod production; do
            if [ -f "helm-charts/$chart/values/values-$env.yaml" ]; then
                print_success "  values-$env.yaml exists"
            else
                print_warning "  values-$env.yaml missing"
            fi
        done
        
        # Lint chart
        if command -v helm &> /dev/null; then
            if helm lint "helm-charts/$chart" &> /dev/null; then
                print_success "  Chart passes lint"
            else
                print_error "  Chart fails lint"
            fi
        fi
        
        echo ""
    done
}

# Validate K8s manifests
validate_k8s_manifests() {
    print_header "Validating Kubernetes Manifests"
    
    STACKS=("db" "cache" "queue" "observability" "vault" "myapp")
    
    for stack in "${STACKS[@]}"; do
        if [ -d "k8s/$stack" ]; then
            print_info "Validating $stack stack..."
            
            manifest_count=$(find "k8s/$stack" -name "*.yaml" | wc -l)
            if [ "$manifest_count" -gt 0 ]; then
                print_success "  Found $manifest_count manifest files"
                
                # Validate YAML syntax
                for file in k8s/$stack/*.yaml; do
                    if kubectl apply --dry-run=client -f "$file" &> /dev/null; then
                        print_success "  $(basename $file) is valid"
                    else
                        print_error "  $(basename $file) has errors"
                    fi
                done
            else
                print_warning "  No manifest files found"
            fi
        else
            print_warning "  $stack directory not found"
        fi
        echo ""
    done
}

# Check deployed resources
check_deployed_resources() {
    print_header "Checking Deployed Resources"
    
    if ! kubectl cluster-info &> /dev/null; then
        print_warning "Skipping deployed resources check (no cluster connection)"
        return
    fi
    
    # Check namespaces
    print_info "Checking namespaces..."
    NAMESPACES=("db" "cache" "queue" "observability" "vault" "myapp")
    for ns in "${NAMESPACES[@]}"; do
        if kubectl get namespace "$ns" &> /dev/null; then
            print_success "  Namespace $ns exists"
        else
            print_warning "  Namespace $ns not found"
        fi
    done
    echo ""
    
    # Check pods
    print_info "Checking pods..."
    total_pods=$(kubectl get pods -A --no-headers 2>/dev/null | wc -l)
    running_pods=$(kubectl get pods -A --no-headers 2>/dev/null | grep Running | wc -l)
    print_info "  Total pods: $total_pods"
    print_info "  Running pods: $running_pods"
    
    if [ "$total_pods" -gt 0 ]; then
        not_running=$((total_pods - running_pods))
        if [ "$not_running" -gt 0 ]; then
            print_warning "  $not_running pods not running"
        else
            print_success "  All pods are running"
        fi
    fi
    echo ""
    
    # Check PVCs
    print_info "Checking PVCs..."
    total_pvcs=$(kubectl get pvc -A --no-headers 2>/dev/null | wc -l)
    bound_pvcs=$(kubectl get pvc -A --no-headers 2>/dev/null | grep Bound | wc -l)
    print_info "  Total PVCs: $total_pvcs"
    print_info "  Bound PVCs: $bound_pvcs"
    
    if [ "$total_pvcs" -gt 0 ]; then
        not_bound=$((total_pvcs - bound_pvcs))
        if [ "$not_bound" -gt 0 ]; then
            print_error "  $not_bound PVCs not bound"
        else
            print_success "  All PVCs are bound"
        fi
    fi
    echo ""
    
    # Check Helm releases
    if command -v helm &> /dev/null; then
        print_info "Checking Helm releases..."
        release_count=$(helm list -A --no-headers 2>/dev/null | wc -l)
        deployed_count=$(helm list -A --no-headers 2>/dev/null | grep deployed | wc -l)
        print_info "  Total releases: $release_count"
        print_info "  Deployed releases: $deployed_count"
        
        if [ "$release_count" -gt 0 ]; then
            if [ "$release_count" -eq "$deployed_count" ]; then
                print_success "  All releases are deployed"
            else
                print_warning "  Some releases are not in deployed state"
            fi
        fi
    fi
    echo ""
}

# Check documentation
check_documentation() {
    print_header "Checking Documentation"
    
    DOCS=("README.md" "SETUP.md" "UPGRADE_GUIDE.md" "helm-charts/README.md" "k8s/README.md")
    
    for doc in "${DOCS[@]}"; do
        if [ -f "$doc" ]; then
            print_success "$doc exists"
        else
            print_warning "$doc missing"
        fi
    done
    echo ""
}

# Check scripts
check_scripts() {
    print_header "Checking Scripts"
    
    SCRIPTS=("k8s/deploy.sh" "helm-charts/deploy-all.sh")
    
    for script in "${SCRIPTS[@]}"; do
        if [ -f "$script" ]; then
            if [ -x "$script" ]; then
                print_success "$script exists and is executable"
            else
                print_warning "$script exists but is not executable"
            fi
        else
            print_error "$script missing"
        fi
    done
    echo ""
}

# Summary
print_summary() {
    print_header "Validation Summary"
    
    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        print_success "All checks passed! ✨"
    elif [ $ERRORS -eq 0 ]; then
        print_warning "Validation completed with $WARNINGS warnings"
    else
        print_error "Validation failed with $ERRORS errors and $WARNINGS warnings"
    fi
    
    echo ""
    echo "Errors: $ERRORS"
    echo "Warnings: $WARNINGS"
    echo ""
    
    if [ $ERRORS -gt 0 ]; then
        exit 1
    fi
}

# Main
main() {
    echo ""
    print_header "Infrastructure Setup Validation"
    echo ""
    
    check_prerequisites
    validate_helm_charts
    validate_k8s_manifests
    check_deployed_resources
    check_documentation
    check_scripts
    print_summary
}

main "$@"
