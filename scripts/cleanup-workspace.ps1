# Workspace Cleanup Script - Remove Unnecessary Files
# This script identifies and removes redundant/temporary files

Write-Host "🧹 WORKSPACE CLEANUP - REMOVING UNNECESSARY FILES" -ForegroundColor Green
Write-Host "=================================================" -ForegroundColor Green
Write-Host ""

$FilesToRemove = @()
$DirectoriesToRemove = @()

Write-Host "🔍 Analyzing workspace for unnecessary files..." -ForegroundColor Yellow
Write-Host ""

# Function to add file for removal
function Add-FileForRemoval {
    param($FilePath, $Reason)
    if (Test-Path $FilePath) {
        $FilesToRemove += @{Path = $FilePath; Reason = $Reason}
        Write-Host "📝 MARKED: $FilePath - $Reason" -ForegroundColor Yellow
    }
}

# Function to add directory for removal
function Add-DirectoryForRemoval {
    param($DirPath, $Reason)
    if (Test-Path $DirPath) {
        $DirectoriesToRemove += @{Path = $DirPath; Reason = $Reason}
        Write-Host "📂 MARKED: $DirPath - $Reason" -ForegroundColor Yellow
    }
}

Write-Host "🔍 IDENTIFYING UNNECESSARY FILES:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# 1. Duplicate/redundant documentation files
Add-FileForRemoval "DEPLOYMENT_SUCCESS_SUMMARY.md" "Outdated deployment summary"
Add-FileForRemoval "JENKINS_DEPLOY.md" "Redundant with main docs"
Add-FileForRemoval "BACKEND_SETUP.md" "Setup info now in main README"
Add-FileForRemoval "CICD_SETUP_GUIDE.md" "Covered in main documentation"

# 2. Redundant Kubernetes manifests
Add-FileForRemoval "k8s-sample-app.yaml" "Replaced by modular k8s-apps/"
Add-FileForRemoval "jenkins-server.tf" "Moved to cicd/jenkins/"

# 3. Old/redundant scripts
Add-FileForRemoval "scripts\check-jenkins-installation.ps1" "Replaced by demo scripts"
Add-FileForRemoval "scripts\check-jenkins-status.ps1" "Redundant functionality"
Add-FileForRemoval "scripts\check-jenkins-status.sh" "Duplicate of PowerShell version"
Add-FileForRemoval "scripts\fix-jenkins-direct.ps1" "Troubleshooting script no longer needed"
Add-FileForRemoval "scripts\fix-jenkins-eks-access.ps1" "Troubleshooting script no longer needed"
Add-FileForRemoval "scripts\fix-jenkins-user-remote.ps1" "Troubleshooting script no longer needed"
Add-FileForRemoval "scripts\fix-jenkins-user.sh" "Troubleshooting script no longer needed"
Add-FileForRemoval "scripts\jenkins-fix.sh" "Troubleshooting script no longer needed"
Add-FileForRemoval "scripts\jenkins-troubleshoot.ps1" "Troubleshooting script no longer needed"
Add-FileForRemoval "scripts\monitor-jenkins-installation.ps1" "Setup script no longer needed"
Add-FileForRemoval "scripts\setup-git-hook-auto.sh" "Manual setup approach deprecated"
Add-FileForRemoval "scripts\setup-git-hook.sh" "Manual setup approach deprecated"
Add-FileForRemoval "scripts\test-jenkins-pipeline.ps1" "Replaced by demo scripts"
Add-FileForRemoval "scripts\test-jenkins-ubuntu.ps1" "OS-specific script not needed"
Add-FileForRemoval "scripts\verify-jenkins-setup.ps1" "Setup verification no longer needed"
Add-FileForRemoval "scripts\verify-pipeline-fix.ps1" "Pipeline fix verification no longer needed"

# 4. Security check duplicates
Add-FileForRemoval "scripts\security-check.bat" "Batch file version not needed"
Add-FileForRemoval "scripts\security-check.sh" "Shell version not needed (have PowerShell)"

# 5. Duplicate deployment scripts
Add-FileForRemoval "k8s-apps\sample-web-app\deploy.sh" "Shell version not needed (have PowerShell)"

# 6. Temporary/generated files that might exist
Add-FileForRemoval "python.pem" "Temporary key file"
Add-FileForRemoval "python.ppk" "Temporary key file"
Add-FileForRemoval "generate_architecture_diagram.py" "Used once, can be recreated if needed"

# 7. Redundant service files
Add-FileForRemoval "k8s-apps\sample-web-app\service-nodeport.yaml" "NodePort not used in production setup"

Write-Host ""
Write-Host "📊 CLEANUP SUMMARY:" -ForegroundColor Cyan
Write-Host "==================" -ForegroundColor Cyan
Write-Host "Files to remove: $($FilesToRemove.Count)" -ForegroundColor White
Write-Host "Directories to remove: $($DirectoriesToRemove.Count)" -ForegroundColor White
Write-Host ""

if ($FilesToRemove.Count -eq 0 -and $DirectoriesToRemove.Count -eq 0) {
    Write-Host "✅ Workspace is already clean!" -ForegroundColor Green
    exit 0
}

Write-Host "🗑️  FILES TO BE REMOVED:" -ForegroundColor Red
Write-Host "=======================" -ForegroundColor Red
foreach ($file in $FilesToRemove) {
    Write-Host "  ❌ $($file.Path)" -ForegroundColor Red
    Write-Host "     Reason: $($file.Reason)" -ForegroundColor Gray
}

if ($DirectoriesToRemove.Count -gt 0) {
    Write-Host ""
    Write-Host "📂 DIRECTORIES TO BE REMOVED:" -ForegroundColor Red
    Write-Host "=============================" -ForegroundColor Red
    foreach ($dir in $DirectoriesToRemove) {
        Write-Host "  ❌ $($dir.Path)" -ForegroundColor Red
        Write-Host "     Reason: $($dir.Reason)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "⚠️  IMPORTANT:" -ForegroundColor Yellow
Write-Host "This will permanently delete the above files." -ForegroundColor Yellow
Write-Host "Make sure you have backups if needed." -ForegroundColor Yellow
Write-Host ""

$confirmation = Read-Host "Do you want to proceed with cleanup? (y/N)"

if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
    Write-Host ""
    Write-Host "🧹 CLEANING UP WORKSPACE..." -ForegroundColor Green
    Write-Host "===========================" -ForegroundColor Green
    
    $removedCount = 0
    
    # Remove files
    foreach ($file in $FilesToRemove) {
        if (Test-Path $file.Path) {
            try {
                Remove-Item $file.Path -Force
                Write-Host "✅ Removed: $($file.Path)" -ForegroundColor Green
                $removedCount++
            } catch {
                Write-Host "❌ Failed to remove: $($file.Path) - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    # Remove directories
    foreach ($dir in $DirectoriesToRemove) {
        if (Test-Path $dir.Path) {
            try {
                Remove-Item $dir.Path -Recurse -Force
                Write-Host "✅ Removed directory: $($dir.Path)" -ForegroundColor Green
                $removedCount++
            } catch {
                Write-Host "❌ Failed to remove directory: $($dir.Path) - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
    
    Write-Host ""
    Write-Host "🎉 CLEANUP COMPLETE!" -ForegroundColor Green
    Write-Host "===================" -ForegroundColor Green
    Write-Host "Removed $removedCount items" -ForegroundColor White
    Write-Host ""
    Write-Host "✅ KEPT ESSENTIAL FILES:" -ForegroundColor Cyan
    Write-Host "  • Terraform infrastructure code" -ForegroundColor White
    Write-Host "  • Main documentation (README.md)" -ForegroundColor White
    Write-Host "  • Demo guides and scripts" -ForegroundColor White
    Write-Host "  • Architecture diagrams" -ForegroundColor White
    Write-Host "  • Working CI/CD pipeline" -ForegroundColor White
    Write-Host "  • Production K8s manifests" -ForegroundColor White
    Write-Host "  • Essential test scripts" -ForegroundColor White
    
} else {
    Write-Host ""
    Write-Host "❌ Cleanup cancelled." -ForegroundColor Yellow
    Write-Host "No files were removed." -ForegroundColor Gray
}

Write-Host ""
Write-Host "📋 FINAL WORKSPACE STRUCTURE:" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host "Essential files that remain:" -ForegroundColor White
Write-Host "  📁 Root: Terraform code, docs, diagrams" -ForegroundColor White
Write-Host "  📁 scripts/: Demo and test scripts" -ForegroundColor White
Write-Host "  📁 k8s-apps/: Kubernetes applications" -ForegroundColor White
Write-Host "  📁 cicd/: Jenkins CI/CD configuration" -ForegroundColor White
Write-Host ""
Write-Host "🚀 Your workspace is now clean and production-ready!" -ForegroundColor Green
