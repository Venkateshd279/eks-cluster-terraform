# Copy Files and Build on Jenkins Server
# This script will copy the necessary files to Jenkins server and build the image

param(
    [Parameter(Mandatory=$true)]
    [string]$JenkinsServerIP,
    [string]$KeyFile = "python.pem"
)

Write-Host "🚀 Manual ECR Build via Jenkins Server" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Variables
$APP_DIR = "k8s-apps/sample-web-app"
$REMOTE_DIR = "/tmp/sample-web-app-build"

Write-Host "`n1. Copying files to Jenkins server..." -ForegroundColor Yellow

# Create remote directory
ssh -i $KeyFile ubuntu@$JenkinsServerIP "mkdir -p $REMOTE_DIR"

# Copy required files
Write-Host "   Copying Dockerfile..." -ForegroundColor Gray
scp -i $KeyFile "$APP_DIR/Dockerfile" ubuntu@$JenkinsServerIP`:$REMOTE_DIR/

Write-Host "   Copying index.html..." -ForegroundColor Gray
scp -i $KeyFile "$APP_DIR/index.html" ubuntu@$JenkinsServerIP`:$REMOTE_DIR/

Write-Host "   Copying nginx.conf..." -ForegroundColor Gray
scp -i $KeyFile "$APP_DIR/nginx.conf" ubuntu@$JenkinsServerIP`:$REMOTE_DIR/

Write-Host "   Copying build script..." -ForegroundColor Gray
scp -i $KeyFile "scripts/manual-ecr-build.sh" ubuntu@$JenkinsServerIP`:$REMOTE_DIR/

Write-Host "✅ Files copied successfully" -ForegroundColor Green

Write-Host "`n2. Making build script executable..." -ForegroundColor Yellow
ssh -i $KeyFile ubuntu@$JenkinsServerIP "chmod +x $REMOTE_DIR/manual-ecr-build.sh"

Write-Host "`n3. Running build on Jenkins server..." -ForegroundColor Yellow
Write-Host "   This will:" -ForegroundColor Gray
Write-Host "   - Build Docker image" -ForegroundColor Gray
Write-Host "   - Push to ECR" -ForegroundColor Gray
Write-Host "   - Verify the push" -ForegroundColor Gray
Write-Host ""

# Run the build script
ssh -i $KeyFile ubuntu@$JenkinsServerIP "cd $REMOTE_DIR && ./manual-ecr-build.sh"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 Manual build completed successfully!" -ForegroundColor Green
    Write-Host "✅ Image should now be available in ECR" -ForegroundColor Green
    Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Verify image in ECR console" -ForegroundColor Gray
    Write-Host "   2. Run Jenkins pipeline" -ForegroundColor Gray
    Write-Host "   3. Check deployment status" -ForegroundColor Gray
} else {
    Write-Host "`n❌ Manual build failed!" -ForegroundColor Red
    Write-Host "   Check the output above for errors" -ForegroundColor Gray
}

Write-Host "`n4. Cleaning up remote files..." -ForegroundColor Yellow
ssh -i $KeyFile ubuntu@$JenkinsServerIP "rm -rf $REMOTE_DIR"
Write-Host "✅ Cleanup completed" -ForegroundColor Green
