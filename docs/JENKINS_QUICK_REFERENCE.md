# Jenkins Pipeline Quick Reference

## 🚀 Quick Setup Checklist

### ✅ Before You Start
- [ ] Jenkins server is running and accessible
- [ ] EKS cluster is deployed and accessible
- [ ] AWS CLI, kubectl, Docker installed on Jenkins server
- [ ] Required Jenkins plugins installed

### ✅ Create Pipeline Job
1. **New Item** → Enter name: `eks-sample-web-app-pipeline`
2. **Select**: Pipeline
3. **Definition**: Pipeline script from SCM
4. **SCM**: Git
5. **Repository URL**: Your GitHub repo URL
6. **Branch**: `*/main`
7. **Script Path**: `k8s-apps/sample-web-app/Jenkinsfile` ⚠️ **CRITICAL**

### ✅ Required Credentials
- **AWS Credentials** (ID: `aws-credentials`)
- **GitHub Credentials** (ID: `github-credentials`) [if private repo]

### ✅ Environment Variables (in Jenkinsfile)
```groovy
AWS_REGION = 'ap-south-1'
EKS_CLUSTER_NAME = 'my-eks-cluster'
AWS_ACCOUNT_ID = '897722681721'
APP_NAME = 'sample-web-app'
NAMESPACE = 'sample-apps'
```

## 🔧 Pipeline Stages
1. **Checkout** → Get code + git info
2. **Environment Setup** → Verify tools
3. **Create ECR Repository** → Ensure ECR exists
4. **Build Docker Image** → Build + tag image
5. **Push to ECR** → Push to registry
6. **Update K8s Manifests** → Update deployment-ecr.yaml
7. **Configure EKS Access** → Update kubeconfig
8. **Deploy to EKS** → Apply manifests
9. **Wait for Deployment** → Wait for rollout
10. **Verify Deployment** → Check status
11. **Cleanup** → Remove local images

## 🛠️ Required Tools on Jenkins Server
- **AWS CLI v2**: `aws --version`
- **kubectl**: `kubectl version --client`
- **Docker**: `docker --version`
- **Git**: `git --version`

## 📦 Required Jenkins Plugins
- **Pipeline** (workflow-aggregator)
- **Git** (git)
- **AWS Steps** (pipeline-aws)
- **Docker Pipeline** (docker-workflow)
- **Kubernetes** (kubernetes)

## 🔍 Validation Commands
```powershell
# Validate complete setup
.\scripts\validate-jenkins-pipeline.ps1

# Check Jenkins status
.\scripts\check-jenkins-status.ps1

# Test Jenkins installation
.\scripts\verify-jenkins-setup.ps1
```

## 🚨 Common Issues

### Script Path Error
**Error**: `Jenkinsfile not found`
**Fix**: Script Path = `k8s-apps/sample-web-app/Jenkinsfile`

### AWS Credentials
**Error**: `Unable to locate credentials`
**Fix**: Add AWS credentials in Jenkins → Manage Jenkins → Credentials

### kubectl Access
**Error**: `cluster not found`
**Fix**: Verify EKS cluster exists and IAM permissions

### Docker Permission
**Error**: `Docker daemon not accessible`
**Fix**: Add jenkins user to docker group: `sudo usermod -aG docker jenkins`

## 🎯 Pipeline URLs
- **Jenkins Dashboard**: `http://your-jenkins-server:8080`
- **Pipeline Job**: `http://your-jenkins-server:8080/job/eks-sample-web-app-pipeline`
- **Blue Ocean**: `http://your-jenkins-server:8080/blue`

## 📱 After Deployment
```bash
# Check deployment
kubectl get all -n sample-apps

# Get app URL
kubectl get ingress -n sample-apps

# Test app
curl -I http://your-app-url
```

## 🔄 Pipeline Flow
```
GitHub → Jenkins → ECR → EKS → LoadBalancer → 🌐 Live App
```

## 📞 Support
- **Setup Guide**: `docs/JENKINS_PIPELINE_SETUP.md`
- **Validation**: `scripts/validate-jenkins-pipeline.ps1`
- **Troubleshooting**: Check Jenkins console logs
