# Manual ECR Build and Push Script for Jenkins Server
# Run this on your Jenkins server where Docker is available

# Set variables
$AWS_REGION = "ap-south-1"
$AWS_ACCOUNT_ID = "897722681721"
$APP_NAME = "sample-web-app"
$ECR_REGISTRY = "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
$IMAGE_REPO = "$ECR_REGISTRY/$APP_NAME"
$IMAGE_TAG = "manual-1"

Write-Host "🐳 Manual ECR Build and Push Script" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Step 1: Verify tools
Write-Host "`n1. Verifying tools..." -ForegroundColor Yellow
try {
    $awsVersion = aws --version 2>&1
    Write-Host "✅ AWS CLI: $awsVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS CLI not found" -ForegroundColor Red
    exit 1
}

try {
    $dockerVersion = docker --version 2>&1
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker not found" -ForegroundColor Red
    exit 1
}

# Step 2: Check AWS credentials
Write-Host "`n2. Checking AWS credentials..." -ForegroundColor Yellow
try {
    $identity = aws sts get-caller-identity | ConvertFrom-Json
    Write-Host "✅ AWS Account: $($identity.Account)" -ForegroundColor Green
    Write-Host "✅ AWS User: $($identity.Arn)" -ForegroundColor Green
} catch {
    Write-Host "❌ AWS credentials not configured" -ForegroundColor Red
    exit 1
}

# Step 3: Create ECR repository if needed
Write-Host "`n3. Creating ECR repository if needed..." -ForegroundColor Yellow
try {
    $repoCheck = aws ecr describe-repositories --repository-names $APP_NAME --region $AWS_REGION 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ECR repository '$APP_NAME' already exists" -ForegroundColor Green
    } else {
        Write-Host "📦 Creating ECR repository '$APP_NAME'..." -ForegroundColor Yellow
        aws ecr create-repository --repository-name $APP_NAME --region $AWS_REGION
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ ECR repository created successfully" -ForegroundColor Green
        } else {
            Write-Host "❌ Failed to create ECR repository" -ForegroundColor Red
            exit 1
        }
    }
} catch {
    Write-Host "❌ Error checking/creating ECR repository" -ForegroundColor Red
    exit 1
}

# Step 4: Build Docker image
Write-Host "`n4. Building Docker image..." -ForegroundColor Yellow
Write-Host "Image will be tagged as: $IMAGE_REPO`:$IMAGE_TAG" -ForegroundColor Gray

try {
    docker build -t "$APP_NAME`:$IMAGE_TAG" .
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Docker image built successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Docker build failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error building Docker image" -ForegroundColor Red
    exit 1
}

# Step 5: Tag image for ECR
Write-Host "`n5. Tagging image for ECR..." -ForegroundColor Yellow
try {
    docker tag "$APP_NAME`:$IMAGE_TAG" "$IMAGE_REPO`:$IMAGE_TAG"
    docker tag "$APP_NAME`:$IMAGE_TAG" "$IMAGE_REPO`:latest"
    Write-Host "✅ Images tagged for ECR" -ForegroundColor Green
    
    # Show docker images
    Write-Host "`nDocker images:" -ForegroundColor Gray
    docker images | Select-String $APP_NAME
} catch {
    Write-Host "❌ Error tagging images" -ForegroundColor Red
    exit 1
}

# Step 6: Login to ECR
Write-Host "`n6. Logging in to ECR..." -ForegroundColor Yellow
try {
    $loginResult = aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ECR login successful" -ForegroundColor Green
    } else {
        Write-Host "❌ ECR login failed" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error logging in to ECR" -ForegroundColor Red
    exit 1
}

# Step 7: Push images to ECR
Write-Host "`n7. Pushing images to ECR..." -ForegroundColor Yellow
try {
    Write-Host "Pushing $IMAGE_REPO`:$IMAGE_TAG..." -ForegroundColor Gray
    docker push "$IMAGE_REPO`:$IMAGE_TAG"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Tagged image pushed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to push tagged image" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "Pushing $IMAGE_REPO`:latest..." -ForegroundColor Gray
    docker push "$IMAGE_REPO`:latest"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Latest image pushed successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to push latest image" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Error pushing images to ECR" -ForegroundColor Red
    exit 1
}

# Step 8: Verify images in ECR
Write-Host "`n8. Verifying images in ECR..." -ForegroundColor Yellow
try {
    $images = aws ecr describe-images --repository-name $APP_NAME --region $AWS_REGION | ConvertFrom-Json
    Write-Host "✅ Images in ECR repository:" -ForegroundColor Green
    foreach ($image in $images.imageDetails) {
        Write-Host "   - Tags: $($image.imageTags -join ', ')" -ForegroundColor Gray
        Write-Host "   - Pushed: $($image.imagePushedAt)" -ForegroundColor Gray
        Write-Host "   - Size: $([math]::Round($image.imageSizeInBytes / 1MB, 2)) MB" -ForegroundColor Gray
        Write-Host ""
    }
} catch {
    Write-Host "⚠️ Could not verify images in ECR" -ForegroundColor Yellow
}

# Step 9: Cleanup local images
Write-Host "`n9. Cleaning up local images..." -ForegroundColor Yellow
try {
    docker rmi "$APP_NAME`:$IMAGE_TAG" 2>$null
    docker rmi "$IMAGE_REPO`:$IMAGE_TAG" 2>$null
    docker rmi "$IMAGE_REPO`:latest" 2>$null
    Write-Host "✅ Local images cleaned up" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Some local images could not be removed" -ForegroundColor Yellow
}

Write-Host "`n🎉 Manual ECR build and push completed successfully!" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host "Image URI: $IMAGE_REPO`:$IMAGE_TAG" -ForegroundColor Cyan
Write-Host "Latest URI: $IMAGE_REPO`:latest" -ForegroundColor Cyan
Write-Host "`nYou can now run the Jenkins pipeline!" -ForegroundColor Green
