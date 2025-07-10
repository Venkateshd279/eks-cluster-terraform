# Update ConfigMap from Index.html - Root Level Script
# This script generates configmap.yaml from index.html and can be run from project root

Write-Host "🔄 UPDATING SAMPLE APP CONFIGMAP" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

$appDir = "k8s-apps\sample-web-app"

# Check if we're in the project root
if (-not (Test-Path $appDir)) {
    Write-Host "❌ Error: $appDir directory not found" -ForegroundColor Red
    Write-Host "Please run this script from the project root directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "📂 App directory: $appDir" -ForegroundColor Cyan
Write-Host ""

# Check if required files exist
$htmlFile = "$appDir\index.html"
$updateScript = "$appDir\update-configmap.ps1"

if (-not (Test-Path $htmlFile)) {
    Write-Host "❌ Error: $htmlFile not found" -ForegroundColor Red
    exit 1
}

Write-Host "📖 Found index.html file" -ForegroundColor Green

# Change to app directory and run the update script
Write-Host "🔄 Changing to app directory and updating ConfigMap..." -ForegroundColor Yellow
try {
    Push-Location $appDir
    
    if (Test-Path "update-configmap.ps1") {
        .\update-configmap.ps1
    } else {
        Write-Host "❌ update-configmap.ps1 not found in app directory" -ForegroundColor Red
        exit 1
    }
    
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "🎯 DEPLOYMENT COMMANDS:" -ForegroundColor Cyan
Write-Host "======================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Apply the updated ConfigMap:" -ForegroundColor Yellow
Write-Host "  kubectl apply -f $appDir\configmap.yaml" -ForegroundColor White
Write-Host ""
Write-Host "Restart the deployment to pick up changes:" -ForegroundColor Yellow
Write-Host "  kubectl rollout restart deployment/sample-web-app -n sample-apps" -ForegroundColor White
Write-Host ""
Write-Host "Check deployment status:" -ForegroundColor Yellow
Write-Host "  kubectl get pods -n sample-apps" -ForegroundColor White
Write-Host ""
Write-Host "View application logs:" -ForegroundColor Yellow
Write-Host "  kubectl logs -l app=sample-web-app -n sample-apps" -ForegroundColor White
Write-Host ""
Write-Host "✅ ConfigMap update complete!" -ForegroundColor Green
