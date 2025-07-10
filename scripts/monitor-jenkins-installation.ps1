# Monitor Jenkins Installation Progress
param(
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "python.pem",
    
    [Parameter(Mandatory=$false)]
    [string]$JenkinsIP = "13.204.60.118"
)

Write-Host "=========================================="
Write-Host "Monitoring Jenkins Installation Progress"
Write-Host "=========================================="

$sshBase = "ssh -i $KeyPath -o StrictHostKeyChecking=no ubuntu@$JenkinsIP"

Write-Host "1. Checking cloud-init status..."
& cmd /c "$sshBase `"sudo cloud-init status`""
Write-Host ""

Write-Host "2. Checking installation log (last 20 lines)..."
& cmd /c "$sshBase `"sudo tail -20 /var/log/jenkins-setup.log 2>/dev/null || echo 'Setup log not found yet'`""
Write-Host ""

Write-Host "3. Checking cloud-init output (last 30 lines)..."
& cmd /c "$sshBase `"sudo tail -30 /var/log/cloud-init-output.log`""
Write-Host ""

Write-Host "4. Checking running processes..."
& cmd /c "$sshBase `"ps aux | grep -E '(apt|dpkg|jenkins|setup)' | grep -v grep`""
Write-Host ""

Write-Host "Installation is still in progress..."
Write-Host "This typically takes 5-10 minutes for a fresh Ubuntu installation."
Write-Host "You can run this script periodically to monitor progress."
