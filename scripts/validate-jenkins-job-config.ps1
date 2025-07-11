# Jenkins Job Configuration Validator
# Run this after updating your Jenkins job configuration

param(
    [string]$JenkinsUrl = "http://localhost:8080",
    [string]$JobName = "eks-sample-web-app-pipeline"
)

Write-Host "🔍 Validating Jenkins Job Configuration" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Check if Jenkinsfile exists in correct location
$jenkinsfilePath = "k8s-apps\sample-web-app\Jenkinsfile"
if (Test-Path $jenkinsfilePath) {
    Write-Host "✅ Jenkinsfile found at: $jenkinsfilePath" -ForegroundColor Green
    
    # Check file size
    $fileSize = (Get-Item $jenkinsfilePath).Length
    Write-Host "   File size: $fileSize bytes" -ForegroundColor Gray
    
    if ($fileSize -gt 1000) {
        Write-Host "   ✅ File appears to have content" -ForegroundColor Green
    } else {
        Write-Host "   ⚠️ File seems small - check if content is complete" -ForegroundColor Yellow
    }
} else {
    Write-Host "❌ Jenkinsfile NOT found at: $jenkinsfilePath" -ForegroundColor Red
    Write-Host "   The pipeline will fail during checkout!" -ForegroundColor Red
    exit 1
}

# Check if old Jenkinsfile exists (should be removed)
if (Test-Path "Jenkinsfile") {
    Write-Host "⚠️ Old Jenkinsfile still exists in root directory" -ForegroundColor Yellow
    Write-Host "   This might cause confusion - consider removing it" -ForegroundColor Yellow
} else {
    Write-Host "✅ No conflicting Jenkinsfile in root directory" -ForegroundColor Green
}

# Check related files
Write-Host "`n📋 Checking Required Files:" -ForegroundColor Yellow

$requiredFiles = @(
    "k8s-apps\sample-web-app\Dockerfile",
    "k8s-apps\sample-web-app\deployment-ecr.yaml", 
    "k8s-apps\sample-web-app\service.yaml",
    "k8s-apps\sample-web-app\ingress.yaml",
    "k8s-apps\sample-web-app\namespace.yaml",
    "k8s-apps\sample-web-app\configmap.yaml"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file" -ForegroundColor Red
    }
}

# Instructions for Jenkins configuration
Write-Host "`n🔧 Jenkins Job Configuration Required:" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "1. Go to: $JenkinsUrl/job/$JobName/configure" -ForegroundColor Gray
Write-Host "2. Scroll to 'Pipeline' section" -ForegroundColor Gray
Write-Host "3. Set 'Script Path' to: k8s-apps/sample-web-app/Jenkinsfile" -ForegroundColor Yellow
Write-Host "4. Click 'Save'" -ForegroundColor Gray
Write-Host "5. Run 'Build Now'" -ForegroundColor Gray

Write-Host "`n🎯 Quick Access Links:" -ForegroundColor Cyan
Write-Host "=====================" -ForegroundColor Cyan
Write-Host "Jenkins Dashboard: $JenkinsUrl" -ForegroundColor Gray
Write-Host "Job Configuration: $JenkinsUrl/job/$JobName/configure" -ForegroundColor Gray
Write-Host "Build Now: $JenkinsUrl/job/$JobName/build" -ForegroundColor Gray
Write-Host "Console Output: $JenkinsUrl/job/$JobName/lastBuild/console" -ForegroundColor Gray

Write-Host "`n✅ Configuration Summary:" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host "Script Path: k8s-apps/sample-web-app/Jenkinsfile" -ForegroundColor Yellow
Write-Host "Repository: [Your GitHub repo URL]" -ForegroundColor Gray
Write-Host "Branch: */main" -ForegroundColor Gray
Write-Host "Definition: Pipeline script from SCM" -ForegroundColor Gray

Write-Host "`nReady to test your pipeline! 🚀" -ForegroundColor Green
