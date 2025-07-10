#!/bin/bash
# Deployment script for Sample Web Application on EKS

echo "🚀 Deploying Sample Web Application to EKS Cluster"
echo "=================================================="

# Check if kubectl is available and connected
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Check cluster connection
echo "🔍 Checking EKS cluster connection..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to EKS cluster. Please configure kubectl:"
    echo "   aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster"
    exit 1
fi

echo "✅ Connected to EKS cluster"

# Get current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "📦 Creating namespace..."
kubectl apply -f "$SCRIPT_DIR/namespace.yaml"

echo ""
echo "🗺️  Applying ConfigMap..."
kubectl apply -f "$SCRIPT_DIR/configmap.yaml"

echo ""
echo "🚢 Deploying application..."
kubectl apply -f "$SCRIPT_DIR/deployment.yaml"

echo ""
echo "🌐 Creating service..."
kubectl apply -f "$SCRIPT_DIR/service.yaml"

echo ""
echo "🔗 Creating ingress (requires AWS Load Balancer Controller)..."
kubectl apply -f "$SCRIPT_DIR/ingress.yaml"

echo ""
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/sample-web-app -n sample-apps

echo ""
echo "📊 Deployment Status:"
echo "==================="
kubectl get namespace sample-apps
echo ""
kubectl get pods -n sample-apps -o wide
echo ""
kubectl get service -n sample-apps
echo ""
kubectl get ingress -n sample-apps

echo ""
echo "🎉 Sample Web Application deployed successfully!"
echo ""
echo "📋 Useful commands:"
echo "  • View pods:     kubectl get pods -n sample-apps"
echo "  • View service:  kubectl get svc -n sample-apps"
echo "  • View ingress:  kubectl get ingress -n sample-apps"
echo "  • View logs:     kubectl logs -l app=sample-web-app -n sample-apps"
echo "  • Delete app:    kubectl delete namespace sample-apps"
echo ""

# Get ingress URL if available
echo "🌍 Checking for Load Balancer URL..."
INGRESS_URL=$(kubectl get ingress sample-web-app-ingress -n sample-apps -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
if [ ! -z "$INGRESS_URL" ]; then
    echo "🔗 Application URL: http://$INGRESS_URL"
else
    echo "⏳ Load Balancer URL not ready yet. Check again in a few minutes:"
    echo "   kubectl get ingress -n sample-apps"
fi

echo ""
echo "✅ Deployment complete!"
