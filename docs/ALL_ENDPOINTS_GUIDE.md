# 🌐 Complete Server Endpoints Access Guide

## 🎯 All Available Endpoints

### 1. **🌍 Web Application Load Balancer (Production)**
```
🔗 URL: http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com
```
- **Status**: ✅ Available Now
- **Purpose**: Load-balanced web servers
- **Use Case**: Public web application access
- **Security**: Public, load-balanced across 2 web servers

### 2. **🖥️ Individual Web Servers (Direct Access)**
```
🔗 Web Server 1: http://13.232.85.18
🔗 Web Server 2: http://13.232.101.109
```
- **Status**: ✅ Available Now
- **Purpose**: Direct web server access
- **Use Case**: Testing, debugging individual servers

### 3. **⚙️ App Servers (Backend - Private Access)**
```
🔗 App Server 1: 10.0.10.176 (Private IP)
🔗 App Server 2: 10.0.11.29 (Private IP)
```
- **Status**: 🔒 Private subnet only
- **Purpose**: Backend application logic
- **Access**: Via SSH tunnel or from web servers

### 4. **☸️ EKS Application (Kubernetes)**
```
🔗 Local: http://localhost:8080 (port-forward)
🔗 Future: ALB endpoint (after controller installation)
```
- **Status**: ✅ Local access available
- **Purpose**: Containerized application

### 5. **🔧 Jenkins CI/CD Server**
```
🔗 Jenkins UI: http://13.204.60.118:8080
🔗 SSH Access: ssh -i python.pem ubuntu@13.204.60.118
```
- **Status**: ✅ Available Now
- **Purpose**: CI/CD pipeline management

---

## 🚀 Quick Access Commands

### Test All Public Endpoints:
```powershell
# Test Web ALB (Load Balancer)
curl http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com

# Test Individual Web Servers
curl http://13.232.85.18
curl http://13.232.101.109

# Test Jenkins
curl http://13.204.60.118:8080
```

### Access App Servers (Backend):
```powershell
# SSH to Web Server, then access app servers
ssh -i python.pem ec2-user@13.232.85.18

# From web server, access app servers:
curl http://10.0.10.176:8080  # App Server 1
curl http://10.0.11.29:8080   # App Server 2
```

### Access EKS Application:
```powershell
# Port forward for local access
kubectl port-forward service/sample-web-app-service 8080:80 -n sample-apps

# Then open: http://localhost:8080
```

---

## 🏗️ Architecture Overview

```
Internet
    ↓
🌍 Web ALB: my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com
    ↓
┌─────────────────────┬─────────────────────┐
│  🖥️ Web Server 1    │  🖥️ Web Server 2    │
│  13.232.85.18       │  13.232.101.109     │
│  (Public Subnet)    │  (Public Subnet)    │
└─────────────────────┴─────────────────────┘
    ↓                           ↓
┌─────────────────────┬─────────────────────┐
│  ⚙️ App Server 1     │  ⚙️ App Server 2     │
│  10.0.10.176        │  10.0.11.29         │
│  (Private Subnet)   │  (Private Subnet)   │
└─────────────────────┴─────────────────────┘

☸️ EKS Cluster (Private Subnets)
   └── 🚀 Sample Web App (3 pods)

🔧 Jenkins Server: 13.204.60.118:8080
```

---

## 🔍 Status Check Commands

### Check Web Application:
```powershell
# Test the main web application
Invoke-WebRequest http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com

# Check individual web servers
Invoke-WebRequest http://13.232.85.18
Invoke-WebRequest http://13.232.101.109
```

### Check Jenkins:
```powershell
# Check Jenkins status
Invoke-WebRequest http://13.204.60.118:8080
```

### Check EKS Application:
```powershell
# Check EKS app (via port forward)
kubectl port-forward service/sample-web-app-service 8080:80 -n sample-apps &
Start-Sleep 3
Invoke-WebRequest http://localhost:8080
```

---

## 🛡️ Security & Access Notes

### ✅ **Public Access (Available Now):**
- Web ALB: `http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com`
- Web Server 1: `http://13.232.85.18`
- Web Server 2: `http://13.232.101.109`
- Jenkins: `http://13.204.60.118:8080`

### 🔒 **Private Access (Secure Backend):**
- App Servers: Only accessible from web servers or via SSH tunnel
- EKS Nodes: Only accessible via kubectl or SSH tunnel

### 🌐 **For Internet Users:**
**Primary URL**: `http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com`

This is your **main production endpoint** that load-balances across both web servers.

---

## 📱 Quick Test Script

Run this to test all endpoints:
```powershell
.\scripts\test-all-endpoints.ps1
```
