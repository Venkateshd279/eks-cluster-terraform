#!/bin/bash

# Manual ECR Build and Push Script for Jenkins Server
# Run this on your Jenkins server where Docker is available

# Set variables
AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="897722681721"
APP_NAME="sample-web-app"
ECR_REGISTRY="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
IMAGE_REPO="$ECR_REGISTRY/$APP_NAME"
IMAGE_TAG="manual-1"

echo "🐳 Manual ECR Build and Push Script"
echo "================================="

# Step 1: Verify tools
echo ""
echo "1. Verifying tools..."
if command -v aws &> /dev/null; then
    echo "✅ AWS CLI: $(aws --version)"
else
    echo "❌ AWS CLI not found"
    exit 1
fi

if command -v docker &> /dev/null; then
    echo "✅ Docker: $(docker --version)"
else
    echo "❌ Docker not found"
    exit 1
fi

# Step 2: Check AWS credentials
echo ""
echo "2. Checking AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    IDENTITY=$(aws sts get-caller-identity)
    echo "✅ AWS credentials configured"
    echo "   Account: $(echo $IDENTITY | jq -r '.Account')"
    echo "   User: $(echo $IDENTITY | jq -r '.Arn')"
else
    echo "❌ AWS credentials not configured"
    exit 1
fi

# Step 3: Navigate to app directory
echo ""
echo "3. Navigating to app directory..."
cd /var/lib/jenkins/workspace/eks-sample-web-app-pipeline/k8s-apps/sample-web-app || {
    echo "❌ Could not find app directory"
    echo "Available directories:"
    find /var/lib/jenkins/workspace -name "*sample-web-app*" -type d 2>/dev/null
    exit 1
}
echo "✅ In directory: $(pwd)"

# Step 4: Check required files
echo ""
echo "4. Checking required files..."
if [ -f "Dockerfile" ]; then
    echo "✅ Dockerfile found"
else
    echo "❌ Dockerfile not found"
    exit 1
fi

if [ -f "index.html" ]; then
    echo "✅ index.html found"
else
    echo "❌ index.html not found"
    exit 1
fi

# Step 5: Create ECR repository if needed
echo ""
echo "5. Creating ECR repository if needed..."
if aws ecr describe-repositories --repository-names $APP_NAME --region $AWS_REGION &> /dev/null; then
    echo "✅ ECR repository '$APP_NAME' already exists"
else
    echo "📦 Creating ECR repository '$APP_NAME'..."
    if aws ecr create-repository --repository-name $APP_NAME --region $AWS_REGION; then
        echo "✅ ECR repository created successfully"
    else
        echo "❌ Failed to create ECR repository"
        exit 1
    fi
fi

# Step 6: Build Docker image
echo ""
echo "6. Building Docker image..."
echo "Image will be tagged as: $IMAGE_REPO:$IMAGE_TAG"
if docker build -t $APP_NAME:$IMAGE_TAG .; then
    echo "✅ Docker image built successfully"
else
    echo "❌ Docker build failed"
    exit 1
fi

# Step 7: Tag image for ECR
echo ""
echo "7. Tagging image for ECR..."
docker tag $APP_NAME:$IMAGE_TAG $IMAGE_REPO:$IMAGE_TAG
docker tag $APP_NAME:$IMAGE_TAG $IMAGE_REPO:latest
echo "✅ Images tagged for ECR"

# Show docker images
echo ""
echo "Docker images:"
docker images | grep $APP_NAME

# Step 8: Login to ECR
echo ""
echo "8. Logging in to ECR..."
if aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY; then
    echo "✅ ECR login successful"
else
    echo "❌ ECR login failed"
    exit 1
fi

# Step 9: Push images to ECR
echo ""
echo "9. Pushing images to ECR..."
echo "Pushing $IMAGE_REPO:$IMAGE_TAG..."
if docker push $IMAGE_REPO:$IMAGE_TAG; then
    echo "✅ Tagged image pushed successfully"
else
    echo "❌ Failed to push tagged image"
    exit 1
fi

echo "Pushing $IMAGE_REPO:latest..."
if docker push $IMAGE_REPO:latest; then
    echo "✅ Latest image pushed successfully"
else
    echo "❌ Failed to push latest image"
    exit 1
fi

# Step 10: Verify images in ECR
echo ""
echo "10. Verifying images in ECR..."
if aws ecr describe-images --repository-name $APP_NAME --region $AWS_REGION; then
    echo "✅ Images verified in ECR"
else
    echo "⚠️ Could not verify images in ECR"
fi

# Step 11: Cleanup local images
echo ""
echo "11. Cleaning up local images..."
docker rmi $APP_NAME:$IMAGE_TAG 2>/dev/null || true
docker rmi $IMAGE_REPO:$IMAGE_TAG 2>/dev/null || true
docker rmi $IMAGE_REPO:latest 2>/dev/null || true
echo "✅ Local images cleaned up"

echo ""
echo "🎉 Manual ECR build and push completed successfully!"
echo "================================="
echo "Image URI: $IMAGE_REPO:$IMAGE_TAG"
echo "Latest URI: $IMAGE_REPO:latest"
echo ""
echo "You can now run the Jenkins pipeline!"
