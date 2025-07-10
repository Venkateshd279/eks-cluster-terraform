# 🚀 Sample Web Application for EKS

This directory contains a sample web application designed to demonstrate EKS deployment capabilities with a **new improved workflow** using separate HTML files.

## 📁 File Structure

```
sample-web-app/
├── index.html                 # 📄 Main HTML content (edit this!)
├── configmap.yaml             # ☸️ Generated Kubernetes ConfigMap
├── configmap-template.yaml    # 📋 Template for ConfigMap
├── update-configmap.ps1       # 🔄 Script to generate ConfigMap from HTML
├── deployment.yaml            # 🚢 Kubernetes Deployment
├── service.yaml               # 🌐 Kubernetes Service
├── ingress.yaml              # 🔗 Kubernetes Ingress
├── namespace.yaml            # 📦 Kubernetes Namespace
├── Dockerfile                # 🐳 Container build instructions
├── nginx.conf                # ⚙️ Nginx configuration
└── README.md                 # 📖 This documentation
```

## ✨ New Feature: Separate HTML File

### **Why This Approach?**
- ✅ **Easier Editing**: Edit HTML directly without YAML escaping
- ✅ **Better Syntax Highlighting**: Full HTML support in editors
- ✅ **Version Control**: Clear diff tracking for HTML changes
- ✅ **Maintainability**: Separation of concerns

### **How to Update the Web Content:**

#### **Method 1: Using the Update Script (Recommended)**
```bash
# From project root
.\scripts\update-configmap.ps1

# Or from app directory
cd k8s-apps\sample-web-app
.\update-configmap.ps1
```

#### **Method 2: Manual Process**
```bash
# 1. Edit the HTML content
notepad index.html

# 2. Generate ConfigMap
.\update-configmap.ps1

# 3. Apply to cluster
kubectl apply -f configmap.yaml

# 4. Restart deployment
kubectl rollout restart deployment/sample-web-app -n sample-apps
```

## 🚀 Quick Deployment

### **Deploy the entire application:**
```bash
# Using PowerShell script
.\deploy.ps1

# Or manually step by step
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

### **Update only the web content:**
```bash
# Edit index.html, then:
.\update-configmap.ps1
kubectl apply -f configmap.yaml
kubectl rollout restart deployment/sample-web-app -n sample-apps
```

## 🔄 Development Workflow

### **For Content Changes:**
1. **Edit**: Modify `index.html` directly
2. **Generate**: Run `.\update-configmap.ps1`
3. **Deploy**: Apply the generated `configmap.yaml`
4. **Restart**: Restart the deployment to pick up changes

### **For Infrastructure Changes:**
- Modify `deployment.yaml`, `service.yaml`, or `ingress.yaml`
- Apply changes directly with `kubectl apply`

## 📊 Application Features

### **What the App Demonstrates:**
- ✅ **EKS Integration**: Running on Kubernetes cluster
- ✅ **ConfigMap Usage**: External configuration management
- ✅ **Namespace Isolation**: Deployed in `sample-apps` namespace
- ✅ **Load Balancing**: 3 replica pods for high availability
- ✅ **Modern UI**: Responsive design with live information
- ✅ **Infrastructure Info**: Displays cluster and deployment details

### **Live Information Displayed:**
- Cluster name and version
- Deployment timestamp (Indian timezone)
- Pod hostname (shows load balancing)
- Infrastructure components
- Build information and updates

## 🌐 Access Methods

### **Via Application Load Balancer:**
```bash
# Get ALB URL from ingress
kubectl get ingress -n sample-apps

# Example URL (from your infrastructure)
http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com
```

### **Via Port Forward (Development):**
```bash
kubectl port-forward svc/sample-web-app-service 8080:80 -n sample-apps
# Access: http://localhost:8080
```

## 🔧 Configuration

### **Environment Variables** (in deployment.yaml):
- `CLUSTER_NAME`: EKS cluster name
- `NAMESPACE`: Kubernetes namespace
- `BUILD_NUMBER`: CI/CD build number (updated by Jenkins)

### **ConfigMap Data**:
- `index.html`: Main web content (auto-generated from HTML file)

## 🔍 Troubleshooting

### **Check Deployment Status:**
```bash
kubectl get pods -n sample-apps
kubectl describe deployment sample-web-app -n sample-apps
```

### **View Logs:**
```bash
kubectl logs -l app=sample-web-app -n sample-apps
kubectl logs -f deployment/sample-web-app -n sample-apps
```

### **Verify ConfigMap:**
```bash
kubectl get configmap web-app-content -n sample-apps -o yaml
```

### **Common Issues:**

**ConfigMap not updating:**
```bash
# Force restart pods
kubectl rollout restart deployment/sample-web-app -n sample-apps
```

**HTML not rendering:**
```bash
# Check ConfigMap content
kubectl describe configmap web-app-content -n sample-apps

# Verify pod mounts
kubectl describe pod <pod-name> -n sample-apps
```

## 🎯 Demo Usage

This application is perfect for:
- ✅ Manager presentations showing live EKS deployment
- ✅ Demonstrating Kubernetes concepts (pods, services, ingress)
- ✅ Showing CI/CD pipeline integration
- ✅ Testing load balancing and high availability
- ✅ Infrastructure validation and monitoring

## 💡 Tips for Live Demos

1. **Show the HTML file** - Demonstrate how easy it is to edit
2. **Run the update script** - Show the automated ConfigMap generation
3. **Apply and restart** - Demonstrate Kubernetes deployment updates
4. **Refresh browser** - Show the live changes appearing

## 📝 Notes

- The `configmap.yaml` file is auto-generated - don't edit it manually
- Always edit `index.html` for content changes
- Use the update script to maintain proper YAML formatting
- The application shows live pod information to demonstrate load balancing
- Build information updates automatically via CI/CD pipeline

**The application updates automatically show when changes are deployed, making it perfect for live demonstrations!**
