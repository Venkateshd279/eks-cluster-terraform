# EKS Demo Automation Script
# Run this script to execute demo steps automatically

param(
    [Parameter(Mandatory=$false)]
    [string]$DemoMode = "full",  # Options: quick, full, infrastructure
    
    [Parameter(Mandatory=$false)]
    [string]$CustomMessage = "LIVE DEMO UPDATE!"
)

Write-Host "🚀 EKS CI/CD Pipeline Demo Script" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Function to pause for user input
function Wait-ForUser {
    param([string]$Message = "Press Enter to continue...")
    Write-Host $Message -ForegroundColor Yellow
    Read-Host
}

# Function to run command with explanation
function Demo-Command {
    param(
        [string]$Command,
        [string]$Explanation,
        [bool]$WaitForUser = $true
    )
    
    Write-Host "📝 $Explanation" -ForegroundColor Green
    Write-Host "💻 Command: $Command" -ForegroundColor White
    
    if ($WaitForUser) {
        Wait-ForUser "Press Enter to execute..."
    }
    
    Invoke-Expression $Command
    Write-Host ""
}

# Check prerequisites
function Test-Prerequisites {
    Write-Host "🔍 Checking prerequisites..." -ForegroundColor Cyan
    
    # Check kubectl
    try {
        kubectl version --client --short | Out-Null
        Write-Host "✅ kubectl is available" -ForegroundColor Green
    } catch {
        Write-Host "❌ kubectl not found. Please install kubectl first." -ForegroundColor Red
        exit 1
    }
    
    # Check cluster connection
    try {
        kubectl cluster-info --request-timeout=10s | Out-Null
        Write-Host "✅ Connected to Kubernetes cluster" -ForegroundColor Green
    } catch {
        Write-Host "❌ Cannot connect to Kubernetes cluster. Check your kubeconfig." -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
}

# Infrastructure Demo
function Demo-Infrastructure {
    Write-Host "🏗️  PART 1: INFRASTRUCTURE OVERVIEW" -ForegroundColor Magenta
    Write-Host "====================================" -ForegroundColor Magenta
    
    Demo-Command "kubectl cluster-info" "Show cluster information"
    Demo-Command "kubectl get nodes -o wide" "Show worker nodes across availability zones"
    Demo-Command "kubectl get pods -n kube-system" "Show system components"
    Demo-Command "kubectl get namespace" "Show namespaces including our application"
}

# Application Demo
function Demo-Application {
    Write-Host "📱 PART 2: APPLICATION OVERVIEW" -ForegroundColor Magenta
    Write-Host "===============================" -ForegroundColor Magenta
    
    Demo-Command "kubectl get all -n sample-apps" "Show all application resources"
    Demo-Command "kubectl get configmap web-app-content -n sample-apps" "Show the ConfigMap containing our HTML"
    Demo-Command "kubectl get ingress -n sample-apps" "Show the ingress (load balancer configuration)"
    
    Write-Host "🌐 Open your browser to: http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com" -ForegroundColor Cyan
    Wait-ForUser "Verify the application is loading, then press Enter..."
}

# Live Update Demo
function Demo-LiveUpdate {
    Write-Host "⚡ PART 3: LIVE UPDATE DEMONSTRATION" -ForegroundColor Magenta
    Write-Host "====================================" -ForegroundColor Magenta
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    Write-Host "📝 Now we'll update the application content live..." -ForegroundColor Green
    Write-Host "   We'll add: '$CustomMessage' with timestamp: $timestamp" -ForegroundColor White
    
    # Create backup
    Copy-Item "k8s-apps\sample-web-app\configmap.yaml" "k8s-apps\sample-web-app\configmap.yaml.backup"
    
    # Update ConfigMap
    $configMapContent = Get-Content "k8s-apps\sample-web-app\configmap.yaml" -Raw
    $updatedContent = $configMapContent -replace "This K8s CICD pipeline DEMO", "This K8s CICD pipeline - $CustomMessage"
    $updatedContent = $updatedContent -replace "Running on Kubernetes", "🚀 Running on Kubernetes - Updated at $timestamp"
    
    $updatedContent | Set-Content "k8s-apps\sample-web-app\configmap.yaml"
    
    Demo-Command "kubectl apply -f k8s-apps\sample-web-app\configmap.yaml" "Apply the updated ConfigMap"
    Demo-Command "kubectl rollout restart deployment/sample-web-app -n sample-apps" "Trigger rolling restart to pick up new content"
    
    Write-Host "⏱️  Watching the rolling update..." -ForegroundColor Yellow
    kubectl get pods -n sample-apps -w --timeout=60s
    
    Write-Host ""
    Write-Host "🎉 Update complete! Refresh your browser to see the changes." -ForegroundColor Green
    Wait-ForUser "Press Enter after verifying the updated content..."
}

# Rollback Demo
function Demo-Rollback {
    Write-Host "🔄 BONUS: ROLLBACK DEMONSTRATION" -ForegroundColor Magenta
    Write-Host "================================" -ForegroundColor Magenta
    
    Demo-Command "kubectl rollout history deployment/sample-web-app -n sample-apps" "Show deployment history"
    Demo-Command "kubectl rollout undo deployment/sample-web-app -n sample-apps" "Rollback to previous version"
    
    Write-Host "⏱️  Watching the rollback..." -ForegroundColor Yellow
    kubectl get pods -n sample-apps -w --timeout=60s
    
    Write-Host ""
    Write-Host "🎉 Rollback complete! The application is back to the original state." -ForegroundColor Green
}

# Cleanup
function Reset-Demo {
    Write-Host "🧹 Resetting demo to original state..." -ForegroundColor Cyan
    
    if (Test-Path "k8s-apps\sample-web-app\configmap.yaml.backup") {
        Copy-Item "k8s-apps\sample-web-app\configmap.yaml.backup" "k8s-apps\sample-web-app\configmap.yaml"
        kubectl apply -f k8s-apps\sample-web-app\configmap.yaml
        kubectl rollout restart deployment/sample-web-app -n sample-apps
        Remove-Item "k8s-apps\sample-web-app\configmap.yaml.backup"
        Write-Host "✅ Demo reset to original state" -ForegroundColor Green
    }
}

# Main demo execution
try {
    Test-Prerequisites
    
    switch ($DemoMode.ToLower()) {
        "quick" {
            Demo-Application
            Demo-LiveUpdate
        }
        "infrastructure" {
            Demo-Infrastructure
            Demo-Application
        }
        "full" {
            Demo-Infrastructure
            Demo-Application
            Demo-LiveUpdate
            
            $rollback = Read-Host "Would you like to demonstrate rollback? (y/n)"
            if ($rollback -eq 'y' -or $rollback -eq 'Y') {
                Demo-Rollback
            }
        }
        default {
            Write-Host "Invalid demo mode. Use: quick, infrastructure, or full" -ForegroundColor Red
            exit 1
        }
    }
    
    Write-Host ""
    Write-Host "🎉 Demo completed successfully!" -ForegroundColor Green
    Write-Host "Key URLs:" -ForegroundColor Cyan
    Write-Host "  Application: http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com" -ForegroundColor White
    Write-Host "  Jenkins: http://13.204.60.118:8080" -ForegroundColor White
    
} catch {
    Write-Host "❌ Demo failed: $($_.Exception.Message)" -ForegroundColor Red
    Reset-Demo
} finally {
    $reset = Read-Host "Would you like to reset the demo to original state? (y/n)"
    if ($reset -eq 'y' -or $reset -eq 'Y') {
        Reset-Demo
    }
}

Write-Host ""
Write-Host "Thank you for watching the EKS CI/CD Pipeline Demo! 🚀" -ForegroundColor Cyan
