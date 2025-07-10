#!/bin/bash
# Quick test script for EKS application

echo "🧪 Quick EKS Application Test"

# Check if kubectl is configured
echo "Checking kubectl configuration..."
if kubectl cluster-info &> /dev/null; then
    echo "✅ kubectl configured and connected to EKS"
else
    echo "❌ kubectl not configured. Run: aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster"
    exit 1
fi

# Check application status
echo "📊 Application Status:"
kubectl get pods -n sample-apps -l app=sample-web-app
kubectl get service sample-web-app-service -n sample-apps

# Test connectivity
echo "🔗 Testing connectivity..."
kubectl run test-pod --image=curlimages/curl:latest --rm -i --restart=Never -n sample-apps -- \
curl -s http://sample-web-app-service.sample-apps.svc.cluster.local

echo "✅ Test completed!"
