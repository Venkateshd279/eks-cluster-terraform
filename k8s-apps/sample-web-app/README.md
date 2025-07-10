# Sample Web Application for EKS

This directory contains a complete sample web application designed to demonstrate deployment on your EKS cluster.

## 📁 Directory Structure

```
k8s-apps/sample-web-app/
├── namespace.yaml     # Creates 'sample-apps' namespace
├── configmap.yaml     # Custom HTML content
├── deployment.yaml    # Application deployment (3 replicas)
├── service.yaml       # ClusterIP service
├── ingress.yaml       # ALB ingress configuration
├── deploy.sh          # Bash deployment script
├── deploy.ps1         # PowerShell deployment script
└── README.md          # This file
```

## 🚀 Quick Deployment

### Option 1: PowerShell (Windows)
```powershell
cd k8s-apps\sample-web-app
.\deploy.ps1
```

### Option 2: Bash (Git Bash/WSL/Linux)
```bash
cd k8s-apps/sample-web-app
bash deploy.sh
```

### Option 3: Manual kubectl
```bash
kubectl apply -f namespace.yaml
kubectl apply -f configmap.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f ingress.yaml
```

## 🏗️ Application Features

- **Custom Namespace**: Deployed in `sample-apps` namespace for isolation
- **High Availability**: 3 replicas with rolling update strategy
- **Production Ready**: Resource limits, health checks, and proper labels
- **Custom UI**: Beautiful gradient interface showing cluster information
- **Load Balancer**: AWS ALB integration via ingress
- **Monitoring Ready**: Proper labels for observability

## 📊 Monitoring Deployment

### Check Pod Status
```bash
kubectl get pods -n sample-apps -o wide
```

### View Service
```bash
kubectl get svc -n sample-apps
```

### Check Ingress and Load Balancer
```bash
kubectl get ingress -n sample-apps
```

### View Application Logs
```bash
kubectl logs -l app=sample-web-app -n sample-apps
```

### Port Forward for Testing (if ingress not ready)
```bash
kubectl port-forward svc/sample-web-app-service 8080:80 -n sample-apps
# Then visit http://localhost:8080
```

## 🌐 Accessing the Application

After deployment, the application will be available via:

1. **AWS Load Balancer** (if AWS Load Balancer Controller is installed)
   - Get URL: `kubectl get ingress -n sample-apps`
   - Access via the provided hostname

2. **Port Forward** (for testing)
   - Run: `kubectl port-forward svc/sample-web-app-service 8080:80 -n sample-apps`
   - Visit: http://localhost:8080

## 📋 Application Information

- **Container**: Nginx 1.25 Alpine
- **Replicas**: 3 pods for high availability
- **Resources**: 50m CPU request, 100m CPU limit, 64Mi-128Mi memory
- **Health Checks**: Liveness and readiness probes configured
- **Strategy**: Rolling updates with max surge/unavailable = 1

## 🔧 Customization

### Modify the Web Content
Edit `configmap.yaml` and update the HTML content, then apply:
```bash
kubectl apply -f configmap.yaml
kubectl rollout restart deployment/sample-web-app -n sample-apps
```

### Scale the Application
```bash
kubectl scale deployment sample-web-app --replicas=5 -n sample-apps
```

### Update the Application
```bash
kubectl set image deployment/sample-web-app web-app=nginx:1.26-alpine -n sample-apps
```

## 🧹 Cleanup

### Delete the Application
```bash
kubectl delete namespace sample-apps
```

### Delete Individual Resources
```bash
kubectl delete -f ingress.yaml
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
kubectl delete -f configmap.yaml
kubectl delete -f namespace.yaml
```

## 🔍 Troubleshooting

### Pods Not Starting
```bash
kubectl describe pods -n sample-apps
kubectl logs -l app=sample-web-app -n sample-apps
```

### Service Not Accessible
```bash
kubectl describe svc sample-web-app-service -n sample-apps
kubectl get endpoints -n sample-apps
```

### Ingress Issues
```bash
kubectl describe ingress sample-web-app-ingress -n sample-apps
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

## 📚 Next Steps

1. **Install AWS Load Balancer Controller** for ingress functionality
2. **Set up monitoring** with Prometheus and Grafana
3. **Configure autoscaling** with HPA (Horizontal Pod Autoscaler)
4. **Add TLS/SSL** certificates for HTTPS
5. **Implement CI/CD** pipeline for automated deployments

## 🏷️ Labels and Selectors

The application uses consistent labeling:
- `app: sample-web-app`
- `version: v1.0`
- `component: frontend`

This enables easy monitoring, service mesh integration, and advanced deployment strategies.
