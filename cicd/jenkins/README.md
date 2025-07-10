# Jenkins CI/CD Setup for EKS Deployment

This guide will help you set up Jenkins for automated deployment to your EKS cluster.

## Prerequisites ✅

1. **✅ Jenkins Server**: Ubuntu 22.04 instance running Jenkins (COMPLETE)
2. **✅ Docker**: Installed on Jenkins server (COMPLETE)
3. **✅ AWS CLI**: Configured with IAM role authentication (COMPLETE)
4. **✅ kubectl**: Installed and configured for EKS access (COMPLETE)
5. **🔄 Required Plugins**: Need to be installed in Jenkins UI (NEXT STEP)

## Required Jenkins Plugins

Install these plugins in Jenkins:

```
• AWS Credentials Plugin
• Docker Pipeline Plugin
• Kubernetes Plugin
• Pipeline Plugin
• Git Plugin
• Blue Ocean (optional, for better UI)
```

## Setup Steps

### 1. AWS Authentication - ✅ COMPLETE

**✅ Your Jenkins server is already configured and working!**

Your Jenkins server is using an IAM role (`my-eks-cluster-jenkins-role`) for AWS authentication. This provides secure access to:
- Amazon EKS cluster
- Amazon ECR (Docker registry)
- Other AWS services

**No additional AWS credentials configuration is needed in Jenkins UI.**

**Verification:** AWS CLI commands work successfully from Jenkins server.

### 2. Configure Kubeconfig (Optional)

If you want to store kubeconfig as a file credential:

1. Go to **Manage Jenkins** → **Manage Credentials**
2. Add **Secret file**:
   - Kind: `Secret file`
   - ID: `kubeconfig-file`
   - File: Upload your kubeconfig file

### 3. Create Jenkins Pipeline Job

1. **New Item** → **Pipeline**
2. **Pipeline Definition**: Pipeline script from SCM
3. **SCM**: Git
4. **Repository URL**: Your Git repository URL
5. **Script Path**: `cicd/jenkins/Jenkinsfile`

### 4. Configure Webhook (Optional)

For automatic builds on code push:

1. In your Git repository settings, add webhook:
   - URL: `http://your-jenkins-server/github-webhook/`
   - Content type: `application/json`
   - Events: `push`, `pull request`

## Environment Variables

Configure these in your Jenkins job or globally:

```bash
# AWS Configuration
AWS_REGION=ap-south-1
EKS_CLUSTER_NAME=my-eks-cluster

# Application Configuration
APP_NAME=sample-web-app
NAMESPACE=sample-apps

# Docker Registry
ECR_REGISTRY=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
```

## Jenkins Server Setup Script

If setting up Jenkins on EC2, you can use this user data script:

```bash
#!/bin/bash
# Jenkins setup script for Amazon Linux 2

# Update system
yum update -y

# Install Java 11
amazon-linux-extras install java-openjdk11 -y

# Install Jenkins
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins -y

# Install Docker
yum install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker jenkins

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Start and enable Jenkins
systemctl start jenkins
systemctl enable jenkins

# Print initial admin password
echo "Jenkins initial admin password:"
cat /var/lib/jenkins/secrets/initialAdminPassword
```

## Pipeline Features

### What the Pipeline Does:

1. **Environment Setup**: Configures AWS CLI and kubectl
2. **Build**: Creates Docker image (if Dockerfile exists)
3. **Push**: Pushes image to ECR
4. **Deploy**: Applies Kubernetes manifests
5. **Verify**: Checks deployment status
6. **Cleanup**: Removes local Docker images

### Pipeline Stages:

1. **Checkout**: Gets source code from Git
2. **Environment Setup**: Installs/configures tools
3. **Build Docker Image**: Builds custom image (optional)
4. **Push to ECR**: Pushes to AWS Container Registry
5. **Update Manifests**: Updates deployment files
6. **Configure EKS**: Sets up kubectl access
7. **Deploy to EKS**: Applies Kubernetes resources
8. **Wait for Deployment**: Waits for pods to be ready
9. **Verify Deployment**: Checks application status

## Security Best Practices

### 1. IAM Role for Jenkins (Recommended)

Instead of AWS credentials, use IAM role:

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ecr:GetAuthorizationToken",
                "ecr:BatchCheckLayerAvailability",
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:CreateRepository"
            ],
            "Resource": "*"
        }
    ]
}
```

### 2. Kubernetes RBAC

Create a service account for Jenkins:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins-deployer
  namespace: sample-apps
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: jenkins-deployer
  namespace: sample-apps
rules:
- apiGroups: ["", "apps", "networking.k8s.io"]
  resources: ["*"]
  verbs: ["*"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: jenkins-deployer
  namespace: sample-apps
subjects:
- kind: ServiceAccount
  name: jenkins-deployer
  namespace: sample-apps
roleRef:
  kind: Role
  name: jenkins-deployer
  apiGroup: rbac.authorization.k8s.io
```

## Troubleshooting

### Common Issues:

1. **kubectl not found**: Install kubectl on Jenkins server
2. **AWS permissions**: Check IAM permissions
3. **Docker permission denied**: Add jenkins user to docker group
4. **EKS cluster not accessible**: Check security groups and RBAC

### Debug Commands:

```bash
# Check Jenkins logs
sudo journalctl -u jenkins -f

# Check kubectl access
kubectl cluster-info
kubectl get nodes

# Check AWS CLI
aws sts get-caller-identity
aws eks describe-cluster --name my-eks-cluster --region ap-south-1
```

## Usage

1. **Push code** to your Git repository
2. **Jenkins automatically triggers** the pipeline (if webhook configured)
3. **Monitor progress** in Jenkins Blue Ocean or console output
4. **Access application** via Load Balancer URL

## Next Steps

- Set up **monitoring and alerting**
- Implement **blue-green deployments**
- Add **automated testing** stages
- Configure **multi-environment deployments** (dev/staging/prod)
- Set up **backup and rollback** strategies
