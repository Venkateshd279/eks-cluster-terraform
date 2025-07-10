#!/bin/bash
# Jenkins setup script for Amazon Linux 2
# This script installs Jenkins, Docker, kubectl, and AWS CLI

set -e

# Variables
CLUSTER_NAME="${cluster_name}"
REGION="${region}"

# Log all output
exec > >(tee /var/log/jenkins-setup.log)
exec 2>&1

echo "Starting Jenkins setup for cluster: $CLUSTER_NAME in region: $REGION"

# Update system
echo "Updating system packages..."
yum update -y

# Install Java 11 (required for Jenkins)
echo "Installing Java 11..."
amazon-linux-extras install java-openjdk11 -y

# Install Jenkins
echo "Installing Jenkins..."
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
yum install jenkins -y

# Install Docker
echo "Installing Docker..."
yum install docker -y

# Install Git
echo "Installing Git..."
yum install git -y

# Install kubectl
echo "Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install AWS CLI v2
echo "Installing AWS CLI v2..."
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws/

# Install Helm (for advanced Kubernetes deployments)
echo "Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Start and enable Docker
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add jenkins user to docker group
echo "Adding jenkins user to docker group..."
usermod -a -G docker jenkins

# Configure Jenkins directories and permissions
echo "Configuring Jenkins..."
mkdir -p /var/lib/jenkins/.kube
mkdir -p /var/lib/jenkins/.aws
chown -R jenkins:jenkins /var/lib/jenkins

# Start and enable Jenkins
echo "Starting Jenkins service..."
systemctl start jenkins
systemctl enable jenkins

# Configure AWS CLI for Jenkins user (using instance profile)
echo "Configuring AWS CLI for jenkins user..."
su - jenkins -c "aws configure set region $REGION"
su - jenkins -c "aws configure set output json"

# Configure kubectl for Jenkins user to access EKS cluster
echo "Configuring kubectl for EKS cluster access..."
su - jenkins -c "aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME" || echo "EKS cluster not ready yet, will configure later"

# Install additional tools for CI/CD
echo "Installing additional CI/CD tools..."

# Install jq for JSON processing
yum install jq -y

# Install Node.js and npm (for building JS applications)
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install nodejs -y

# Install Python and pip (for Python applications)
yum install python3 python3-pip -y

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create Jenkins plugins installation script
echo "Creating Jenkins plugins installation script..."
cat > /tmp/install-jenkins-plugins.sh << 'EOF'
#!/bin/bash
# Wait for Jenkins to start
echo "Waiting for Jenkins to start..."
while ! curl -f -s http://localhost:8080/login > /dev/null; do
    echo "Waiting for Jenkins..."
    sleep 10
done

# Install Jenkins CLI
wget http://localhost:8080/jnlpJars/jenkins-cli.jar -O /tmp/jenkins-cli.jar

# Get initial admin password
ADMIN_PASSWORD=$(cat /var/lib/jenkins/secrets/initialAdminPassword)

# Install essential plugins
echo "Installing Jenkins plugins..."
java -jar /tmp/jenkins-cli.jar -s http://localhost:8080 -auth admin:$ADMIN_PASSWORD install-plugin \
    aws-credentials \
    docker-workflow \
    kubernetes \
    pipeline-stage-view \
    git \
    github \
    blue-ocean \
    workflow-aggregator \
    credentials \
    credentials-binding \
    pipeline-utility-steps \
    build-timeout \
    timestamper \
    ws-cleanup

# Restart Jenkins to activate plugins
echo "Restarting Jenkins to activate plugins..."
systemctl restart jenkins
EOF

chmod +x /tmp/install-jenkins-plugins.sh

# Create a systemd service to run the plugin installation after Jenkins starts
cat > /etc/systemd/system/jenkins-plugins-installer.service << EOF
[Unit]
Description=Install Jenkins Plugins
After=jenkins.service
Requires=jenkins.service

[Service]
Type=oneshot
ExecStart=/tmp/install-jenkins-plugins.sh
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl enable jenkins-plugins-installer.service

# Create Jenkins job configuration directory
mkdir -p /var/lib/jenkins/jobs
chown -R jenkins:jenkins /var/lib/jenkins/jobs

# Create a sample job configuration
cat > /var/lib/jenkins/jobs/sample-web-app-deploy.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>Deploy Sample Web Application to EKS</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.plugins.buildblocker.BuildBlockerProperty plugin="build-blocker-plugin@1.7.3">
      <useBuildBlocker>false</useBuildBlocker>
      <blockLevel>GLOBAL</blockLevel>
      <scanQueueFor>DISABLED</scanQueueFor>
      <blockingJobs></blockingJobs>
    </hudson.plugins.buildblocker.BuildBlockerProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.80">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.4.5">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>https://github.com/your-repo/eks-cluster-terraform.git</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>cicd/jenkins/Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

chown jenkins:jenkins /var/lib/jenkins/jobs/sample-web-app-deploy.xml

# Create initialization script for Jenkins
cat > /var/lib/jenkins/init.groovy.d/basic-security.groovy << 'EOF'
import jenkins.model.*
import hudson.security.*
import hudson.security.csrf.DefaultCrumbIssuer
import jenkins.install.InstallState

def instance = Jenkins.getInstance()

// Skip the setup wizard
instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

// Enable CSRF protection
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))

// Save configuration
instance.save()
EOF

chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d/

# Configure firewall (if enabled)
if systemctl is-active --quiet firewalld; then
    echo "Configuring firewall..."
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --reload
fi

# Set up log rotation for Jenkins
cat > /etc/logrotate.d/jenkins << 'EOF'
/var/log/jenkins/jenkins.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    copytruncate
}
EOF

# Print setup completion information
echo "================================================================"
echo "Jenkins setup completed successfully!"
echo "================================================================"
echo "Jenkins URL: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "Initial admin password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"
echo ""
echo "Installed tools:"
echo "- Jenkins: $(jenkins --version 2>/dev/null || echo 'Installed')"
echo "- Docker: $(docker --version)"
echo "- kubectl: $(kubectl version --client --short)"
echo "- AWS CLI: $(aws --version)"
echo "- Helm: $(helm version --short)"
echo "- Node.js: $(node --version)"
echo "- Python: $(python3 --version)"
echo ""
echo "Next steps:"
echo "1. Access Jenkins web interface"
echo "2. Complete initial setup"
echo "3. Configure credentials (AWS, Git)"
echo "4. Create and run your first pipeline"
echo "================================================================"

# Log the completion
echo "$(date): Jenkins setup completed" >> /var/log/jenkins-setup.log
