# Demo Preparation Script - Run Before Manager Demo
# This script verifies all components are ready for the demo

Write-Host "🎯 DEMO PREPARATION - MANAGER PRESENTATION" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""

$ErrorCount = 0

# Function to check and report status
function Test-Component {
    param($Name, $Test, $SuccessMessage, $FailMessage)
    Write-Host "🔍 Checking $Name..." -ForegroundColor Yellow
    try {
        if ($Test) {
            Write-Host "  ✅ $SuccessMessage" -ForegroundColor Green
            return $true
        } else {
            Write-Host "  ❌ $FailMessage" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "  ❌ $FailMessage - Error: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

Write-Host "📋 PRE-DEMO CHECKLIST" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host ""

# 1. Check AWS CLI
if (-not (Test-Component "AWS CLI" {
    aws sts get-caller-identity | Out-Null
    $LASTEXITCODE -eq 0
} "AWS CLI configured and working" "AWS CLI not configured or not working")) {
    $ErrorCount++
}

# 2. Check kubectl
if (-not (Test-Component "kubectl" {
    kubectl version --client | Out-Null
    $LASTEXITCODE -eq 0
} "kubectl installed and working" "kubectl not installed or not working")) {
    $ErrorCount++
}

# 3. Check EKS cluster connection
if (-not (Test-Component "EKS Cluster Connection" {
    kubectl cluster-info | Out-Null
    $LASTEXITCODE -eq 0
} "Connected to EKS cluster" "Cannot connect to EKS cluster")) {
    $ErrorCount++
    Write-Host "  💡 Fix: aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster" -ForegroundColor Yellow
}

# 4. Check EKS nodes
if (-not (Test-Component "EKS Nodes" {
    $nodes = kubectl get nodes --no-headers 2>$null
    $nodes -and $nodes.Count -gt 0
} "EKS nodes are running" "No EKS nodes found")) {
    $ErrorCount++
}

# 5. Check ALB (customer endpoint)
Write-Host "🔍 Checking Application Load Balancer..." -ForegroundColor Yellow
try {
    $albDns = aws elbv2 describe-load-balancers --region ap-south-1 --query "LoadBalancers[?contains(LoadBalancerName, 'web-alb')].DNSName" --output text 2>$null
    if ($albDns) {
        Write-Host "  ✅ ALB URL: http://$albDns" -ForegroundColor Green
        Write-Host "  📝 Customer Demo URL Ready!" -ForegroundColor Cyan
    } else {
        Write-Host "  ❌ Application Load Balancer not found" -ForegroundColor Red
        $ErrorCount++
    }
} catch {
    Write-Host "  ❌ Cannot retrieve ALB information" -ForegroundColor Red
    $ErrorCount++
}

# 6. Check Jenkins server
Write-Host "🔍 Checking Jenkins Server..." -ForegroundColor Yellow
try {
    $jenkinsIp = aws ec2 describe-instances --region ap-south-1 --filters "Name=tag:Name,Values=*jenkins*" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].PublicIpAddress" --output text 2>$null
    if ($jenkinsIp) {
        Write-Host "  ✅ Jenkins URL: http://${jenkinsIp}:8080" -ForegroundColor Green
        Write-Host "  📝 CI/CD Demo URL Ready!" -ForegroundColor Cyan
    } else {
        Write-Host "  ❌ Jenkins server not found or not running" -ForegroundColor Red
        $ErrorCount++
    }
} catch {
    Write-Host "  ❌ Cannot retrieve Jenkins information" -ForegroundColor Red
    $ErrorCount++
}

# 7. Check architecture diagram
if (-not (Test-Component "Architecture Diagram" {
    Test-Path "EKS_Architecture_Diagram.png"
} "Architecture diagram ready for presentation" "Architecture diagram not found")) {
    $ErrorCount++
}

# 8. Check sample application
Write-Host "🔍 Checking Sample Application..." -ForegroundColor Yellow
try {
    $pods = kubectl get pods -n sample-apps --no-headers 2>$null
    if ($pods) {
        Write-Host "  ✅ Sample application deployed and running" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Sample application not deployed (Optional for demo)" -ForegroundColor Yellow
        Write-Host "  💡 Deploy with: .\k8s-apps\sample-web-app\deploy.ps1" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  Sample application status unknown" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📊 DEMO READINESS SUMMARY" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

if ($ErrorCount -eq 0) {
    Write-Host "🎉 ALL SYSTEMS READY FOR DEMO!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 Demo Assets:" -ForegroundColor Cyan
    Write-Host "  • Architecture Diagram: EKS_Architecture_Diagram.png" -ForegroundColor White
    Write-Host "  • Customer URL: $albDns" -ForegroundColor White
    Write-Host "  • Jenkins URL: http://${jenkinsIp}:8080" -ForegroundColor White
    Write-Host "  • Demo Guide: DEMO_GUIDE_FOR_MANAGER.md" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 You're ready to impress your manager!" -ForegroundColor Green
} else {
    Write-Host "❌ $ErrorCount ISSUES FOUND - Fix before demo" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Quick fixes:" -ForegroundColor Yellow
    Write-Host "  • Ensure AWS CLI is configured: aws configure" -ForegroundColor White
    Write-Host "  • Connect to EKS: aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster" -ForegroundColor White
    Write-Host "  • Check infrastructure: terraform plan" -ForegroundColor White
}

Write-Host ""
Write-Host "📖 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Review DEMO_GUIDE_FOR_MANAGER.md" -ForegroundColor White
Write-Host "  2. Practice the demo script" -ForegroundColor White
Write-Host "  3. Open architecture diagram for presentation" -ForegroundColor White
Write-Host "  4. Prepare for Q&A using the guide" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Good luck with your demo!" -ForegroundColor Green
