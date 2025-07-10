# Test Jenkins Ubuntu Installation
param(
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "python.pem",
    
    [Parameter(Mandatory=$false)]
    [string]$JenkinsIP = "13.204.60.118"
)

Write-Host "=========================================="
Write-Host "Testing Jenkins Ubuntu Installation"
Write-Host "=========================================="
Write-Host "Jenkins IP: $JenkinsIP"
Write-Host "SSH Key: $KeyPath"
Write-Host ""

$sshBase = "ssh -i $KeyPath -o StrictHostKeyChecking=no ubuntu@$JenkinsIP"

Write-Host "1. Checking Ubuntu version..."
& cmd /c "$sshBase `"lsb_release -a`""
Write-Host ""

Write-Host "2. Checking Jenkins service status..."
& cmd /c "$sshBase `"sudo systemctl status jenkins --no-pager -l`""
Write-Host ""

Write-Host "3. Checking if Jenkins setup completed..."
& cmd /c "$sshBase `"sudo tail -10 /var/log/jenkins-setup.log`""
Write-Host ""

Write-Host "4. Checking Jenkins user configuration..."
& cmd /c "$sshBase `"sudo getent passwd jenkins`""
Write-Host ""

Write-Host "5. Testing switching to jenkins user..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'whoami && pwd && echo \$SHELL'`""
Write-Host ""

Write-Host "6. Checking if jenkins user can run kubectl..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'kubectl version --client'`""
Write-Host ""

Write-Host "7. Checking AWS CLI for jenkins user..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'aws --version && aws sts get-caller-identity'`""
Write-Host ""

Write-Host "8. Testing EKS access..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'kubectl get nodes'`""
Write-Host ""

Write-Host "9. Getting Jenkins initial admin password..."
& cmd /c "$sshBase `"sudo cat /var/lib/jenkins/secrets/initialAdminPassword`""
Write-Host ""

Write-Host "10. Checking what's running on port 8080..."
& cmd /c "$sshBase `"sudo netstat -tulpn | grep 8080`""
Write-Host ""

Write-Host "=========================================="
Write-Host "Jenkins Access Information:"
Write-Host "=========================================="
Write-Host "Jenkins URL: http://$JenkinsIP:8080"
Write-Host "SSH Command: $sshBase"
Write-Host "Switch to Jenkins user: sudo su - jenkins"
Write-Host ""
Write-Host "Note: Jenkins may take 5-10 minutes to fully install and start."
Write-Host "If Jenkins is not ready yet, wait a few minutes and try again."
