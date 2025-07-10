# Update ConfigMap Script - Generates configmap.yaml from index.html
# This script reads the index.html file and creates a proper ConfigMap

Write-Host "🔄 UPDATING CONFIGMAP FROM INDEX.HTML" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green
Write-Host ""

# Get current directory (should be run from k8s-apps/sample-web-app/)
$currentDir = Get-Location

# Check if we're in the right directory
if (-not (Test-Path "index.html")) {
    Write-Host "❌ Error: index.html not found in current directory" -ForegroundColor Red
    Write-Host "Please run this script from k8s-apps/sample-web-app/ directory" -ForegroundColor Yellow
    exit 1
}

# Check if we're in k8s-apps/sample-web-app directory
if ($currentDir.Path -notlike "*k8s-apps*sample-web-app*") {
    Write-Host "⚠️  Warning: Not in k8s-apps/sample-web-app directory" -ForegroundColor Yellow
    Write-Host "Current directory: $currentDir" -ForegroundColor Gray
}

Write-Host "📂 Working directory: $currentDir" -ForegroundColor Cyan
Write-Host ""

# Read the HTML content
Write-Host "📖 Reading index.html..." -ForegroundColor Yellow
try {
    $htmlContent = Get-Content "index.html" -Raw -Encoding UTF8
    Write-Host "✅ Successfully read index.html ($($htmlContent.Length) characters)" -ForegroundColor Green
} catch {
    Write-Host "❌ Error reading index.html: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Create the ConfigMap YAML content
Write-Host "🔨 Generating ConfigMap YAML..." -ForegroundColor Yellow

$configMapContent = @"
apiVersion: v1
kind: ConfigMap
metadata:
  name: web-app-content
  namespace: sample-apps
  labels:
    app: sample-web-app
  annotations:
    generated-from: index.html
    generated-at: "$(Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ')"
data:
  # This ConfigMap was auto-generated from index.html
  # To update:
  # 1. Edit index.html
  # 2. Run: .\scripts\update-configmap.ps1 (from project root)
  # 3. Apply: kubectl apply -f configmap.yaml
  # 4. Restart: kubectl rollout restart deployment/sample-web-app -n sample-apps
  
  index.html: |
$($htmlContent -split "`n" | ForEach-Object { "    " + $_ } | Out-String)
"@

# Write the ConfigMap to file
Write-Host "💾 Writing configmap.yaml..." -ForegroundColor Yellow
try {
    $configMapContent | Out-File "configmap.yaml" -Encoding UTF8
    Write-Host "✅ Successfully created configmap.yaml" -ForegroundColor Green
} catch {
    Write-Host "❌ Error writing configmap.yaml: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Validate the YAML (basic check)
Write-Host "🔍 Validating YAML format..." -ForegroundColor Yellow
try {
    $yamlTest = Get-Content "configmap.yaml" -Raw
    if ($yamlTest -match "apiVersion: v1" -and $yamlTest -match "kind: ConfigMap") {
        Write-Host "✅ YAML format looks valid" -ForegroundColor Green
    } else {
        Write-Host "⚠️  YAML format may have issues" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠️  Could not validate YAML" -ForegroundColor Yellow
}

# Show file size information
$htmlSize = (Get-Item "index.html").Length
$yamlSize = (Get-Item "configmap.yaml").Length
Write-Host ""
Write-Host "📊 File Information:" -ForegroundColor Cyan
Write-Host "  • index.html: $([math]::Round($htmlSize / 1KB, 2)) KB" -ForegroundColor White
Write-Host "  • configmap.yaml: $([math]::Round($yamlSize / 1KB, 2)) KB" -ForegroundColor White

Write-Host ""
Write-Host "🎉 ConfigMap Successfully Generated!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "1. Review the generated configmap.yaml" -ForegroundColor White
Write-Host "2. Apply to cluster: kubectl apply -f configmap.yaml" -ForegroundColor White
Write-Host "3. Restart deployment: kubectl rollout restart deployment/sample-web-app -n sample-apps" -ForegroundColor White
Write-Host "4. Check status: kubectl get pods -n sample-apps" -ForegroundColor White
Write-Host ""
Write-Host "💡 For future updates:" -ForegroundColor Cyan
Write-Host "  • Edit index.html directly" -ForegroundColor White
Write-Host "  • Run this script again to regenerate configmap.yaml" -ForegroundColor White
Write-Host "  • Apply and restart to see changes" -ForegroundColor White
Write-Host ""
Write-Host "✅ Ready for deployment!" -ForegroundColor Green
