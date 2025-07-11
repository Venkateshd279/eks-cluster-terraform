# Quick Fix for Dockerfile and Retry Build
# Run this to fix the Docker build issue

param(
    [Parameter(Mandatory=$true)]
    [string]$JenkinsServerIP,
    [string]$KeyFile = "python.pem"
)

Write-Host "🔧 Fixing Dockerfile and Retrying Build" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$APP_DIR = "k8s-apps/sample-web-app"
$WORKSPACE_DIR = "/var/lib/jenkins/workspace/eks-ci-cd-pipeline/k8s-apps/sample-web-app"

Write-Host "`n1. Copying fixed Dockerfile to Jenkins server..." -ForegroundColor Yellow
scp -i $KeyFile "$APP_DIR/Dockerfile" ubuntu@$JenkinsServerIP`:$WORKSPACE_DIR/

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Dockerfile copied successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to copy Dockerfile" -ForegroundColor Red
    exit 1
}

Write-Host "`n2. Cleaning up failed Docker build..." -ForegroundColor Yellow
ssh -i $KeyFile ubuntu@$JenkinsServerIP "docker system prune -f"

Write-Host "`n3. Retrying Docker build..." -ForegroundColor Yellow
$buildCommands = @"
cd $WORKSPACE_DIR
echo "Building Docker image with fixed Dockerfile..."
docker build -t sample-web-app:manual-1 .
if [ `$? -eq 0 ]; then
    echo "✅ Docker build successful"
    
    echo "Tagging images for ECR..."
    docker tag sample-web-app:manual-1 897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app:manual-1
    docker tag sample-web-app:manual-1 897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app:latest
    
    echo "Logging in to ECR..."
    aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 897722681721.dkr.ecr.ap-south-1.amazonaws.com
    
    echo "Pushing images to ECR..."
    docker push 897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app:manual-1
    docker push 897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app:latest
    
    echo "Verifying images in ECR..."
    aws ecr describe-images --repository-name sample-web-app --region ap-south-1
    
    echo "🎉 Build and push completed successfully!"
else
    echo "❌ Docker build failed again"
    exit 1
fi
"@

ssh -i $KeyFile ubuntu@$JenkinsServerIP $buildCommands

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n🎉 Fixed build completed successfully!" -ForegroundColor Green
    Write-Host "✅ Images should now be in ECR" -ForegroundColor Green
    Write-Host "`n📋 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Verify images in AWS ECR console" -ForegroundColor Gray
    Write-Host "   2. Run Jenkins pipeline again" -ForegroundColor Gray
    Write-Host "   3. Pipeline should now succeed!" -ForegroundColor Gray
} else {
    Write-Host "`n❌ Build still failed!" -ForegroundColor Red
    Write-Host "   Check the error messages above" -ForegroundColor Gray
}

Write-Host "`n4. Checking ECR repository status..." -ForegroundColor Yellow
Write-Host "You can verify with:" -ForegroundColor Gray
Write-Host "aws ecr describe-images --repository-name sample-web-app --region ap-south-1" -ForegroundColor Gray
