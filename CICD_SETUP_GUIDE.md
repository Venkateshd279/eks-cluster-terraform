# 🚀 Complete CI/CD Setup Guide for EKS

This guide will walk you through setting up a complete CI/CD pipeline using Jenkins to deploy applications to your EKS cluster.

## 📋 Overview

**What we'll set up:**
- Jenkins pipeline job
- Automated Docker image builds
- Push to Amazon ECR
- Deploy to EKS cluster
- Automated testing and verification

**Architecture:**
```
Git Repository → Jenkins → Docker Build → ECR → EKS Deployment
```

## 🛠️ Step-by-Step Setup

### Step 1: Install Required Jenkins Plugins

1. **Access Jenkins UI:** `http://13.204.60.118:8080`

2. **Go to:** `Manage Jenkins` → `Manage Plugins` → `Available Plugins`

3. **Install these plugins:**
   ```
   ✅ Pipeline Plugin
   ✅ Git Plugin  
   ✅ Docker Pipeline Plugin
   ✅ Blue Ocean (optional, for better UI)
   ✅ Kubernetes Plugin (optional)
   ```

4. **Restart Jenkins** after installation

### Step 2: Create ECR Repository

Run this command to create the ECR repository for your app:

```bash
aws ecr create-repository --repository-name sample-web-app --region ap-south-1
```

Or the Jenkins pipeline will create it automatically.

### Step 3: Set Up Git Repository (Choose One)

#### Option A: Use Local Git Repository
```bash
# Navigate to your app directory
cd k8s-apps/sample-web-app

# Initialize git repository
git init
git add .
git commit -m "Initial commit - Sample web app"

# Optional: Push to remote repository (GitHub, GitLab, etc.)
```

#### Option B: Use Existing Git Repository
If you already have a Git repository, ensure the Jenkinsfile is in the root or specify the correct path.

### Step 4: Create Jenkins Pipeline Job

1. **In Jenkins UI:**
   - Click `New Item`
   - Enter name: `sample-web-app-pipeline`
   - Select `Pipeline`
   - Click `OK`

2. **Configure Pipeline:**

   **General Settings:**
   - ✅ `GitHub project` (if using GitHub)
   - URL: `https://github.com/yourusername/your-repo`

   **Build Triggers:**
   - ✅ `Poll SCM` (for automatic builds)
   - Schedule: `H/5 * * * *` (check every 5 minutes)
   
   **Pipeline Definition:**
   - **Definition:** `Pipeline script from SCM`
   - **SCM:** `Git`
   - **Repository URL:** Your Git repository URL
   - **Credentials:** Add if private repository
   - **Branch:** `*/main` or `*/master`
   - **Script Path:** `k8s-apps/sample-web-app/Jenkinsfile`

3. **Save the configuration**

### Step 5: Test the Pipeline

1. **Manual Trigger:**
   - Click `Build Now` in your pipeline job
   - Watch the build progress in real-time

2. **Monitor Pipeline:**
   - Click on build number to see console output
   - Each stage will show progress and logs

### Step 6: Verify Deployment

After successful pipeline execution:

```bash
# Check deployment status
kubectl get all -n sample-apps

# Get application URL
kubectl get ingress -n sample-apps

# Check application logs
kubectl logs -n sample-apps -l app=sample-web-app --tail=50
```

## 🔧 Pipeline Stages Explained

### 1. **Checkout** 🔄
- Gets latest code from Git repository
- Extracts commit information for tagging

### 2. **Environment Setup** ⚙️
- Verifies AWS CLI, kubectl, Docker are available
- Configures AWS credentials

### 3. **Create ECR Repository** 📦
- Creates ECR repository if it doesn't exist
- Ensures image registry is ready

### 4. **Build Docker Image** 🐳
- Builds Docker image from Dockerfile
- Tags with build number and commit hash

### 5. **Push to ECR** ⬆️
- Authenticates with ECR
- Pushes Docker image to registry

### 6. **Update Manifests** 📝
- Updates Kubernetes deployment with new image tag
- Ensures latest image is deployed

### 7. **Configure EKS** 🔐
- Updates kubeconfig for cluster access
- Verifies connection to EKS

### 8. **Deploy to EKS** 🚀
- Applies all Kubernetes manifests
- Creates/updates application resources

### 9. **Wait for Deployment** ⏳
- Waits for pods to be ready
- Ensures rolling update completes

### 10. **Verify Deployment** ✅
- Checks application health
- Displays service endpoints and URLs

### 11. **Cleanup** 🧹
- Removes local Docker images
- Frees up disk space

## 🎯 Environment Variables

The pipeline uses these key variables:

```bash
AWS_REGION=ap-south-1
EKS_CLUSTER_NAME=my-eks-cluster
APP_NAME=sample-web-app
NAMESPACE=sample-apps
AWS_ACCOUNT_ID=897722681721
```

## 📊 Monitoring and Logs

### Jenkins Monitoring:
- **Pipeline View:** Shows all stages and status
- **Blue Ocean:** Modern UI for pipeline visualization
- **Console Output:** Detailed logs for each stage

### Application Monitoring:
```bash
# Watch deployment progress
kubectl get pods -n sample-apps -w

# Check application logs
kubectl logs -n sample-apps deployment/sample-web-app -f

# Check events
kubectl get events -n sample-apps --sort-by='.lastTimestamp'
```

## 🚨 Troubleshooting

### Common Issues:

1. **Docker Build Fails:**
   ```bash
   # Check Dockerfile syntax
   # Ensure all files exist
   ```

2. **ECR Push Fails:**
   ```bash
   # Check AWS credentials
   aws sts get-caller-identity
   
   # Check ECR permissions
   aws ecr describe-repositories --region ap-south-1
   ```

3. **EKS Deployment Fails:**
   ```bash
   # Check kubectl access
   kubectl get nodes
   
   # Check namespace exists
   kubectl get namespace sample-apps
   
   # Check resource limits
   kubectl describe deployment sample-web-app -n sample-apps
   ```

4. **Pipeline Hangs:**
   - Check Jenkins logs: `sudo journalctl -u jenkins -f`
   - Verify tools are in PATH for jenkins user
   - Check resource availability on Jenkins server

### Debug Commands:
```bash
# SSH to Jenkins server
ssh -i python.pem ubuntu@13.204.60.118

# Switch to jenkins user
sudo su - jenkins

# Test AWS access
aws sts get-caller-identity

# Test kubectl access
kubectl get nodes

# Test Docker access
docker version
```

## 🎉 Success Metrics

**Pipeline Success Indicators:**
- ✅ All stages complete without errors
- ✅ Docker image pushed to ECR
- ✅ Pods running in EKS cluster
- ✅ LoadBalancer URL accessible

**Application Health Checks:**
```bash
# Check pod health
kubectl get pods -n sample-apps

# Check service endpoints
kubectl get svc -n sample-apps

# Check ingress status
kubectl get ingress -n sample-apps
```

## 🔄 Next Steps

1. **Set up Webhooks** for automatic builds on Git push
2. **Add automated testing** stages to pipeline
3. **Implement blue-green deployments**
4. **Set up monitoring and alerting**
5. **Configure multiple environments** (dev/staging/prod)

## 📚 Additional Resources

- **Jenkins Documentation:** https://www.jenkins.io/doc/
- **Kubernetes Documentation:** https://kubernetes.io/docs/
- **AWS EKS User Guide:** https://docs.aws.amazon.com/eks/
- **Docker Best Practices:** https://docs.docker.com/develop/dev-best-practices/

---

**🎯 You're now ready to deploy applications to EKS with full CI/CD automation!**
