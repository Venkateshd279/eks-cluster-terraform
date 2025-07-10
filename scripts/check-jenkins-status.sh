#!/bin/bash
# Monitor Jenkins initialization status

JENKINS_IP="65.1.240.109"
KEY_FILE="python.pem"

echo "Monitoring Jenkins initialization on $JENKINS_IP..."
echo "================================================================"

# Function to check if Jenkins is responding
check_jenkins() {
    curl -s -o /dev/null -w "%{http_code}" http://$JENKINS_IP:8080
}

# Function to get Jenkins setup log via SSH
get_setup_log() {
    ssh -i "$KEY_FILE" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@$JENKINS_IP "tail -20 /var/log/jenkins-setup.log" 2>/dev/null
}

# Function to check Jenkins service status
check_jenkins_service() {
    ssh -i "$KEY_FILE" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@$JENKINS_IP "sudo systemctl status jenkins --no-pager -l" 2>/dev/null
}

echo "Checking setup progress..."
echo "Setup log (last 20 lines):"
get_setup_log

echo ""
echo "Jenkins service status:"
check_jenkins_service

echo ""
echo "Checking web interface..."
HTTP_CODE=$(check_jenkins)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "403" ]; then
    echo "✅ Jenkins is accessible! HTTP Code: $HTTP_CODE"
    echo "🌐 Access Jenkins at: http://$JENKINS_IP:8080"
    
    # Get initial admin password
    echo ""
    echo "Getting initial admin password..."
    ssh -i "$KEY_FILE" -o ConnectTimeout=10 -o StrictHostKeyChecking=no ec2-user@$JENKINS_IP "sudo cat /var/lib/jenkins/secrets/initialAdminPassword" 2>/dev/null
else
    echo "⏳ Jenkins is still initializing... HTTP Code: $HTTP_CODE"
    echo "Please wait a few more minutes and try again."
fi

echo ""
echo "================================================================"
echo "Commands to manually check status:"
echo "SSH: ssh -i python.pem ec2-user@$JENKINS_IP"
echo "Check logs: sudo tail -f /var/log/jenkins-setup.log"
echo "Check Jenkins: sudo systemctl status jenkins"
echo "Check password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
