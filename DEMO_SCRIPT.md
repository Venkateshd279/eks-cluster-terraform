# 🚀 EKS CI/CD Pipeline Demo Script
# Complete Architecture Demonstration

## 📋 Demo Overview
This demo showcases a production-grade AWS EKS cluster with CI/CD pipeline, demonstrating:
- Infrastructure as Code (Terraform)
- Kubernetes Container Orchestration
- CI/CD with Jenkins
- Live Application Updates
- AWS Load Balancer Integration

---

## 🎯 Demo Flow (30-45 minutes)

### **Part 1: Infrastructure Overview (10 minutes)**
#### 1.1 Architecture Walkthrough
```
"Let me show you our production-grade EKS infrastructure built with Terraform..."
```

**Show Architecture Diagram:**
- VPC with public/private subnets across 2 AZs
- EKS Cluster with managed node groups
- Application Load Balancer
- Jenkins CI/CD server
- Web and App servers for comparison

**Key Points:**
- "Everything is defined as code using Terraform"
- "High availability across multiple zones"
- "Secure private subnets for worker nodes"
- "Internet-facing ALB for external access"

#### 1.2 Show Terraform Infrastructure
```powershell
# Navigate to terraform directory
cd terraform

# Show the infrastructure files
ls -la
```

**Explain key files:**
- `main.tf` - Core infrastructure
- `variables.tf` - Configuration parameters
- `outputs.tf` - Important resource references

```powershell
# Show current infrastructure state
terraform show | head -20
```

---

### **Part 2: Kubernetes Cluster Deep Dive (10 minutes)**
#### 2.1 Cluster Status
```powershell
# Show cluster information
kubectl cluster-info

# Show nodes
kubectl get nodes -o wide

# Show system pods
kubectl get pods -n kube-system
```

**Explain:**
- "2 worker nodes for high availability"
- "Running on Amazon Linux optimized for EKS"
- "CoreDNS for service discovery"
- "AWS VPC CNI for networking"

#### 2.2 Application Namespace
```powershell
# Show application namespace
kubectl get namespace sample-apps

# Show all resources in the namespace
kubectl get all -n sample-apps
```

**Explain:**
- "Dedicated namespace for our application"
- "3 pod replicas for high availability"
- "ClusterIP service for internal communication"
- "NodePort service for external access"

---

### **Part 3: Live Application Demo (15 minutes)**
#### 3.1 Show Current Application
```
"Let's see our live application running on Kubernetes..."
```

**Open browser:** `http://my-eks-cluster-web-alb-1309538953.ap-south-1.elb.amazonaws.com`

**Show:**
- Simple, clean interface
- "This K8s CICD pipeline DEMO"
- "Running on Kubernetes"

#### 3.2 Behind the Scenes
```powershell
# Show the ConfigMap
kubectl get configmap web-app-content -n sample-apps -o yaml

# Show how it's mounted in pods
kubectl describe pod -n sample-apps -l app=sample-web-app | grep -A 10 "Mounts:"
```

**Explain:**
- "HTML content stored in Kubernetes ConfigMap"
- "Mounted as a volume in nginx pods"
- "Enables configuration without rebuilding images"

#### 3.3 Load Balancer Configuration
```powershell
# Show the ingress
kubectl get ingress -n sample-apps

# Show the service
kubectl get svc -n sample-apps
```

**Explain AWS ALB Integration:**
- "Application Load Balancer automatically created"
- "Health checks ensure only healthy pods receive traffic"
- "Integrates with AWS security groups and VPC"

---

### **Part 4: Live Configuration Update (10 minutes)**
#### 4.1 The Magic Demo
```
"Now let's demonstrate live updates without downtime..."
```

**Step 1: Edit the ConfigMap**
```powershell
# Open the ConfigMap for editing
code k8s-apps/sample-web-app/configmap.yaml
```

**Live edit the HTML:**
```html
<h1>This K8s CICD pipeline DEMO - UPDATED LIVE!</h1>
<p>🚀 Running on Kubernetes - No Downtime!</p>
<p>⚡ ConfigMap updated at: [current time]</p>
```

**Step 2: Apply the Changes**
```powershell
# Apply the updated ConfigMap
kubectl apply -f k8s-apps/sample-web-app/configmap.yaml

# Restart the deployment to pick up changes
kubectl rollout restart deployment/sample-web-app -n sample-apps

# Watch the rolling update
kubectl get pods -n sample-apps -w
```

**Step 3: Show the Results**
- Refresh the browser
- Show the updated content
- **"Zero downtime update!"**

#### 4.2 Explain the Process
```
"What just happened behind the scenes..."
```

**Show the rollout:**
```powershell
# Show rollout status
kubectl rollout status deployment/sample-web-app -n sample-apps

# Show rollout history
kubectl rollout history deployment/sample-web-app -n sample-apps
```

**Key Points:**
- "Kubernetes rolling update strategy"
- "Old pods kept running until new ones are ready"
- "Load balancer automatically routes to healthy pods"
- "Can rollback instantly if needed"

---

### **Part 5: CI/CD Pipeline Overview (5 minutes)**
#### 5.1 Jenkins Integration
```powershell
# Show Jenkins server
echo "Jenkins URL: http://13.204.60.118:8080"
```

**Open Jenkins in browser and show:**
- Pipeline configuration
- Integration with GitHub
- Automated deployments
- Build history

#### 5.2 Complete DevOps Flow
```
"Here's the complete CI/CD pipeline..."
```

**Explain the flow:**
1. **Developer commits code** → GitHub
2. **Jenkins detects changes** → Triggers build
3. **Jenkins builds image** → Pushes to registry
4. **Jenkins updates Kubernetes** → Deploys to EKS
5. **Load balancer routes traffic** → Zero downtime

---

## 🎨 Demo Tips & Best Practices

### **Opening Hook (2 minutes)**
```
"Today I'll show you how to build and deploy a production-grade 
Kubernetes application on AWS with complete CI/CD automation. 
In the next 30 minutes, you'll see:
- Infrastructure as Code with Terraform
- Kubernetes orchestration on AWS EKS
- Live application updates with zero downtime
- Complete CI/CD pipeline with Jenkins
And I'll do it all with live demonstrations!"
```

### **Engagement Points**
- **Ask questions:** "Who's used Kubernetes before?"
- **Relate to audience:** "This solves the problem of..."
- **Show real value:** "This reduces deployment time from hours to minutes"

### **Technical Deep Dives**
- **Security:** "Notice all worker nodes are in private subnets"
- **Scalability:** "This setup can handle thousands of requests per second"
- **Cost optimization:** "Managed node groups auto-scale based on demand"

### **Common Questions & Answers**
Q: "How do you handle secrets?"
A: "We use Kubernetes secrets and AWS Secrets Manager integration"

Q: "What about monitoring?"
A: "We integrate with CloudWatch and Prometheus for comprehensive monitoring"

Q: "How do you handle different environments?"
A: "We use separate namespaces and Terraform workspaces for dev/staging/prod"

---

## 🚀 Demo Variations

### **Quick Demo (10 minutes)**
1. Show running application
2. Edit ConfigMap live
3. Apply changes
4. Show updated application
5. Explain the architecture

### **Deep Technical Demo (60 minutes)**
- Include Terraform plan/apply
- Show monitoring dashboards
- Demonstrate rollback scenarios
- Show security features
- Include cost analysis

### **Executive Demo (15 minutes)**
- Focus on business value
- Show before/after deployment times
- Highlight cost savings
- Emphasize scalability benefits

---

## 📝 Preparation Checklist

### **Before Demo**
- [ ] Verify all services are running
- [ ] Test the application URL
- [ ] Prepare backup slides
- [ ] Have kubectl configured
- [ ] Test all demo commands
- [ ] Prepare for Q&A

### **Demo Environment**
- [ ] Clean terminal windows
- [ ] Zoom terminal font size
- [ ] Bookmark application URL
- [ ] Have architecture diagram ready
- [ ] Prepare VS Code with files open

### **Backup Plans**
- [ ] Screenshots of working demo
- [ ] Pre-recorded video clips
- [ ] Static HTML version
- [ ] Slide deck with key points

---

## 🎯 Key Takeaways to Emphasize

1. **Infrastructure as Code** - Everything is reproducible and version-controlled
2. **Zero Downtime Deployments** - Business continuity is maintained
3. **Scalability** - Automatically handles traffic spikes
4. **Security** - Private subnets, security groups, IAM roles
5. **Cost Optimization** - Pay only for what you use
6. **Developer Productivity** - Focus on code, not infrastructure
7. **Reliability** - High availability across multiple zones

---

## 🔧 Troubleshooting During Demo

### **If Application is Down:**
```powershell
kubectl get pods -n sample-apps
kubectl logs -n sample-apps -l app=sample-web-app
```

### **If LoadBalancer is Slow:**
```powershell
kubectl get ingress -n sample-apps
aws elbv2 describe-target-health --target-group-arn [ARN]
```

### **If ConfigMap Update Doesn't Work:**
```powershell
kubectl describe configmap web-app-content -n sample-apps
kubectl get pods -n sample-apps -o wide
```

---

**Remember:** The goal is to tell a story about modern application deployment, not just show commands. Focus on the business value and developer experience!
