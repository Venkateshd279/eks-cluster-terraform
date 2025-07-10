# PowerShell script to check Jenkins installation status
param(
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "python.pem",
    
    [Parameter(Mandatory=$false)]
    [string]$JenkinsIP = "65.1.240.109"
)

Write-Host "=========================================="
Write-Host "Checking Jenkins Installation Status"
Write-Host "=========================================="

$sshBase = "ssh -i $KeyPath -o StrictHostKeyChecking=no ec2-user@$JenkinsIP"

Write-Host "1. Checking if Jenkins service exists and is running..."
& cmd /c "$sshBase `"sudo systemctl status jenkins --no-pager`""
Write-Host ""

Write-Host "2. Checking Java installation..."
& cmd /c "$sshBase `"java -version`""
Write-Host ""

Write-Host "3. Checking if Jenkins user exists..."
& cmd /c "$sshBase `"id jenkins`""
& cmd /c "$sshBase `"getent passwd jenkins`""
Write-Host ""

Write-Host "4. Checking Jenkins setup log..."
& cmd /c "$sshBase `"sudo tail -20 /var/log/jenkins-setup.log`""
Write-Host ""

Write-Host "5. Checking what's running on port 8080..."
& cmd /c "$sshBase `"sudo netstat -tulpn | grep 8080`""
Write-Host ""

Write-Host "6. Checking if user data script executed..."
& cmd /c "$sshBase `"sudo tail -20 /var/log/cloud-init-output.log`""
Write-Host ""

Write-Host "7. Checking Jenkins installation directory..."
& cmd /c "$sshBase `"ls -la /var/lib/jenkins/`""
Write-Host ""

Write-Host "8. Checking if AWS CLI works..."
& cmd /c "$sshBase `"aws --version`""
Write-Host ""

Write-Host "9. Checking if kubectl is installed..."
& cmd /c "$sshBase `"which kubectl`""
& cmd /c "$sshBase `"kubectl version --client`""
