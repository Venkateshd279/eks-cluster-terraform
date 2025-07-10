# 🚀 ECR Deployment Guide

You've created a private ECR repository! Here's how to use it:

## 📋 ECR Repository Details
- **Repository URI**: `897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app`
- **Region**: ap-south-1
- **Status**: Created (empty)

## 🔄 Two Deployment Options

### Option 1: Keep ConfigMap Approach (Current)
**Pros**: Fast demo updates, simple
**File**: `deployment.yaml` (with ConfigMap mount)
```yaml
image: nginx:1.25-alpine
# HTML from ConfigMap volume
```

### Option 2: Use ECR with Custom Images
**Pros**: Production CI/CD, immutable deployments
**File**: `deployment-ecr.yaml` (no ConfigMap)
```yaml
image: 897722681721.dkr.ecr.ap-south-1.amazonaws.com/sample-web-app:latest
# HTML baked into image
```

## 🛠️ Steps to Use ECR

### Step 1: Start Docker Desktop
```powershell
# Make sure Docker Desktop is running
docker version
```

### Step 2: Build and Push Image
```powershell
# Navigate to app directory
cd k8s-apps\sample-web-app

# Run the build script
.\build-and-push.ps1
```

### Step 3: Deploy ECR Version
```powershell
# Apply the ECR-based deployment
kubectl apply -f deployment-ecr.yaml

# Watch the rollout
kubectl rollout status deployment/sample-web-app -n sample-apps
```

### Step 4: Verify
```powershell
# Check pods are using new image
kubectl get pods -n sample-apps -o wide

# Check the application
# URL: http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com
```

## 🔄 Updating with ECR Workflow

### Traditional Way (ConfigMap):
1. Edit `configmap.yaml`
2. `kubectl apply -f configmap.yaml`
3. `kubectl rollout restart deployment/sample-web-app -n sample-apps`

### ECR Way (Immutable):
1. Edit `index.html`
2. `.\build-and-push.ps1 -ImageTag "v1.1"`
3. Update `deployment-ecr.yaml` with new tag
4. `kubectl apply -f deployment-ecr.yaml`

## 🎯 For Your Demo

**Recommendation**: Start with ConfigMap for quick demos, then show ECR as "production approach"

### Demo Script:
1. **Show current app** (ConfigMap version)
2. **Explain**: "This is great for development, but in production we use immutable images"
3. **Show ECR repository**: `aws ecr describe-repositories`
4. **Build & push**: `.\build-and-push.ps1`
5. **Deploy ECR version**: `kubectl apply -f deployment-ecr.yaml`
6. **Compare**: "Same app, different deployment strategy"

## 🚨 Troubleshooting

### Docker not running:
```powershell
# Start Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
```

### ECR authentication issues:
```powershell
# Re-authenticate
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 897722681721.dkr.ecr.ap-south-1.amazonaws.com
```

### Image pull issues in Kubernetes:
```powershell
# Check if EKS nodes can pull from ECR (they should have permission)
kubectl describe pod [pod-name] -n sample-apps
```

Your ECR repository is ready! 🎉
