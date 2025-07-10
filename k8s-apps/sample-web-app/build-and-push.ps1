# Build and Push to ECR Script
# This script builds the Docker image and pushes it to your private ECR repository

param(
    [Parameter(Mandatory=$false)]
    [string]$ImageTag = "latest"
)

$ErrorActionPreference = "Stop"

# Configuration
$AWS_REGION = "ap-south-1"
$AWS_ACCOUNT_ID = "897722681721"
$REPO_NAME = "sample-web-app"
$ECR_URI = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"

Write-Host "🚀 Building and pushing $REPO_NAME to ECR..." -ForegroundColor Cyan

# Check if Docker is running
try {
    docker version | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    Write-Host "💡 You can start it manually or run: Start-Process 'C:\Program Files\Docker\Docker\Docker Desktop.exe'" -ForegroundColor Yellow
    exit 1
}

# Check if we're in the right directory
if (!(Test-Path "Dockerfile")) {
    Write-Host "❌ Dockerfile not found. Make sure you're in the k8s-apps/sample-web-app directory" -ForegroundColor Red
    exit 1
}

try {
    # Authenticate with ECR
    Write-Host "🔐 Authenticating with ECR..." -ForegroundColor Yellow
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URI
    
    # Build the Docker image
    Write-Host "🔨 Building Docker image..." -ForegroundColor Yellow
    docker build -t $REPO_NAME`:$ImageTag .
    
    # Tag for ECR
    Write-Host "🏷️ Tagging image for ECR..." -ForegroundColor Yellow
    docker tag $REPO_NAME`:$ImageTag $ECR_URI`:$ImageTag
    
    # Push to ECR
    Write-Host "📤 Pushing image to ECR..." -ForegroundColor Yellow
    docker push $ECR_URI`:$ImageTag
    
    Write-Host "🎉 Successfully pushed image to ECR!" -ForegroundColor Green
    Write-Host "📋 Image URI: $ECR_URI`:$ImageTag" -ForegroundColor Cyan
    
    # Show image details
    Write-Host "📊 Checking image in ECR..." -ForegroundColor Yellow
    aws ecr describe-images --repository-name $REPO_NAME --region $AWS_REGION --query 'imageDetails[*].[imageTags[0],imageSizeInBytes,imagePushedAt]' --output table
    
} catch {
    Write-Host "❌ Failed to build/push image: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
