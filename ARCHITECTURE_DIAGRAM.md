# 🏗️ Complete EKS Infrastructure Architecture Diagram

## 📐 **Full System Architecture**

```
                                    INTERNET
                                       │
                          ┌─────────────────────────┐
                          │    Route 53 (DNS)      │
                          │   your-app.com         │
                          └─────────────┬───────────┘
                                       │
                          ┌─────────────────────────┐
                          │     CloudFront CDN     │
                          │   (Optional - Global)   │
                          └─────────────┬───────────┘
                                       │
    ┌─────────────────────────────────────────────────────────────────┐
    │                        AWS VPC (10.0.0.0/16)                   │
    │                                                                 │
    │  ┌─────────────────────────────────────────────────────────┐   │
    │  │                 PUBLIC SUBNETS                          │   │
    │  │                                                         │   │
    │  │  ┌─────────────────┐    ┌─────────────────┐            │   │
    │  │  │  Web Server 1   │    │  Web Server 2   │            │   │
    │  │  │ 13.232.85.18    │    │13.232.101.109   │            │   │
    │  │  │  (AZ-1a)        │    │   (AZ-1b)       │            │   │
    │  │  │  Frontend       │    │  Frontend       │            │   │
    │  │  │  Nginx/Apache   │    │ Nginx/Apache    │            │   │
    │  │  └─────────────────┘    └─────────────────┘            │   │
    │  │           │                      │                     │   │
    │  │           └──────────┬───────────┘                     │   │
    │  │                      │                                 │   │
    │  │  ┌─────────────────────────────────────────────────┐   │   │
    │  │  │        Application Load Balancer (ALB)         │   │   │
    │  │  │my-eks-cluster-web-alb-1309538953.ap-south-1... │   │   │
    │  │  │          Ports: 80, 443 (HTTPS)                │   │   │
    │  │  └─────────────────────────────────────────────────┘   │   │
    │  │                                                         │   │
    │  │  ┌─────────────────┐                                   │   │
    │  │  │ Jenkins Server  │                                   │   │
    │  │  │ 13.204.60.118   │                                   │   │
    │  │  │   (CI/CD)       │                                   │   │
    │  │  │   Port: 8080    │                                   │   │
    │  │  └─────────────────┘                                   │   │
    │  │                                                         │   │
    │  │  ┌─────────────────┐    ┌─────────────────┐            │   │
    │  │  │  NAT Gateway    │    │  NAT Gateway    │            │   │
    │  │  │    (AZ-1a)      │    │    (AZ-1b)      │            │   │
    │  │  └─────────────────┘    └─────────────────┘            │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                              │                                 │
    │  ┌─────────────────────────────────────────────────────────┐   │
    │  │                 PRIVATE SUBNETS                         │   │
    │  │                                                         │   │
    │  │  ┌─────────────────┐    ┌─────────────────┐            │   │
    │  │  │  App Server 1   │    │  App Server 2   │            │   │
    │  │  │  10.0.10.176    │    │  10.0.11.29     │            │   │
    │  │  │    (AZ-1a)      │    │    (AZ-1b)      │            │   │
    │  │  │ Business Logic  │    │ Business Logic  │            │   │
    │  │  │ API Services    │    │ API Services    │            │   │
    │  │  └─────────────────┘    └─────────────────┘            │   │
    │  │                                                         │   │
    │  │  ┌─────────────────────────────────────────────────┐   │   │
    │  │  │             EKS CLUSTER                         │   │   │
    │  │  │        my-eks-cluster (v1.32)                   │   │   │
    │  │  │                                                 │   │   │
    │  │  │  ┌─────────────┐    ┌─────────────┐            │   │   │
    │  │  │  │EKS Worker 1 │    │EKS Worker 2 │            │   │   │
    │  │  │  │10.0.10.86   │    │10.0.11.158  │            │   │   │
    │  │  │  │  (AZ-1a)    │    │  (AZ-1b)    │            │   │   │
    │  │  │  └─────────────┘    └─────────────┘            │   │   │
    │  │  │                                                 │   │   │
    │  │  │  ┌─────────────────────────────────────────┐   │   │   │
    │  │  │  │         KUBERNETES PODS                 │   │   │   │
    │  │  │  │                                         │   │   │   │
    │  │  │  │  📦 sample-web-app (3 replicas)        │   │   │   │
    │  │  │  │  ├── Pod 1: sample-web-app-xxx-fk4fs   │   │   │   │
    │  │  │  │  ├── Pod 2: sample-web-app-xxx-k87mh   │   │   │   │
    │  │  │  │  └── Pod 3: sample-web-app-xxx-ntwdz   │   │   │   │
    │  │  │  │                                         │   │   │   │
    │  │  │  │  🔗 Services:                          │   │   │   │
    │  │  │  │  ├── ClusterIP: 172.20.62.48:80       │   │   │   │
    │  │  │  │  └── NodePort: 30080                   │   │   │   │
    │  │  │  │                                         │   │   │   │
    │  │  │  │  📋 ConfigMaps & Secrets               │   │   │   │
    │  │  │  │  └── web-app-content                   │   │   │   │
    │  │  │  └─────────────────────────────────────────┘   │   │   │
    │  │  └─────────────────────────────────────────────────┘   │   │
    │  └─────────────────────────────────────────────────────────┘   │
    │                                                                 │
    │  ┌─────────────────────────────────────────────────────────┐   │
    │  │                 AWS SERVICES                            │   │
    │  │                                                         │   │
    │  │  🗄️ S3 Bucket                   🔐 IAM Roles            │   │
    │  │  eks-terraform-state-xxx        - EKS Cluster Role     │   │
    │  │                                 - EKS NodeGroup Role   │   │
    │  │  📊 DynamoDB                    - Jenkins EC2 Role     │   │
    │  │  eks-terraform-locks            - ALB Controller Role  │   │
    │  │                                                         │   │
    │  │  🔑 Key Pair: python.pem                              │   │
    │  └─────────────────────────────────────────────────────────┘   │
    └─────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════
                            TRAFFIC FLOW
═══════════════════════════════════════════════════════════════════════

👥 CUSTOMERS
    ↓ HTTP/HTTPS
🌐 your-app.com (Route 53)
    ↓ DNS Resolution
🔄 Application Load Balancer (ALB)
    ↓ Load Balancing
🖥️ Web Servers (Public Subnet)
    ↓ Internal API Calls
⚙️ App Servers (Private Subnet)
    ↓ Data Processing
📊 Response to Customer

═══════════════════════════════════════════════════════════════════════
                             CI/CD FLOW
═══════════════════════════════════════════════════════════════════════

👨‍💻 DEVELOPER
    ↓ Git Push
🐙 GitHub Repository
    ↓ Webhook Trigger
🔧 Jenkins (13.204.60.118:8080)
    ↓ Build & Deploy
☸️ EKS Cluster
    ↓ Application Update
👥 Customers See New Version

═══════════════════════════════════════════════════════════════════════
                           ACCESS METHODS
═══════════════════════════════════════════════════════════════════════

🌐 CUSTOMER ACCESS:
   ✅ http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com
   ✅ https://your-app.com (future custom domain)

🔧 ADMIN ACCESS:
   ✅ Jenkins: http://13.204.60.118:8080
   ✅ SSH to Jenkins: ssh -i python.pem ubuntu@13.204.60.118
   ✅ kubectl: EKS cluster management

☸️ EKS APPLICATION:
   ✅ Local: http://localhost:8080 (port-forward)
   ✅ Internal: sample-web-app-service.sample-apps.svc.cluster.local

🔒 PRIVATE ACCESS (Admin Only):
   ⚙️ App Servers: 10.0.10.176, 10.0.11.29 (via SSH tunnel)
   🖥️ Web Servers: ssh -i python.pem ec2-user@13.232.85.18

═══════════════════════════════════════════════════════════════════════
                           SECURITY LAYERS
═══════════════════════════════════════════════════════════════════════

🛡️ NETWORK SECURITY:
   ├── Internet Gateway (Public traffic entry)
   ├── NAT Gateway (Private subnet internet access)
   ├── Security Groups (Firewall rules)
   ├── NACLs (Network Access Control Lists)
   └── VPC Isolation (10.0.0.0/16)

🔐 ACCESS CONTROL:
   ├── IAM Roles (AWS service permissions)
   ├── Key Pairs (SSH access)
   ├── EKS RBAC (Kubernetes permissions)
   └── Service Accounts (Pod-level permissions)

📊 MONITORING & LOGGING:
   ├── CloudWatch (AWS monitoring)
   ├── ALB Access Logs
   ├── VPC Flow Logs
   └── EKS Control Plane Logs

═══════════════════════════════════════════════════════════════════════
```

## 📱 **Component Details**

### **Public Components (Customer-Facing)**
- **ALB**: `my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com`
- **Web Server 1**: `13.232.85.18` (AZ: ap-south-1a)
- **Web Server 2**: `13.232.101.109` (AZ: ap-south-1b)

### **Private Components (Secure Backend)**
- **App Server 1**: `10.0.10.176` (AZ: ap-south-1a)
- **App Server 2**: `10.0.11.29` (AZ: ap-south-1b)
- **EKS Worker 1**: `10.0.10.86` (AZ: ap-south-1a)
- **EKS Worker 2**: `10.0.11.158` (AZ: ap-south-1b)

### **Management Components**
- **Jenkins**: `13.204.60.118:8080`
- **EKS Control Plane**: `C39336F8949EDA606469C5B8506DED79.gr7.ap-south-1.eks.amazonaws.com`

### **Storage & State**
- **S3 Bucket**: `eks-cluster-terraform-state-413eebae`
- **DynamoDB**: `eks-cluster-terraform-locks`

## 🎯 **High Availability & Scaling**
- **Multi-AZ Deployment**: Resources across 2 availability zones
- **Load Balancing**: ALB distributes traffic across web servers
- **Auto Scaling**: EKS nodes can scale based on demand
- **Redundancy**: 2 web servers + 2 app servers + 3 EKS pods
