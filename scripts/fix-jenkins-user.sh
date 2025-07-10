#!/bin/bash

# Fix Jenkins User Configuration Script
# This script fixes the jenkins user shell, home directory, and configures kubectl access

set -e

echo "=========================================="
echo "Fixing Jenkins User Configuration"
echo "=========================================="

# Check if running as root/sudo
if [ "$EUID" -ne 0 ]; then
    echo "This script must be run as root or with sudo"
    exit 1
fi

echo "1. Checking current jenkins user configuration..."
id jenkins
getent passwd jenkins

echo "2. Setting up proper shell for jenkins user..."
# Set bash as the shell for jenkins user
usermod -s /bin/bash jenkins

echo "3. Creating and configuring jenkins home directory..."
# Ensure jenkins home directory exists and has proper permissions
mkdir -p /var/lib/jenkins
chown jenkins:jenkins /var/lib/jenkins
chmod 755 /var/lib/jenkins

# Create .bashrc for jenkins user if it doesn't exist
if [ ! -f /var/lib/jenkins/.bashrc ]; then
    cat > /var/lib/jenkins/.bashrc << 'EOF'
# .bashrc for jenkins user

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions
export PATH=$PATH:/usr/local/bin:/opt/aws-cli/v2/current/bin
export KUBECONFIG=/var/lib/jenkins/.kube/config

# AWS CLI completion
complete -C '/opt/aws-cli/v2/current/bin/aws_completer' aws

# kubectl completion
if command -v kubectl &> /dev/null; then
    source <(kubectl completion bash)
fi
EOF
    chown jenkins:jenkins /var/lib/jenkins/.bashrc
fi

echo "4. Creating .kube directory for jenkins user..."
mkdir -p /var/lib/jenkins/.kube
chown jenkins:jenkins /var/lib/jenkins/.kube
chmod 700 /var/lib/jenkins/.kube

echo "5. Installing kubectl if not present..."
if ! command -v kubectl &> /dev/null; then
    echo "Installing kubectl..."
    curl -o kubectl "https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.3/2023-11-14/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/
fi

echo "6. Checking AWS CLI installation..."
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
fi

echo "7. Configuring EKS access for jenkins user..."
# Get EKS cluster name from terraform output or use known values
CLUSTER_NAME="my-eks-cluster"
REGION="ap-south-1"

echo "Cluster Name: $CLUSTER_NAME"
echo "Region: $REGION"

# Update kubeconfig for jenkins user
sudo -u jenkins aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME --kubeconfig /var/lib/jenkins/.kube/config

# Set proper permissions
chown jenkins:jenkins /var/lib/jenkins/.kube/config
chmod 600 /var/lib/jenkins/.kube/config

echo "8. Adding jenkins user to docker group (if docker is installed)..."
if getent group docker > /dev/null 2>&1; then
    usermod -a -G docker jenkins
    echo "Jenkins user added to docker group"
else
    echo "Docker group not found, skipping..."
fi

echo "9. Testing jenkins user configuration..."
echo "Switching to jenkins user and testing kubectl..."

# Test the configuration
sudo -u jenkins bash -c '
    echo "Testing as jenkins user..."
    echo "Current user: $(whoami)"
    echo "Home directory: $HOME"
    echo "PATH: $PATH"
    echo "KUBECONFIG: $KUBECONFIG"
    
    echo "Testing AWS CLI..."
    aws --version
    
    echo "Testing kubectl..."
    kubectl version --client
    
    echo "Testing EKS connection..."
    kubectl get nodes --request-timeout=10s || echo "EKS connection test failed - this may be expected if cluster is not ready"
'

echo "=========================================="
echo "Jenkins user configuration completed!"
echo "=========================================="
echo ""
echo "You can now switch to jenkins user with:"
echo "sudo su - jenkins"
echo ""
echo "Or test kubectl access with:"
echo "sudo -u jenkins kubectl get nodes"
