# PowerShell script to fix Jenkins user configuration on the remote server
# Run this from your local machine

param(
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "~\.ssh\terraform-key.pem",
    
    [Parameter(Mandatory=$false)]
    [string]$JenkinsIP = "65.1.240.109"
)

Write-Host "=========================================="
Write-Host "Fixing Jenkins User Configuration Remote"
Write-Host "=========================================="

# Check if key file exists
if (-not (Test-Path $KeyPath)) {
    Write-Error "SSH key file not found at: $KeyPath"
    Write-Host "Please update the KeyPath parameter or ensure your SSH key is at the correct location"
    exit 1
}

Write-Host "Using SSH Key: $KeyPath"
Write-Host "Jenkins Server IP: $JenkinsIP"
Write-Host ""

# Copy the fix script to the server
Write-Host "1. Copying fix script to Jenkins server..."
scp -i $KeyPath -o StrictHostKeyChecking=no "scripts\fix-jenkins-user.sh" ec2-user@${JenkinsIP}:/tmp/

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to copy script to server"
    exit 1
}

# Execute the fix script on the server
Write-Host "2. Executing fix script on Jenkins server..."
ssh -i $KeyPath -o StrictHostKeyChecking=no ec2-user@$JenkinsIP @"
chmod +x /tmp/fix-jenkins-user.sh
sudo /tmp/fix-jenkins-user.sh
"@

if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to execute fix script on server"
    exit 1
}

Write-Host ""
Write-Host "=========================================="
Write-Host "Jenkins user fix completed!"
Write-Host "=========================================="
Write-Host ""
Write-Host "You can now SSH to the server and test:"
Write-Host "ssh -i $KeyPath ec2-user@$JenkinsIP"
Write-Host "sudo su - jenkins"
Write-Host "kubectl get nodes"
