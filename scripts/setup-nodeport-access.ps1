# Quick External Access using NodePort
# This provides immediate external access without installing Load Balancer Controller

Write-Host "🚀 Setting up Quick External Access via NodePort" -ForegroundColor Green

# Create NodePort service
Write-Host "📋 Creating NodePort service..." -ForegroundColor Cyan
kubectl apply -f k8s-apps/sample-web-app/service-nodeport.yaml

# Get worker node external IPs
Write-Host "📋 Getting worker node external IPs..." -ForegroundColor Cyan
$nodeIPs = kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

if (-not $nodeIPs) {
    Write-Host "Getting public IPs from AWS..." -ForegroundColor Yellow
    $instanceIds = kubectl get nodes -o jsonpath='{.items[*].spec.providerID}' | ForEach-Object { $_.Split('/')[-1] }
    
    foreach ($instanceId in $instanceIds) {
        $publicIP = aws ec2 describe-instances --instance-ids $instanceId --query 'Reservations[0].Instances[0].PublicIpAddress' --output text
        if ($publicIP -and $publicIP -ne "None") {
            Write-Host "🌐 Application accessible at: http://${publicIP}:30080" -ForegroundColor Green
        }
    }
} else {
    foreach ($ip in $nodeIPs.Split(' ')) {
        Write-Host "🌐 Application accessible at: http://${ip}:30080" -ForegroundColor Green
    }
}

Write-Host "`n📋 Service Status:" -ForegroundColor Cyan
kubectl get service sample-web-app-nodeport -n sample-apps

Write-Host "`n✅ NodePort setup completed!" -ForegroundColor Green
Write-Host "Note: You may need to update security group to allow port 30080" -ForegroundColor Yellow
