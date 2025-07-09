# EKS Cluster with Web Servers, App Servers, and Application Load Balancer

This Terraform configuration creates an Amazon EKS cluster with a complete web application infrastructure including:

## Architecture Overview

- **EKS Cluster**: Kubernetes cluster running version 1.28
- **Managed Node Group**: 2 worker nodes using t2.medium instances
- **Multi-AZ Deployment**: Resources distributed across 3 availability zones
- **Web Servers**: 2 Apache web servers in public subnets
- **App Servers**: 2 Node.js application servers in private subnets
- **Application Load Balancer**: ALB for web servers with health checks
- **VPC**: Custom VPC with public and private subnets
- **Security Groups**: Properly configured for secure communication

## Infrastructure Components

### Networking
- VPC with CIDR block 10.0.0.0/16
- 3 Public subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
- 3 Private subnets (10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24)
- Internet Gateway for public internet access
- 3 NAT Gateways for private subnet internet access
- Route tables with proper routing configuration

### Web Servers (Public Subnets)
- **2 Apache Web Servers** deployed in different AZs
- Instance type: t2.micro (configurable)
- Public IP addresses assigned
- Security group allows HTTP (80), HTTPS (443), and SSH (22)
- Custom web interface with app server connectivity testing
- Health check endpoints for ALB

### App Servers (Private Subnets)
- **2 Node.js Application Servers** deployed in different AZs
- Instance type: t2.micro (configurable)
- Private IP addresses only
- Security group allows traffic from web servers only
- REST API endpoints for data processing
- Health monitoring and system metrics
- Both HTTP (8080) and HTTPS (8443) support

### EKS Cluster
- Cluster name: `altimetrik-eks-cluster` (configurable)
- Version: 1.28 (configurable)
- Control plane logging enabled
- Both private and public endpoint access enabled

### Node Group
- Instance type: t2.medium
- Desired capacity: 2 nodes
- Min size: 1 node
- Max size: 4 nodes
- Deployed in private subnets across 3 AZs

### Application Load Balancer
- Internet-facing ALB for web servers
- Health checks on port 80
- Target group with both web servers
- Automatic failover between healthy targets

### Security
- IAM roles for cluster, nodes, and Load Balancer Controller
- Security groups with least privilege access
- Web servers can communicate with app servers
- App servers isolated from direct internet access
- OIDC provider for service account integration

## Prerequisites

1. **AWS CLI**: Configured with appropriate credentials for ap-south-1 region
2. **Terraform**: Version >= 1.0
3. **kubectl**: For cluster management after deployment
4. **Existing EC2 Key Pair**: The `python.pem` key pair should exist in ap-south-1 region

## Usage

### 1. Verify Your Key Pair Exists
Make sure your `python` key pair exists in the ap-south-1 region:
```bash
aws ec2 describe-key-pairs --region ap-south-1 --key-names python
```

If it doesn't exist, you can create it:
```bash
# Upload your existing public key
aws ec2 import-key-pair --region ap-south-1 --key-name python --public-key-material fileb://~/.ssh/id_rsa.pub
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review Configuration
The configuration is pre-set for:
- **Region**: ap-south-1 (Mumbai)
- **Key Pair**: python (your existing key)
- **Cluster**: altimetrik-eks-cluster

You can modify `terraform.tfvars` if needed:
```hcl
aws_region = "ap-south-1"
cluster_name = "altimetrik-eks-cluster"
cluster_version = "1.28"
key_pair_name = "python"
web_server_instance_type = "t2.micro"
app_server_instance_type = "t2.micro"
```

### 4. Plan the Deployment
```bash
terraform plan
```

### 5. Deploy the Infrastructure
```bash
terraform apply
```

### 6. Configure kubectl
After deployment, configure kubectl to connect to your cluster:
```bash
aws eks update-kubeconfig --region ap-south-1 --name altimetrik-eks-cluster
```

## Post-Deployment Setup

### Access Your Infrastructure

After deployment, you'll receive several important outputs:

1. **Web Application Load Balancer URL**: Access your web servers
2. **Web Server IPs**: Direct access to individual web servers
3. **App Server IPs**: For troubleshooting (accessible only from web servers)
4. **EKS Cluster Info**: For Kubernetes management

### Testing Web Server to App Server Connectivity

1. **Access the Web Interface**:
   ```bash
   # Get the ALB DNS name
   terraform output web_alb_dns_name
   
   # Open in browser
   http://<alb-dns-name>
   ```

2. **Test App Server Connectivity**:
   - The web interface includes buttons to test connectivity to both app servers
   - Click "Test App Server 1" or "Test App Server 2" to verify communication
   - Results show port status, ping tests, and API responses

3. **SSH Access to Servers**:
   ```bash
   # SSH to Web Server 1 (using python.pem)
   ssh -i python.pem ec2-user@<web-server-1-public-ip>
   
   # SSH to Web Server 2 (using python.pem)
   ssh -i python.pem ec2-user@<web-server-2-public-ip>
   
   # SSH to App Servers (via web servers)
   ssh -i python.pem ec2-user@<web-server-ip>
   ssh -i python.pem ec2-user@<app-server-private-ip>
   ```

### App Server API Endpoints

The app servers provide several REST API endpoints:

```bash
# Health check
curl http://<app-server-ip>:8080/

# Detailed server info
curl http://<app-server-ip>:8080/info

# User data API
curl http://<app-server-ip>:8080/api/users

# System metrics
curl http://<app-server-ip>:8080/api/system/metrics

# Database status simulation
curl http://<app-server-ip>:8080/api/database/status
```

### Monitoring and Logs

**Web Servers**:
```bash
# Check Apache status
sudo systemctl status httpd

# View Apache logs
sudo tail -f /var/log/httpd/access_log
sudo tail -f /var/log/httpd/error_log

# Check setup logs
sudo cat /var/log/web-server-setup.log
```

**App Servers**:
```bash
# Check app service status
sudo systemctl status app-server

# View app logs
sudo journalctl -u app-server -f

# Run health check
sudo /opt/app-server/health-check.sh

# Check setup logs
sudo cat /var/log/app-server-setup.log
```

### Install AWS Load Balancer Controller (for EKS)

1. **Install using Helm**:
```bash
# Add the EKS chart repo
helm repo add eks https://aws.github.io/eks-charts

# Install AWS Load Balancer Controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<cluster-name> \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

2. **Create Service Account**:
```bash
kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  labels:
    app.kubernetes.io/component: controller
    app.kubernetes.io/name: aws-load-balancer-controller
  name: aws-load-balancer-controller
  namespace: kube-system
  annotations:
    eks.amazonaws.com/role-arn: $(terraform output -raw aws_load_balancer_controller_role_arn)
EOF
```

### Example Application with ALB

Here's an example of deploying an application with Application Load Balancer:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: sample-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: sample-app
  template:
    metadata:
      labels:
        app: sample-app
    spec:
      containers:
      - name: app
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: sample-app-service
spec:
  selector:
    app: sample-app
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: sample-app-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: sample-app-service
            port:
              number: 80
```

## Outputs

The configuration provides several useful outputs:

### EKS Cluster Outputs
- `cluster_endpoint`: EKS cluster API endpoint
- `cluster_name`: The EKS cluster name
- `aws_load_balancer_controller_role_arn`: IAM role ARN for ALB controller

### Infrastructure Outputs
- `vpc_id`: VPC ID
- `private_subnets`: Private subnet IDs
- `public_subnets`: Public subnet IDs

### Web Server Outputs
- `web_alb_dns_name`: Application Load Balancer DNS name
- `web_server_1_public_ip`: Web Server 1 public IP
- `web_server_2_public_ip`: Web Server 2 public IP
- `web_server_1_private_ip`: Web Server 1 private IP
- `web_server_2_private_ip`: Web Server 2 private IP

### App Server Outputs
- `app_server_1_private_ip`: App Server 1 private IP
- `app_server_2_private_ip`: App Server 2 private IP

## Security Considerations

- Worker nodes are deployed in private subnets
- Security groups follow least privilege principle
- IAM roles have minimal required permissions
- Cluster logging is enabled for monitoring

## Cost Optimization

- Uses t2.medium instances (can be changed to t3.medium for better performance)
- Auto-scaling enabled (1-4 nodes)
- Resources tagged for cost tracking

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

**Note**: Make sure to delete any Load Balancers created by the ALB controller before running terraform destroy to avoid issues.

## Troubleshooting

### Common Issues

1. **IAM Permissions**: Ensure your AWS credentials have sufficient permissions
2. **Region Limits**: Check if your region has available capacity for t2.medium instances
3. **VPC Limits**: Ensure you haven't reached VPC limits in your AWS account

### Useful Commands

```bash
# Check cluster status
kubectl get nodes

# View pods in all namespaces
kubectl get pods --all-namespaces

# Check ALB controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

## Support

For issues or questions, refer to:
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [AWS Load Balancer Controller Documentation](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
