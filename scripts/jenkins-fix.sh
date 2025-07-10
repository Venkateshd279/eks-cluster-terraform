#!/bin/bash
# Jenkins Fix Script - Run this on the Jenkins server to fix common startup issues

set -e

echo "==============================="
echo "Jenkins Startup Fix Script"
echo "==============================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run this script with sudo:"
    echo "sudo bash jenkins-fix.sh"
    exit 1
fi

echo "1. Checking Java installation..."
java -version || {
    echo "Installing Java 11..."
    amazon-linux-extras install java-openjdk11 -y
}

echo "2. Checking Jenkins installation..."
which jenkins || {
    echo "Reinstalling Jenkins..."
    wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    yum install jenkins -y
}

echo "3. Fixing Jenkins permissions..."
# Ensure jenkins user exists
id jenkins || useradd jenkins

# Fix directory permissions
mkdir -p /var/lib/jenkins
mkdir -p /var/cache/jenkins
mkdir -p /var/log/jenkins
chown -R jenkins:jenkins /var/lib/jenkins
chown -R jenkins:jenkins /var/cache/jenkins
chown -R jenkins:jenkins /var/log/jenkins
chmod -R 755 /var/lib/jenkins

echo "4. Checking Jenkins configuration..."
# Create default Jenkins config if missing
if [ ! -f /etc/sysconfig/jenkins ]; then
    echo "Creating Jenkins configuration..."
    cat > /etc/sysconfig/jenkins << 'EOF'
JENKINS_HOME="/var/lib/jenkins"
JENKINS_JAVA_CMD=""
JENKINS_USER="jenkins"
JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true"
JENKINS_PORT="8080"
JENKINS_LISTEN_ADDRESS=""
JENKINS_HTTPS_PORT=""
JENKINS_HTTPS_KEYSTORE=""
JENKINS_HTTPS_KEYSTORE_PASSWORD=""
JENKINS_HTTPS_LISTEN_ADDRESS=""
JENKINS_DEBUG_LEVEL="5"
JENKINS_ENABLE_ACCESS_LOG="no"
JENKINS_HANDLER_MAX="100"
JENKINS_HANDLER_IDLE="20"
JENKINS_ARGS=""
EOF
fi

echo "5. Setting up Jenkins environment..."
# Ensure proper Java environment
export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::")
echo "JAVA_HOME=$JAVA_HOME" >> /etc/environment

echo "6. Stopping any existing Jenkins processes..."
pkill -f jenkins || true
systemctl stop jenkins || true

echo "7. Cleaning up Jenkins locks..."
rm -f /var/lib/jenkins/.jenkins.pid || true

echo "8. Starting Jenkins service..."
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo "9. Waiting for Jenkins to start..."
sleep 30

echo "10. Checking Jenkins status..."
systemctl status jenkins --no-pager

if systemctl is-active --quiet jenkins; then
    echo "✅ Jenkins is now running successfully!"
    echo "🌐 Access Jenkins at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
    echo "🔑 Initial admin password:"
    cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "Password file not yet created, wait a few minutes"
else
    echo "❌ Jenkins failed to start. Checking logs..."
    echo "Recent Jenkins logs:"
    journalctl -u jenkins --no-pager -l | tail -20
    echo ""
    echo "Check detailed logs with: journalctl -u jenkins -f"
fi

echo "==============================="
echo "Fix script completed"
echo "==============================="
