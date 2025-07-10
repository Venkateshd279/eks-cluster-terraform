# Test All Server Endpoints
# This script tests all available endpoints in your infrastructure

Write-Host "🌐 Testing All Server Endpoints" -ForegroundColor Green

# Get outputs from Terraform
Write-Host "`n📋 Getting endpoint information..." -ForegroundColor Cyan
$webALB = terraform output -raw web_alb_dns_name
$webServer1 = terraform output -raw web_server_1_public_ip
$webServer2 = terraform output -raw web_server_2_public_ip
$jenkinsIP = terraform output -raw jenkins_public_ip

Write-Host "Web ALB: $webALB" -ForegroundColor Yellow
Write-Host "Web Server 1: $webServer1" -ForegroundColor Yellow
Write-Host "Web Server 2: $webServer2" -ForegroundColor Yellow
Write-Host "Jenkins: $jenkinsIP" -ForegroundColor Yellow

# Test Web ALB (Load Balancer)
Write-Host "`n🌍 Testing Web Application Load Balancer..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://$webALB" -TimeoutSec 10 -UseBasicParsing
    Write-Host "✅ Web ALB is accessible at: http://$webALB" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode) $($response.StatusDescription)" -ForegroundColor White
} catch {
    Write-Host "❌ Web ALB not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Individual Web Servers
Write-Host "`n🖥️ Testing Individual Web Servers..." -ForegroundColor Cyan

# Web Server 1
try {
    $response = Invoke-WebRequest -Uri "http://$webServer1" -TimeoutSec 10 -UseBasicParsing
    Write-Host "✅ Web Server 1 is accessible at: http://$webServer1" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode) $($response.StatusDescription)" -ForegroundColor White
} catch {
    Write-Host "❌ Web Server 1 not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Web Server 2
try {
    $response = Invoke-WebRequest -Uri "http://$webServer2" -TimeoutSec 10 -UseBasicParsing
    Write-Host "✅ Web Server 2 is accessible at: http://$webServer2" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode) $($response.StatusDescription)" -ForegroundColor White
} catch {
    Write-Host "❌ Web Server 2 not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test Jenkins
Write-Host "`n🔧 Testing Jenkins Server..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://${jenkinsIP}:8080" -TimeoutSec 10 -UseBasicParsing
    Write-Host "✅ Jenkins is accessible at: http://${jenkinsIP}:8080" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode) $($response.StatusDescription)" -ForegroundColor White
} catch {
    Write-Host "❌ Jenkins not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Test EKS Application (if port forward is running)
Write-Host "`n☸️ Testing EKS Application..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 5 -UseBasicParsing
    Write-Host "✅ EKS App is accessible at: http://localhost:8080" -ForegroundColor Green
    Write-Host "   Status: $($response.StatusCode) $($response.StatusDescription)" -ForegroundColor White
} catch {
    Write-Host "⚠️  EKS App not accessible locally. Run port forward:" -ForegroundColor Yellow
    Write-Host "   kubectl port-forward service/sample-web-app-service 8080:80 -n sample-apps" -ForegroundColor White
}

# Summary
Write-Host "`n📊 Endpoint Summary:" -ForegroundColor Cyan
Write-Host "🌐 Main Web Application: http://$webALB" -ForegroundColor Green
Write-Host "🖥️ Web Server 1: http://$webServer1" -ForegroundColor White
Write-Host "🖥️ Web Server 2: http://$webServer2" -ForegroundColor White
Write-Host "🔧 Jenkins CI/CD: http://${jenkinsIP}:8080" -ForegroundColor White
Write-Host "☸️ EKS App: http://localhost:8080 (with port-forward)" -ForegroundColor White

Write-Host "`n🎯 For Public Access, Use:" -ForegroundColor Green
Write-Host "http://$webALB" -ForegroundColor Cyan

Write-Host "`n✅ Endpoint testing completed!" -ForegroundColor Green
