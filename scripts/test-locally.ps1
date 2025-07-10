# Test EKS Application Locally using VS Code
# This script sets up port forwarding and opens the application in VS Code

Write-Host "🚀 Testing EKS Application Locally in VS Code" -ForegroundColor Green

# Check if kubectl is configured
Write-Host "Checking kubectl configuration..." -ForegroundColor Yellow
try {
    $clusterInfo = kubectl cluster-info 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ kubectl is configured and connected to EKS" -ForegroundColor Green
    } else {
        Write-Host "✗ kubectl not configured. Run: aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ kubectl not found. Please install kubectl first." -ForegroundColor Red
    exit 1
}

# Check if the application is deployed
Write-Host "Checking application deployment..." -ForegroundColor Yellow
$podStatus = kubectl get pods -n sample-apps -l app=sample-web-app 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Application pods found:" -ForegroundColor Green
    kubectl get pods -n sample-apps -l app=sample-web-app
} else {
    Write-Host "✗ Application not deployed. Run the Jenkins pipeline first." -ForegroundColor Red
    exit 1
}

# Start port forwarding
Write-Host "`nStarting port forwarding..." -ForegroundColor Yellow
Write-Host "This will forward local port 8080 to the application service" -ForegroundColor Cyan

# Kill any existing port-forward on port 8080
try {
    $existingProcess = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
    if ($existingProcess) {
        Write-Host "Stopping existing process on port 8080..." -ForegroundColor Yellow
        Stop-Process -Id $existingProcess.OwningProcess -Force
        Start-Sleep -Seconds 2
    }
} catch {
    # Ignore errors
}

Write-Host "Starting port forward..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop port forwarding" -ForegroundColor Yellow

# Start port forwarding in background
$job = Start-Job -ScriptBlock {
    kubectl port-forward service/sample-web-app-service 8080:80 -n sample-apps
}

# Wait a moment for port forwarding to start
Start-Sleep -Seconds 3

# Check if port forwarding is working
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5 -UseBasicParsing
    Write-Host "✓ Application is accessible at http://localhost:8080" -ForegroundColor Green
    
    # Open in VS Code Simple Browser
    Write-Host "Opening application in VS Code Simple Browser..." -ForegroundColor Cyan
    code --command vscode.open "http://localhost:8080"
    
} catch {
    Write-Host "✗ Application not accessible. Port forwarding may have failed." -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== Local Testing Commands ===" -ForegroundColor Cyan
Write-Host "Application URL: http://localhost:8080" -ForegroundColor White
Write-Host "Stop port forwarding: Ctrl+C or close this window" -ForegroundColor White
Write-Host "Check pods: kubectl get pods -n sample-apps" -ForegroundColor White
Write-Host "Check logs: kubectl logs -l app=sample-web-app -n sample-apps" -ForegroundColor White
Write-Host "Check service: kubectl get service sample-web-app-service -n sample-apps" -ForegroundColor White

# Keep the script running
Write-Host "`nPort forwarding is running. Press any key to stop..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Clean up
Write-Host "Stopping port forwarding..." -ForegroundColor Yellow
Stop-Job -Job $job
Remove-Job -Job $job
Write-Host "Port forwarding stopped." -ForegroundColor Green
