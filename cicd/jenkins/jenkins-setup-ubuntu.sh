#!/bin/bash
# Jenkins setup script for Ubuntu 22.04 LTS
# This script installs Jenkins, Docker, kubectl, and AWS CLI

set -e

# Variables
CLUSTER_NAME="${cluster_name}"
REGION="${region}"

# Log all output
exec > >(tee /var/log/jenkins-setup.log)
exec 2>&1

echo "Starting Jenkins setup on Ubuntu 22.04 for cluster: $CLUSTER_NAME in region: $REGION"

# Update system
echo "Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install essential packages
echo "Installing essential packages..."
apt-get install -y curl wget gnupg2 software-properties-common apt-transport-https ca-certificates lsb-release

# # Install Java 11 (required for Jenkins)
# echo "Installing OpenJDK 11..."
# apt-get install -y openjdk-11-jdk

# Add Jenkins repository and install Jenkins
echo "Installing Jenkins..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
    https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install fontconfig openjdk-17-jre
sudo apt-get install jenkins

# Install Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Git
echo "Installing Git..."
apt-get install -y git

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install AWS CLI v2
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
apt-get install -y unzip
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws/

# Install Helm (for advanced Kubernetes deployments)
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install additional tools
echo "Installing additional tools..."
apt-get install -y jq tree htop

# Start and enable Docker
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add jenkins user to docker group
echo "Adding jenkins user to docker group..."
usermod -a -G docker jenkins

# Start and enable Jenkins
echo "Starting Jenkins service..."
systemctl start jenkins
systemctl enable jenkins

# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
sleep 30

# Configure Jenkins directories and permissions
echo "Configuring Jenkins directories..."
mkdir -p /var/lib/jenkins/.kube
mkdir -p /var/lib/jenkins/.aws
chown -R jenkins:jenkins /var/lib/jenkins

# Set proper shell for jenkins user
echo "Setting bash shell for jenkins user..."
usermod -s /bin/bash jenkins

# Create .bashrc for jenkins user
echo "Creating .bashrc for jenkins user..."
cat > /var/lib/jenkins/.bashrc << 'EOF'
# .bashrc for jenkins user
if [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi

# User specific aliases and functions
export PATH=$PATH:/usr/local/bin:/usr/local/aws-cli/v2/current/bin
export KUBECONFIG=/var/lib/jenkins/.kube/config

# AWS CLI completion
if command -v aws_completer >/dev/null 2>&1; then
    complete -C aws_completer aws
fi

# kubectl completion
if command -v kubectl >/dev/null 2>&1; then
    source <(kubectl completion bash)
fi

# Docker aliases
alias dps='docker ps'
alias di='docker images'
alias dc='docker-compose'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
EOF

chown jenkins:jenkins /var/lib/jenkins/.bashrc

# Configure AWS CLI for Jenkins user (using instance profile)
echo "Configuring AWS CLI for jenkins user..."
sudo -u jenkins aws configure set region $REGION
sudo -u jenkins aws configure set output json

# Configure kubectl for Jenkins user to access EKS cluster
echo "Configuring kubectl for EKS cluster access..."
sudo -u jenkins aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME || echo "EKS cluster not ready yet, will configure later"

# Install Node.js and npm (for building JS applications)
echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Install Python and pip (for Python applications)
echo "Installing Python3 and pip..."
apt-get install -y python3 python3-pip

# Install additional development tools
echo "Installing development tools..."
apt-get install -y build-essential

# Set proper permissions for Jenkins directories
chown -R jenkins:jenkins /var/lib/jenkins
chmod 755 /var/lib/jenkins
chmod 700 /var/lib/jenkins/.kube 2>/dev/null || true
chmod 700 /var/lib/jenkins/.aws 2>/dev/null || true

# Configure Jenkins initial setup
echo "Configuring Jenkins initial setup..."
sleep 10

# Install Jenkins plugins via CLI (optional)
echo "Jenkins initial password is stored at: /var/lib/jenkins/secrets/initialAdminPassword"

# Create a status file to indicate setup completion
echo "Jenkins setup completed successfully at $(date)" > /var/lib/jenkins/setup-complete.txt
chown jenkins:jenkins /var/lib/jenkins/setup-complete.txt

# Print setup completion message
echo "=========================================="
echo "Jenkins Ubuntu Setup Complete!"
echo "=========================================="
echo "Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "Initial admin password: $(cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo 'Not available yet')"
echo "SSH as jenkins user: sudo su - jenkins"
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Setup log: /var/log/jenkins-setup.log"
echo "=========================================="
