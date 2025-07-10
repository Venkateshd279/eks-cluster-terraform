# PowerShell Deployment script for Sample Web Application on EKS

Write-Host "🚀 Deploying Sample Web Application to EKS Cluster" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green

# Check if kubectl is available
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-Host "❌ kubectl not found. Please install kubectl first." -ForegroundColor Red
    exit 1
}

# Check cluster connection
Write-Host "🔍 Checking EKS cluster connection..." -ForegroundColor Yellow
try {
    kubectl cluster-info | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Connection failed"
    }
} catch {
    Write-Host "❌ Cannot connect to EKS cluster. Please configure kubectl:" -ForegroundColor Red
    Write-Host "   aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Connected to EKS cluster" -ForegroundColor Green

# Get current directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

Write-Host ""
Write-Host "📦 Creating namespace..." -ForegroundColor Cyan
kubectl apply -f "$ScriptDir\namespace.yaml"

Write-Host ""
Write-Host "🗺️  Applying ConfigMap..." -ForegroundColor Cyan
kubectl apply -f "$ScriptDir\configmap.yaml"

Write-Host ""
Write-Host "🚢 Deploying application..." -ForegroundColor Cyan
kubectl apply -f "$ScriptDir\deployment.yaml"

Write-Host ""
Write-Host "🌐 Creating service..." -ForegroundColor Cyan
kubectl apply -f "$ScriptDir\service.yaml"

Write-Host ""
Write-Host "🔗 Creating ingress (requires AWS Load Balancer Controller)..." -ForegroundColor Cyan
kubectl apply -f "$ScriptDir\ingress.yaml"

Write-Host ""
Write-Host "⏳ Waiting for deployment to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available --timeout=300s deployment/sample-web-app -n sample-apps

Write-Host ""
Write-Host "📊 Deployment Status:" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
kubectl get namespace sample-apps
Write-Host ""
kubectl get pods -n sample-apps -o wide
Write-Host ""
kubectl get service -n sample-apps
Write-Host ""
kubectl get ingress -n sample-apps

Write-Host ""
Write-Host "🎉 Sample Web Application deployed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Useful commands:" -ForegroundColor Cyan
Write-Host "  • View pods:     kubectl get pods -n sample-apps" -ForegroundColor White
Write-Host "  • View service:  kubectl get svc -n sample-apps" -ForegroundColor White
Write-Host "  • View ingress:  kubectl get ingress -n sample-apps" -ForegroundColor White
Write-Host "  • View logs:     kubectl logs -l app=sample-web-app -n sample-apps" -ForegroundColor White
Write-Host "  • Delete app:    kubectl delete namespace sample-apps" -ForegroundColor White
Write-Host ""

# Get ingress URL if available
Write-Host "🌍 Checking for Load Balancer URL..." -ForegroundColor Yellow
try {
    $IngressUrl = kubectl get ingress sample-web-app-ingress -n sample-apps -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null
    if ($IngressUrl) {
        Write-Host "🔗 Application URL: http://$IngressUrl" -ForegroundColor Green
    } else {
        Write-Host "⏳ Load Balancer URL not ready yet. Check again in a few minutes:" -ForegroundColor Yellow
        Write-Host "   kubectl get ingress -n sample-apps" -ForegroundColor White
    }
} catch {
    Write-Host "⏳ Load Balancer URL not ready yet." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
