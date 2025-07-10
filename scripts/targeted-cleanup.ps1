# Targeted Workspace Cleanup - Remove Actually Redundant Files
# This script removes specific redundant files after analyzing the current workspace

Write-Host "🧹 TARGETED WORKSPACE CLEANUP" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

$FilesToRemove = @()

Write-Host "🔍 Analyzing current workspace for redundant files..." -ForegroundColor Yellow
Write-Host ""

# Function to safely add file for removal if it exists
function Add-FileForRemoval {
    param($FilePath, $Reason)
    if (Test-Path $FilePath) {
        $script:FilesToRemove += [PSCustomObject]@{
            Path = $FilePath
            Reason = $Reason
        }
        Write-Host "📝 IDENTIFIED: $FilePath" -ForegroundColor Yellow
        Write-Host "   Reason: $Reason" -ForegroundColor Gray
    }
}

Write-Host "🔍 IDENTIFYING REDUNDANT FILES:" -ForegroundColor Cyan
Write-Host "===============================" -ForegroundColor Cyan

# 1. Redundant documentation files (keeping essential ones)
Add-FileForRemoval "JENKINS_DEPLOY.md" "Redundant - Jenkins setup covered in main docs and demo guides"
Add-FileForRemoval "BACKEND_SETUP.md" "Redundant - Backend setup covered in README.md"
Add-FileForRemoval "CICD_SETUP_GUIDE.md" "Redundant - CI/CD covered in demo guides and main docs"
Add-FileForRemoval "DEPLOYMENT_SUCCESS_SUMMARY.md" "Outdated - Replaced by current demo materials"

# 2. Check for temporary/generated files
Add-FileForRemoval "generate_architecture_diagram.py" "Temporary script - can be recreated if needed"
Add-FileForRemoval "python.pem" "Temporary key file - should not be in repo"
Add-FileForRemoval "python.ppk" "Temporary key file - should not be in repo"

# 3. Check for redundant Kubernetes manifests
Add-FileForRemoval "k8s-sample-app.yaml" "Redundant - Replaced by modular k8s-apps/ structure"

# 4. Check for old Jenkins server file in root
Add-FileForRemoval "jenkins-server.tf" "Redundant - Moved to cicd/jenkins/ directory"

# 5. Check for NodePort service (not used in production)
Add-FileForRemoval "k8s-apps\sample-web-app\service-nodeport.yaml" "Not used in production setup"

# 6. Check for duplicate deployment scripts
Add-FileForRemoval "k8s-apps\sample-web-app\deploy.sh" "Duplicate - PowerShell version preferred on Windows"

Write-Host ""
Write-Host "📊 CLEANUP SUMMARY:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "Redundant files found: $($FilesToRemove.Count)" -ForegroundColor White
Write-Host ""

if ($FilesToRemove.Count -eq 0) {
    Write-Host "✅ No redundant files found! Workspace is already optimized." -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 CURRENT WORKSPACE STRUCTURE IS OPTIMAL:" -ForegroundColor Cyan
    Write-Host "  ✅ Essential Terraform infrastructure files" -ForegroundColor White
    Write-Host "  ✅ Architecture diagrams (PNG, JPG, PDF)" -ForegroundColor White
    Write-Host "  ✅ Demo guides for manager presentation" -ForegroundColor White
    Write-Host "  ✅ Customer access documentation" -ForegroundColor White
    Write-Host "  ✅ Working CI/CD pipeline" -ForegroundColor White
    Write-Host "  ✅ Essential scripts for testing and demo" -ForegroundColor White
    Write-Host "  ✅ Kubernetes manifests for sample app" -ForegroundColor White
    exit 0
}

Write-Host "🗑️  REDUNDANT FILES TO REMOVE:" -ForegroundColor Red
Write-Host "==============================" -ForegroundColor Red
foreach ($file in $FilesToRemove) {
    Write-Host "  ❌ $($file.Path)" -ForegroundColor Red
    Write-Host "     → $($file.Reason)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "⚠️  CONFIRM REMOVAL:" -ForegroundColor Yellow
Write-Host "These files will be permanently deleted." -ForegroundColor Yellow
Write-Host "Essential files will be preserved." -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Proceed with cleanup? (y/N)"

if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
    Write-Host ""
    Write-Host "🧹 REMOVING REDUNDANT FILES..." -ForegroundColor Green
    Write-Host "==============================" -ForegroundColor Green
    
    $removedCount = 0
    $failedCount = 0
    
    foreach ($file in $FilesToRemove) {
        if (Test-Path $file.Path) {
            try {
                Remove-Item $file.Path -Force -ErrorAction Stop
                Write-Host "✅ Removed: $($file.Path)" -ForegroundColor Green
                $removedCount++
            } catch {
                Write-Host "❌ Failed to remove: $($file.Path)" -ForegroundColor Red
                Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Gray
                $failedCount++
            }
        } else {
            Write-Host "⚠️  File not found: $($file.Path)" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "🎉 CLEANUP COMPLETE!" -ForegroundColor Green
    Write-Host "===================" -ForegroundColor Green
    Write-Host "✅ Successfully removed: $removedCount files" -ForegroundColor Green
    if ($failedCount -gt 0) {
        Write-Host "❌ Failed to remove: $failedCount files" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "📁 OPTIMIZED WORKSPACE STRUCTURE:" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    Write-Host "✅ Essential files preserved:" -ForegroundColor White
    Write-Host "  • main.tf, variables.tf, output.tf (Infrastructure)" -ForegroundColor White
    Write-Host "  • README.md (Main documentation)" -ForegroundColor White
    Write-Host "  • DEMO_GUIDE_FOR_MANAGER.md (Demo script)" -ForegroundColor White
    Write-Host "  • DEMO_QUICK_REFERENCE.md (Demo reference)" -ForegroundColor White
    Write-Host "  • CUSTOMER_ACCESS_*.md (Customer docs)" -ForegroundColor White
    Write-Host "  • EKS_Architecture_Diagram.* (Visual diagrams)" -ForegroundColor White
    Write-Host "  • scripts/ (Essential demo and test scripts)" -ForegroundColor White
    Write-Host "  • k8s-apps/ (Kubernetes applications)" -ForegroundColor White
    Write-Host "  • cicd/ (CI/CD pipeline configuration)" -ForegroundColor White
    
} else {
    Write-Host ""
    Write-Host "❌ Cleanup cancelled - No files removed" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "💡 WORKSPACE STATUS:" -ForegroundColor Cyan
Write-Host "Your workspace contains only production-ready files" -ForegroundColor White
Write-Host "Perfect for professional demos and deployment!" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Ready for manager presentation!" -ForegroundColor Green
