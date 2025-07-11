# Jenkins Pipeline Setup Guide

This guide covers setting up the Jenkins pipeline job for your EKS deployment.

## Prerequisites

Before setting up the pipeline, ensure:

1. **Jenkins Server is Running**: Use the scripts in `scripts/` to verify Jenkins is accessible
2. **EKS Cluster is Deployed**: Your EKS cluster should be running and accessible
3. **Required Tools on Jenkins**: AWS CLI, kubectl, Docker are installed on the Jenkins server

## Jenkins Pipeline Job Configuration

### 1. Create New Pipeline Job

1. **Access Jenkins**: Open Jenkins in your browser (usually `http://your-jenkins-server:8080`)
2. **New Item**: Click "New Item" on the Jenkins dashboard
3. **Job Name**: Enter `eks-sample-web-app-pipeline`
4. **Job Type**: Select "Pipeline"
5. **Click OK**

### 2. Configure Pipeline Job

#### General Settings
- **Description**: `Deploy sample web app to EKS cluster with ECR`
- **GitHub Project**: Check this box if you want to link to your GitHub repo
- **Project URL**: `https://github.com/yourusername/yourrepo` (optional)

#### Build Triggers
Configure based on your needs:
- **Poll SCM**: Use `H/5 * * * *` to check for changes every 5 minutes
- **GitHub Hook**: For webhook-based triggers (requires GitHub webhook setup)
- **Build Periodically**: Use `H 2 * * *` for nightly builds

#### Pipeline Definition
**IMPORTANT**: Use these exact settings:

1. **Definition**: Select "Pipeline script from SCM"
2. **SCM**: Select "Git"
3. **Repository URL**: Your GitHub repository URL
4. **Credentials**: Add your GitHub credentials if private repo
5. **Branch**: `*/main` (or your default branch)
6. **Script Path**: `k8s-apps/sample-web-app/Jenkinsfile`

> **⚠️ Critical**: The Script Path MUST be `k8s-apps/sample-web-app/Jenkinsfile` - this is where your Jenkinsfile is located after the project restructuring.

### 3. Required Jenkins Credentials

Set up these credentials in Jenkins (Manage Jenkins → Credentials):

#### AWS Credentials
- **Kind**: AWS Credentials
- **ID**: `aws-credentials`
- **Access Key ID**: Your AWS access key
- **Secret Access Key**: Your AWS secret key

#### GitHub Credentials (if private repo)
- **Kind**: Username with password
- **ID**: `github-credentials`
- **Username**: Your GitHub username
- **Password**: Your GitHub personal access token

### 4. Required Jenkins Plugins

Ensure these plugins are installed:

#### Essential Plugins
- **Pipeline**: Core pipeline functionality
- **Git**: Git SCM support
- **AWS Steps**: AWS CLI integration
- **Docker Pipeline**: Docker build/push support
- **Kubernetes**: Kubernetes deployment support

#### Optional but Recommended
- **Blue Ocean**: Better pipeline visualization
- **Pipeline Stage View**: Enhanced stage visualization
- **Timestamper**: Timestamps in console output

### 5. Jenkins Node Configuration

#### On Jenkins Master/Agent
Ensure these tools are available:

```bash
# AWS CLI v2
aws --version

# kubectl
kubectl version --client

# Docker
docker --version

# Git
git --version
```

#### Environment Variables
Set these in Jenkins system configuration if needed:
- `AWS_DEFAULT_REGION`: `ap-south-1`
- `PATH`: Include Docker and kubectl paths

## Pipeline Environment Variables

The pipeline uses these environment variables (configured in Jenkinsfile):

```groovy
environment {
    AWS_REGION = 'ap-south-1'
    EKS_CLUSTER_NAME = 'my-eks-cluster'
    APP_NAME = 'sample-web-app'
    NAMESPACE = 'sample-apps'
    AWS_ACCOUNT_ID = '897722681721'
    ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    IMAGE_REPO = "${ECR_REGISTRY}/${APP_NAME}"
    IMAGE_TAG = "${BUILD_NUMBER}"
    K8S_MANIFESTS_PATH = 'k8s-apps/sample-web-app'
}
```

## Pipeline Stages Overview

Your pipeline includes these stages:

1. **Checkout**: Get source code and set git commit info
2. **Environment Setup**: Verify tools and configure AWS CLI
3. **Create ECR Repository**: Ensure ECR repo exists
4. **Build Docker Image**: Build and tag Docker image
5. **Push to ECR**: Push image to ECR registry
6. **Update Kubernetes Manifests**: Update deployment-ecr.yaml with new image
7. **Configure EKS Access**: Update kubeconfig for EKS
8. **Deploy to EKS**: Apply Kubernetes manifests
9. **Wait for Deployment**: Wait for rollout to complete
10. **Verify Deployment**: Check deployment status
11. **Cleanup**: Remove local Docker images

## Testing the Pipeline

### 1. First Run
1. **Manual Trigger**: Click "Build Now" for the first test
2. **Monitor Progress**: Watch the pipeline stages in real-time
3. **Check Logs**: Review console output for any issues

### 2. Verify Deployment
```bash
# Check the deployment
kubectl get all -n sample-apps

# Check the application
kubectl get ingress -n sample-apps
```

### 3. Test Web App
```bash
# Get the LoadBalancer URL
kubectl get ingress -n sample-apps -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}'

# Test the app
curl -I http://your-loadbalancer-url
```

## Troubleshooting

### Common Issues

#### 1. Script Path Not Found
**Error**: `Jenkinsfile not found at k8s-apps/sample-web-app/Jenkinsfile`
**Solution**: Verify the Script Path is exactly `k8s-apps/sample-web-app/Jenkinsfile`

#### 2. AWS Credentials Issues
**Error**: `Unable to locate credentials`
**Solution**: 
- Verify AWS credentials are configured in Jenkins
- Check IAM permissions for EKS and ECR access

#### 3. kubectl Access Issues
**Error**: `kubectl: command not found` or `cluster not found`
**Solution**:
- Ensure kubectl is installed on Jenkins server
- Verify EKS cluster is accessible
- Check AWS IAM permissions

#### 4. Docker Build Issues
**Error**: `Docker daemon not accessible`
**Solution**:
- Ensure Docker is running on Jenkins server
- Add Jenkins user to docker group: `sudo usermod -aG docker jenkins`
- Restart Jenkins service

### Debug Commands

Use these scripts to debug Jenkins setup:

```powershell
# Check Jenkins status
.\scripts\check-jenkins-status.ps1

# Verify Jenkins installation
.\scripts\verify-jenkins-setup.ps1

# Test Jenkins pipeline
.\scripts\test-jenkins-pipeline.ps1
```

## Pipeline Customization

### Modify Environment Variables
Edit the `environment` section in your Jenkinsfile:

```groovy
environment {
    AWS_REGION = 'your-region'
    EKS_CLUSTER_NAME = 'your-cluster-name'
    AWS_ACCOUNT_ID = 'your-account-id'
    // ... other variables
}
```

### Add Notification Stages
Add Slack/email notifications to the `post` section:

```groovy
post {
    success {
        // Add your success notifications here
    }
    failure {
        // Add your failure notifications here
    }
}
```

### Customize Deployment Strategy
Modify the deployment stage to use different strategies:
- Blue/Green deployment
- Rolling updates with specific parameters
- Canary deployments

## Security Best Practices

1. **Use IAM Roles**: Prefer IAM roles over access keys where possible
2. **Least Privilege**: Grant minimum required permissions
3. **Secure Credentials**: Store all credentials securely in Jenkins
4. **Network Security**: Ensure secure communication between Jenkins and EKS
5. **Image Scanning**: Consider adding container image scanning stages

## Next Steps

1. **Set up the pipeline job** using the configuration above
2. **Run the pipeline** and verify successful deployment
3. **Set up webhooks** for automatic builds on code changes
4. **Configure notifications** for build status
5. **Add automated testing** stages before deployment

## Resources

- [Jenkins Pipeline Documentation](https://jenkins.io/doc/book/pipeline/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [ECR Documentation](https://docs.aws.amazon.com/ecr/)
