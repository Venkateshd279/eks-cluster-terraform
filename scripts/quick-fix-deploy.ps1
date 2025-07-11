# Quick Fix and Redeploy Script
# This script fixes the nginx PID issue and redeploys

param(
    [string]$JenkinsServerIP = "13.204.60.118",
    [string]$KeyFile = "python.pem"
)

Write-Host "🔧 Quick Fix and Redeploy for nginx PID Issue" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Step 1: Copy fixed nginx.conf to Jenkins server
Write-Host "`n1. Copying fixed nginx.conf to Jenkins server..." -ForegroundColor Yellow
$WORKSPACE_DIR = "/var/lib/jenkins/workspace/eks-ci-cd-pipeline/k8s-apps/sample-web-app"

scp -i $KeyFile "k8s-apps/sample-web-app/nginx.conf" ubuntu@$JenkinsServerIP`:$WORKSPACE_DIR/

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ nginx.conf copied successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to copy nginx.conf" -ForegroundColor Red
    exit 1
}

# Step 2: Rebuild and push image on Jenkins server
Write-Host "`n2. Rebuilding image on Jenkins server..." -ForegroundColor Yellow
$buildCommands = @"
cd $WORKSPACE_DIR

# Build new image with incremented tag
docker build -t sample-web-app:fixed-1 .
docker tag sample-web-app:fixed-1 897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app:fixed-1
docker tag sample-web-app:fixed-1 897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app:latest

# Login and push to ECR
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 897722681721.dkr.ecr.ap-south-1.amazonaws.com
docker push 897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app:fixed-1
docker push 897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app:latest

echo "✅ Image rebuilt and pushed with nginx PID fix"
"@

ssh -i $KeyFile ubuntu@$JenkinsServerIP $buildCommands

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Image rebuilt and pushed successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Image rebuild failed" -ForegroundColor Red
    exit 1
}

# Step 3: Restart deployment to pull new image
Write-Host "`n3. Restarting deployment to pull new image..." -ForegroundColor Yellow
kubectl rollout restart deployment/sample-web-app -n sample-apps

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Deployment restarted" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to restart deployment" -ForegroundColor Red
    exit 1
}

# Step 4: Wait for rollout to complete
Write-Host "`n4. Waiting for rollout to complete..." -ForegroundColor Yellow
kubectl rollout status deployment/sample-web-app -n sample-apps --timeout=300s

# Step 5: Check pod status
Write-Host "`n5. Checking pod status..." -ForegroundColor Yellow
kubectl get pods -n sample-apps -l app=sample-web-app

# Step 6: Test the application
Write-Host "`n6. Getting application URL..." -ForegroundColor Yellow
$ingressAddress = kubectl get ingress sample-web-app-ingress -n sample-apps -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null

if ($ingressAddress) {
    Write-Host "🌐 Application URL: http://$ingressAddress" -ForegroundColor Green
    Write-Host "📋 You can test it with: curl -I http://$ingressAddress" -ForegroundColor Gray
} else {
    Write-Host "⏳ LoadBalancer URL not ready yet" -ForegroundColor Yellow
    Write-Host "📋 Check later with: kubectl get ingress -n sample-apps" -ForegroundColor Gray
}

Write-Host "`n🎉 Quick fix deployment completed!" -ForegroundColor Green
