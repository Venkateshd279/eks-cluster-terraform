# CI/CD Deployment Guide for EKS Applications

## 🚀 Complete CI/CD Setup with Jenkins

This guide will walk you through setting up a complete CI/CD pipeline for deploying applications to your EKS cluster using Jenkins.

## 📋 What We've Created

### 1. **Jenkins Infrastructure**
- **jenkins-server.tf**: Terraform configuration for Jenkins EC2 instance
- **jenkins-setup.sh**: Automated setup script for Jenkins server
- **Jenkinsfile**: Complete pipeline for building and deploying applications

### 2. **Application Structure**
```
k8s-apps/sample-web-app/
├── Dockerfile              # Custom Docker image build
├── nginx.conf              # Optimized Nginx configuration  
├── index.html              # Sample application
├── namespace.yaml          # Kubernetes namespace
├── configmap.yaml          # Application configuration
├── deployment.yaml         # Kubernetes deployment
├── service.yaml            # Kubernetes service
├── ingress.yaml            # AWS Load Balancer ingress
└── deploy.ps1             # Manual deployment script
```

### 3. **CI/CD Pipeline Features**
- ✅ **Automated builds** on Git push
- ✅ **Docker image creation** and push to ECR
- ✅ **Kubernetes deployment** to EKS
- ✅ **Health checks** and verification
- ✅ **Rollback capabilities**
- ✅ **Security scanning** (extensible)

## 🔧 Setup Instructions

### Step 1: Deploy Jenkins Server

Add the Jenkins server to your existing infrastructure:

```bash
# Copy the Jenkins configuration to your main Terraform
cp cicd/jenkins/jenkins-server.tf .

# Plan and apply the Jenkins infrastructure
terraform plan
terraform apply
```

**Note**: The Jenkins server will be created in your existing VPC with:
- **Instance Type**: t3.medium (suitable for CI/CD workloads)
- **Public IP**: With Elastic IP for stability
- **Security Groups**: Ports 8080 (Jenkins), 22 (SSH), 443 (HTTPS)
- **IAM Permissions**: Full access to EKS and ECR

### Step 2: Access Jenkins

After deployment, get the Jenkins URL:

```bash
terraform output jenkins_url
terraform output jenkins_ssh_command
```

**Initial Setup**:
1. Open the Jenkins URL in your browser
2. Get the initial admin password:
   ```bash
   ssh -i python.pem ec2-user@<jenkins-ip>
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. Complete the setup wizard
4. Install recommended plugins

### Step 3: Configure Jenkins Credentials

In Jenkins, go to **Manage Jenkins** → **Manage Credentials**:

#### AWS Credentials:
- **Kind**: AWS Credentials
- **ID**: `aws-credentials`
- **Access Key**: Your AWS Access Key ID
- **Secret Key**: Your AWS Secret Access Key

#### Git Credentials (if private repo):
- **Kind**: Username with password
- **ID**: `git-credentials`
- **Username**: Your Git username
- **Password**: Your Git token/password

### Step 4: Create Pipeline Job

1. **New Item** → **Pipeline**
2. **Name**: `sample-web-app-deploy`
3. **Pipeline Definition**: Pipeline script from SCM
4. **SCM**: Git
5. **Repository URL**: Your repository URL
6. **Script Path**: `cicd/jenkins/Jenkinsfile`

### Step 5: Run Your First Build

1. Click **Build Now**
2. Monitor the pipeline in **Blue Ocean** view
3. Check the console output for detailed logs

## 🔄 CI/CD Workflow

### Pipeline Stages:

1. **Checkout** 📥
   - Pulls latest code from Git repository
   - Verifies repository structure

2. **Environment Setup** 🔧
   - Installs/updates kubectl, AWS CLI
   - Configures tools and permissions

3. **Build Docker Image** 🐳
   - Builds custom Docker image from Dockerfile
   - Tags image with build number

4. **Push to ECR** 📤
   - Authenticates with AWS ECR
   - Creates repository if needed
   - Pushes tagged image

5. **Update Manifests** 📝
   - Updates Kubernetes manifests with new image tag
   - Injects build information

6. **Configure EKS** ☸️
   - Sets up kubectl access to EKS cluster
   - Verifies cluster connectivity

7. **Deploy to EKS** 🚀
   - Applies all Kubernetes manifests
   - Creates namespace, configmap, deployment, service, ingress

8. **Verify Deployment** ✅
   - Waits for pods to be ready
   - Runs health checks
   - Provides access URLs

### Automatic Triggers:

- **Git Push**: Automatically triggers build on code push
- **Pull Request**: Can be configured for PR validation
- **Scheduled**: Can run on schedule (e.g., nightly builds)

## 🛡️ Security Best Practices

### 1. **IAM Roles** (Recommended)
Instead of AWS credentials, use IAM roles:

```bash
# Attach IAM role to Jenkins EC2 instance
# No need to store AWS keys in Jenkins
```

### 2. **Kubernetes RBAC**
Create service account for Jenkins:

```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-deployer
  namespace: sample-apps
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: jenkins-deployer
rules:
- apiGroups: ["", "apps", "networking.k8s.io"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins-deployer
subjects:
- kind: ServiceAccount
  name: jenkins-deployer
  namespace: sample-apps
roleRef:
  kind: ClusterRole
  name: jenkins-deployer
  apiGroup: rbac.authorization.k8s.io
EOF
```

### 3. **Secrets Management**
- Store sensitive data in Kubernetes secrets
- Use AWS Secrets Manager for production
- Never commit credentials to Git

## 📊 Monitoring and Observability

### Jenkins Monitoring:
- **Build Metrics**: Success/failure rates
- **Build Duration**: Performance tracking
- **Resource Usage**: CPU, memory, disk

### Application Monitoring:
- **Pod Health**: Kubernetes health checks
- **Application Logs**: Centralized logging
- **Metrics**: Custom application metrics

## 🔧 Advanced Features

### 1. **Multi-Environment Deployment**

```groovy
// Add environment selection to Jenkinsfile
parameters {
    choice(
        name: 'ENVIRONMENT',
        choices: ['dev', 'staging', 'production'],
        description: 'Environment to deploy to'
    )
}
```

### 2. **Blue-Green Deployment**

```yaml
# Create two versions of deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-web-app-blue
# ... and sample-web-app-green
```

### 3. **Rollback Strategy**

```groovy
// Add rollback stage
stage('Rollback on Failure') {
    when { failure() }
    steps {
        script {
            sh "kubectl rollout undo deployment/sample-web-app -n sample-apps"
        }
    }
}
```

## 🚨 Troubleshooting

### Common Issues:

1. **Build Fails at Docker Step**
   ```bash
   # Check Docker daemon on Jenkins
   sudo systemctl status docker
   sudo usermod -a -G docker jenkins
   ```

2. **kubectl Permission Denied**
   ```bash
   # Check EKS cluster access
   aws eks describe-cluster --name my-eks-cluster --region ap-south-1
   aws eks update-kubeconfig --name my-eks-cluster --region ap-south-1
   ```

3. **ECR Push Failed**
   ```bash
   # Check ECR permissions
   aws ecr get-login-password --region ap-south-1
   ```

### Debug Commands:

```bash
# Jenkins logs
sudo journalctl -u jenkins -f

# Check build workspace
ls -la /var/lib/jenkins/workspace/

# Test kubectl access
kubectl cluster-info
kubectl get nodes
```

## 📚 Next Steps

1. **Set up monitoring** with Prometheus and Grafana
2. **Implement automated testing** (unit, integration, security)
3. **Add notification systems** (Slack, email, Teams)
4. **Configure backup strategies** for Jenkins and applications
5. **Implement GitOps** with ArgoCD or Flux

## 🎯 Quick Start Commands

```bash
# Deploy Jenkins infrastructure
terraform apply -target=aws_instance.jenkins_server

# Get Jenkins URL
terraform output jenkins_url

# SSH to Jenkins server
terraform output jenkins_ssh_command

# Check initial password
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Test pipeline manually
cd k8s-apps/sample-web-app
./deploy.ps1
```

Your CI/CD pipeline is now ready for production use! 🚀
