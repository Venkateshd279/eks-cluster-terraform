# 🌐 EKS Application Endpoint Access Guide

## Current Status Summary

Your EKS cluster is set up with **production-grade security** using private subnets for worker nodes. This is the **correct and secure** approach, but it affects how you access your application externally.

## Available Endpoint Options

### ✅ **Option 1: Local Access (Available Now)**
```
URL: http://localhost:8080
Command: kubectl port-forward service/sample-web-app-service 8080:80 -n sample-apps
```
- **Status**: ✅ Working
- **Use Case**: Development, testing, troubleshooting
- **Security**: High (local only)

### ⚠️ **Option 2: NodePort Service (Created but Limited)**
```
Service: sample-web-app-nodeport
Port: 30080
Status: Worker nodes are in private subnets (no public IPs)
```
- **Status**: ⚠️ Created but not externally accessible
- **Reason**: Worker nodes are in private subnets (security best practice)

### 🚧 **Option 3: Application Load Balancer (Recommended for Production)**
```
Service: AWS ALB via Ingress
Status: Requires AWS Load Balancer Controller
```
- **Status**: 🚧 Needs ALB Controller installation
- **Benefits**: Production-ready, scalable, secure
- **URL Format**: http://[ALB-HOSTNAME]

## 🎯 Recommended Solution: Install AWS Load Balancer Controller

This is the **production-standard** way to expose applications in EKS:

### Quick Setup:
```powershell
# Run this script to enable external web access
.\scripts\setup-external-access.ps1
```

### What it does:
1. ✅ Creates IAM policy for ALB Controller
2. ✅ Creates IAM service account with proper permissions  
3. ✅ Installs AWS Load Balancer Controller via Helm
4. ✅ Configures your existing ingress to get external URL
5. ✅ Provides public HTTPS endpoint

### Expected Result:
```
🌐 External URL: http://[random-alb-hostname].ap-south-1.elb.amazonaws.com
```

## 🔄 Alternative Quick Access Methods

### Method A: Port Forward (Immediate)
```powershell
kubectl port-forward service/sample-web-app-service 8080:80 -n sample-apps
# Then open: http://localhost:8080
```

### Method B: SSH Tunnel via Jenkins (Advanced)
```powershell
# SSH to Jenkins server (which has public IP)
$jenkinsIP = terraform output -raw jenkins_public_ip
ssh -L 8080:sample-web-app-service.sample-apps.svc.cluster.local:80 ubuntu@$jenkinsIP

# Then access: http://localhost:8080
```

## 🏗️ Current Infrastructure Summary

```
Internet → Public Subnets → NAT Gateway → Private Subnets (EKS Nodes)
                          ↓
                    Jenkins Server (Public IP: Available)
                          ↓
                    EKS Cluster (Private: Secure)
```

## 📊 Service Status Check

```bash
# Check all services
kubectl get services -n sample-apps

# Current services:
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)
sample-web-app-service    ClusterIP   172.20.62.48    <none>        80/TCP
sample-web-app-nodeport   NodePort    172.20.227.34   <none>        80:30080/TCP

# Check ingress
kubectl get ingress -n sample-apps
NAME                     CLASS    HOSTS   ADDRESS   PORTS   AGE
sample-web-app-ingress   <none>   *                 80      XX min
```

## 🎯 Next Steps

### For Production External Access:
1. **Run**: `.\scripts\setup-external-access.ps1`
2. **Wait**: 2-3 minutes for ALB provisioning
3. **Access**: Your app at the provided ALB URL

### For Development/Testing:
1. **Run**: `kubectl port-forward service/sample-web-app-service 8080:80 -n sample-apps`
2. **Access**: http://localhost:8080

## 🛡️ Security Notes

✅ **Your current setup is secure because:**
- Worker nodes are in private subnets
- No direct internet access to worker nodes  
- Traffic flows through controlled load balancer
- Jenkins server acts as secure bastion host

❌ **Avoid exposing NodePort directly** (would require opening worker node security groups)

---

## 🚀 Quick Test Command

```powershell
# Test current setup
.\scripts\test-locally.ps1
```

Your infrastructure is set up correctly for production! The ALB Controller installation will give you the secure external endpoint you need.
