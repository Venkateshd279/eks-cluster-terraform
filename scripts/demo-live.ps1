# Manager Demo Automation Script
# Run this during your demo to show live infrastructure

param(
    [string]$Step = "all"
)

Write-Host "🎯 MANAGER DEMO - LIVE INFRASTRUCTURE SHOWCASE" -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

function Show-Step {
    param($StepName, $Description)
    Write-Host ""
    Write-Host "📍 DEMO STEP: $StepName" -ForegroundColor Cyan
    Write-Host "$Description" -ForegroundColor Yellow
    Write-Host "Press Enter to continue..." -ForegroundColor White
    Read-Host
}

function Show-Architecture {
    Show-Step "1. ARCHITECTURE OVERVIEW" "Opening architecture diagram..."
    Start-Process "EKS_Architecture_Diagram.png"
    Write-Host "✅ Architecture diagram opened" -ForegroundColor Green
    Write-Host "💬 Talking points:" -ForegroundColor Cyan
    Write-Host "  • Multi-AZ deployment for high availability" -ForegroundColor White
    Write-Host "  • Private app servers for security" -ForegroundColor White
    Write-Host "  • Load balancer for customer access" -ForegroundColor White
    Write-Host "  • Jenkins for automated CI/CD" -ForegroundColor White
}

function Show-InfrastructureCode {
    Show-Step "2. INFRASTRUCTURE CODE" "Opening VS Code to show modular Terraform code..."
    Start-Process "code" -ArgumentList "."
    Write-Host "✅ VS Code opened with project" -ForegroundColor Green
    Write-Host "💬 Talking points:" -ForegroundColor Cyan
    Write-Host "  • Infrastructure as Code ensures consistency" -ForegroundColor White
    Write-Host "  • Modular design for reusability" -ForegroundColor White
    Write-Host "  • Version controlled infrastructure" -ForegroundColor White
}

function Show-LiveInfrastructure {
    Show-Step "3. LIVE INFRASTRUCTURE STATUS" "Checking live AWS infrastructure..."
    
    Write-Host "🔍 EKS Cluster Information:" -ForegroundColor Yellow
    aws eks describe-cluster --name my-eks-cluster --region ap-south-1 --query "cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}" --output table
    
    Write-Host ""
    Write-Host "🔍 EKS Worker Nodes:" -ForegroundColor Yellow
    kubectl get nodes -o wide
    
    Write-Host ""
    Write-Host "🔍 Running Applications:" -ForegroundColor Yellow
    kubectl get pods --all-namespaces
    
    Write-Host ""
    Write-Host "💬 Talking points:" -ForegroundColor Cyan
    Write-Host "  • Cluster is live and healthy in AWS" -ForegroundColor White
    Write-Host "  • Multiple worker nodes for redundancy" -ForegroundColor White
    Write-Host "  • Applications deployed and running" -ForegroundColor White
}

function Show-CustomerAccess {
    Show-Step "4. CUSTOMER ACCESS DEMO" "Demonstrating customer-facing application..."
    
    Write-Host "🔍 Getting customer URL..." -ForegroundColor Yellow
    $customerUrl = aws elbv2 describe-load-balancers --region ap-south-1 --query "LoadBalancers[?contains(LoadBalancerName, 'web-alb')].DNSName" --output text
    
    if ($customerUrl) {
        Write-Host "🌐 Customer URL: http://$customerUrl" -ForegroundColor Green
        Write-Host "🚀 Opening customer application..." -ForegroundColor Yellow
        Start-Process "http://$customerUrl"
        
        Write-Host ""
        Write-Host "💬 Talking points:" -ForegroundColor Cyan
        Write-Host "  • This is what customers see" -ForegroundColor White
        Write-Host "  • Load balancer distributes traffic" -ForegroundColor White
        Write-Host "  • Backend servers are completely secure" -ForegroundColor White
    } else {
        Write-Host "❌ Customer URL not available" -ForegroundColor Red
    }
}

function Show-CICD {
    Show-Step "5. CI/CD PIPELINE DEMO" "Demonstrating Jenkins automation..."
    
    Write-Host "🔍 Getting Jenkins URL..." -ForegroundColor Yellow
    $jenkinsIp = aws ec2 describe-instances --region ap-south-1 --filters "Name=tag:Name,Values=*jenkins*" "Name=instance-state-name,Values=running" --query "Reservations[].Instances[].PublicIpAddress" --output text
    
    if ($jenkinsIp) {
        Write-Host "🛠️  Jenkins URL: http://${jenkinsIp}:8080" -ForegroundColor Green
        Write-Host "🚀 Opening Jenkins dashboard..." -ForegroundColor Yellow
        Start-Process "http://${jenkinsIp}:8080"
        
        Write-Host ""
        Write-Host "💬 Talking points:" -ForegroundColor Cyan
        Write-Host "  • Automated deployments reduce errors" -ForegroundColor White
        Write-Host "  • Complete audit trail" -ForegroundColor White
        Write-Host "  • Integrates with any Git repository" -ForegroundColor White
        Write-Host "  • Supports rollbacks and blue/green deployments" -ForegroundColor White
    } else {
        Write-Host "❌ Jenkins not available" -ForegroundColor Red
    }
}

function Show-Monitoring {
    Show-Step "6. MONITORING & MANAGEMENT" "Demonstrating operational capabilities..."
    
    Write-Host "📊 Application Logs:" -ForegroundColor Yellow
    kubectl logs -l app=sample-web-app -n sample-apps --tail=10 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  (No sample app logs available)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "📊 Resource Usage:" -ForegroundColor Yellow
    kubectl top nodes 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  (Metrics server not available)" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "📊 Service Health:" -ForegroundColor Yellow
    kubectl get services --all-namespaces
    
    Write-Host ""
    Write-Host "💬 Talking points:" -ForegroundColor Cyan
    Write-Host "  • Real-time monitoring and logging" -ForegroundColor White
    Write-Host "  • Resource utilization tracking" -ForegroundColor White
    Write-Host "  • Health checks and automated recovery" -ForegroundColor White
}

function Show-Summary {
    Write-Host ""
    Write-Host "🎉 DEMO COMPLETE!" -ForegroundColor Green
    Write-Host "=================" -ForegroundColor Green
    Write-Host ""
    Write-Host "📋 What we demonstrated:" -ForegroundColor Cyan
    Write-Host "  ✅ Production-ready AWS EKS cluster" -ForegroundColor White
    Write-Host "  ✅ Automated CI/CD pipeline with Jenkins" -ForegroundColor White
    Write-Host "  ✅ High availability and load balancing" -ForegroundColor White
    Write-Host "  ✅ Security best practices" -ForegroundColor White
    Write-Host "  ✅ Infrastructure as Code" -ForegroundColor White
    Write-Host "  ✅ Live monitoring and management" -ForegroundColor White
    Write-Host ""
    Write-Host "💼 Business value delivered:" -ForegroundColor Cyan
    Write-Host "  💰 Cost optimization through automation" -ForegroundColor White
    Write-Host "  🚀 Faster deployments (minutes vs hours)" -ForegroundColor White
    Write-Host "  🔒 Enterprise-grade security" -ForegroundColor White
    Write-Host "  📈 Scalable for business growth" -ForegroundColor White
    Write-Host "  🛡️  High availability (99.9% uptime potential)" -ForegroundColor White
}

# Execute demo steps
switch ($Step.ToLower()) {
    "all" {
        Show-Architecture
        Show-InfrastructureCode
        Show-LiveInfrastructure
        Show-CustomerAccess
        Show-CICD
        Show-Monitoring
        Show-Summary
    }
    "architecture" { Show-Architecture }
    "code" { Show-InfrastructureCode }
    "infrastructure" { Show-LiveInfrastructure }
    "customer" { Show-CustomerAccess }
    "cicd" { Show-CICD }
    "monitoring" { Show-Monitoring }
    "summary" { Show-Summary }
    default {
        Write-Host "Usage: .\demo-live.ps1 [-Step <step>]" -ForegroundColor Yellow
        Write-Host "Steps: all, architecture, code, infrastructure, customer, cicd, monitoring, summary" -ForegroundColor White
    }
}
