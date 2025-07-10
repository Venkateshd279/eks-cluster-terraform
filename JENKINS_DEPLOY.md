# Quick Jenkins Deployment Guide

## 🚀 Deploy Jenkins Server for CI/CD

Your Jenkins server configuration is now ready! Here's how to deploy it:

### 1. **Deploy Jenkins Server**

```bash
# Deploy only the Jenkins server resources
terraform apply -auto-approve \
  -target=aws_security_group.jenkins_sg \
  -target=aws_iam_role.jenkins_role \
  -target=aws_iam_policy.jenkins_policy \
  -target=aws_iam_role_policy_attachment.jenkins_policy_attachment \
  -target=aws_iam_instance_profile.jenkins_profile \
  -target=aws_instance.jenkins_server \
  -target=aws_eip.jenkins_eip
```

Or deploy everything at once:
```bash
terraform apply
```

### 2. **Get Jenkins Access Information**

After deployment:
```bash
# Get Jenkins URL
terraform output jenkins_url

# Get SSH command
terraform output jenkins_ssh_command

# Get public IP
terraform output jenkins_public_ip
```

### 3. **Access Jenkins**

1. **Open Jenkins URL** in your browser
2. **Get initial password**:
   ```bash
   # SSH to Jenkins server
   ssh -i python.pem ec2-user@<jenkins-ip>
   
   # Get initial admin password
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
3. **Complete setup wizard**
4. **Install recommended plugins**

### 4. **Configure Jenkins for EKS**

1. **Go to Manage Jenkins → Manage Credentials**
2. **Add AWS Credentials**:
   - Kind: `AWS Credentials`
   - ID: `aws-credentials`
   - Access Key: Your AWS Access Key
   - Secret Key: Your AWS Secret Key

3. **Create Pipeline Job**:
   - New Item → Pipeline
   - Name: `sample-web-app-deploy`
   - Pipeline script from SCM
   - Repository URL: Your Git repo
   - Script Path: `cicd/jenkins/Jenkinsfile`

### 5. **Test Application Deployment**

Before setting up CI/CD, test manual deployment:
```bash
cd k8s-apps/sample-web-app
powershell -ExecutionPolicy Bypass -File deploy.ps1
```

## 🛡️ Security Features

✅ **IAM Role**: Jenkins uses IAM role (no hardcoded AWS keys)  
✅ **Security Groups**: Only necessary ports open  
✅ **EBS Encryption**: Encrypted storage  
✅ **EKS Access**: Proper permissions for cluster access  

## 📊 What Jenkins Will Do

1. **Pull code** from Git repository
2. **Build Docker image** (if Dockerfile exists)
3. **Push to ECR** (AWS Container Registry)
4. **Deploy to EKS** using kubectl
5. **Verify deployment** health
6. **Provide access URLs**

## 🔧 Estimated Costs

- **Jenkins Server**: ~$25/month (t3.medium)
- **EBS Storage**: ~$3/month (30GB)
- **Elastic IP**: Free while attached

## 🚀 Ready to Deploy?

Run this command to deploy your Jenkins server:

```bash
terraform apply
```

Then follow the access instructions above to set up your CI/CD pipeline!

## Next Steps

1. **Deploy Jenkins** using the command above
2. **Configure credentials** in Jenkins
3. **Create your first pipeline**
4. **Push code and watch automatic deployment**

Your EKS cluster + Jenkins CI/CD setup will be complete! 🎉
