#!/bin/bash

# MathSync Kubernetes Deployment Script
set -euo pipefail

# Configuration
NAMESPACE="mathsync"
IMAGE_NAME="mathsync"
IMAGE_TAG="${1:-latest}"
REGISTRY="${REGISTRY:-your-registry.com}"
FULL_IMAGE="${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if kubectl is available
check_kubectl() {
    if ! command -v kubectl &> /dev/null; then
        print_error "kubectl is not installed or not in PATH"
        exit 1
    fi
    print_success "kubectl is available"
}

# Function to check if kustomize is available
check_kustomize() {
    if ! command -v kustomize &> /dev/null; then
        print_warning "kustomize is not installed, using kubectl kustomize"
        KUSTOMIZE_CMD="kubectl kustomize"
    else
        KUSTOMIZE_CMD="kustomize"
        print_success "kustomize is available"
    fi
}

# Function to build and push Docker image
build_and_push_image() {
    print_status "Building Docker image: ${FULL_IMAGE}"
    
    docker build -t "${FULL_IMAGE}" .
    
    if [ $? -eq 0 ]; then
        print_success "Docker image built successfully"
    else
        print_error "Failed to build Docker image"
        exit 1
    fi
    
    print_status "Pushing Docker image to registry"
    docker push "${FULL_IMAGE}"
    
    if [ $? -eq 0 ]; then
        print_success "Docker image pushed successfully"
    else
        print_error "Failed to push Docker image"
        exit 1
    fi
}

# Function to apply Kubernetes manifests
deploy_to_kubernetes() {
    print_status "Deploying to Kubernetes namespace: ${NAMESPACE}"
    
    # Create namespace if it doesn't exist
    kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -
    
    # Update image tag in kustomization
    cd k8s
    ${KUSTOMIZE_CMD} edit set image mathsync="${FULL_IMAGE}"
    
    # Apply manifests
    ${KUSTOMIZE_CMD} build . | kubectl apply -f -
    
    if [ $? -eq 0 ]; then
        print_success "Deployment applied successfully"
    else
        print_error "Failed to apply deployment"
        exit 1
    fi
    
    cd ..
}

# Function to wait for rollout
wait_for_rollout() {
    print_status "Waiting for deployment rollout to complete"
    
    kubectl rollout status deployment/mathsync-app -n "${NAMESPACE}" --timeout=300s
    
    if [ $? -eq 0 ]; then
        print_success "Deployment rollout completed successfully"
    else
        print_error "Deployment rollout failed or timed out"
        exit 1
    fi
}

# Function to show deployment status
show_status() {
    print_status "Deployment Status:"
    echo
    kubectl get pods,svc,ingress -n "${NAMESPACE}"
    echo
    
    print_status "HPA Status:"
    kubectl get hpa -n "${NAMESPACE}"
    echo
    
    print_status "Recent Events:"
    kubectl get events -n "${NAMESPACE}" --sort-by='.lastTimestamp' | tail -10
}

# Function to run health checks
health_check() {
    print_status "Running health checks"
    
    # Wait for pods to be ready
    kubectl wait --for=condition=ready pod -l app=mathsync -n "${NAMESPACE}" --timeout=300s
    
    # Get service endpoint
    SERVICE_IP=$(kubectl get svc mathsync-service -n "${NAMESPACE}" -o jsonpath='{.spec.clusterIP}')
    
    # Simple health check (if running in cluster)
    if kubectl run health-check --image=curlimages/curl:latest --rm -i --restart=Never -n "${NAMESPACE}" -- curl -f "http://${SERVICE_IP}/health"; then
        print_success "Health check passed"
    else
        print_warning "Health check failed or could not be performed"
    fi
}

# Main deployment function
main() {
    print_status "Starting MathSync deployment"
    
    # Pre-flight checks
    check_kubectl
    check_kustomize
    
    # Build and push image (skip if NO_BUILD is set)
    if [ "${NO_BUILD:-}" != "true" ]; then
        build_and_push_image
    else
        print_warning "Skipping image build (NO_BUILD=true)"
    fi
    
    # Deploy to Kubernetes
    deploy_to_kubernetes
    
    # Wait for rollout
    wait_for_rollout
    
    # Show status
    show_status
    
    # Run health checks
    health_check
    
    print_success "MathSync deployment completed successfully!"
    print_status "Access your application at: https://mathsync.example.com"
}

# Script usage
usage() {
    echo "Usage: $0 [IMAGE_TAG]"
    echo
    echo "Environment variables:"
    echo "  REGISTRY    - Docker registry (default: your-registry.com)"
    echo "  NO_BUILD    - Skip building Docker image (set to 'true')"
    echo
    echo "Examples:"
    echo "  $0                    # Deploy with 'latest' tag"
    echo "  $0 v1.2.3            # Deploy with specific tag"
    echo "  NO_BUILD=true $0     # Deploy without building image"
    echo "  REGISTRY=gcr.io/my-project $0 v1.2.3"
}

# Handle command line arguments
case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac
