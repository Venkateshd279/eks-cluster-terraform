# Fix Jenkins Docker Permission Issue
# This script resolves the "permission denied" error when Jenkins tries to access Docker

param(
    [string]$JenkinsServerIP = "",
    [string]$KeyPath = "python.pem"
)

Write-Host "🔧 Jenkins Docker Permission Fix" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

if (-not $JenkinsServerIP) {
    Write-Host "❌ Please provide Jenkins server IP address" -ForegroundColor Red
    Write-Host "Usage: .\fix-jenkins-docker-permission.ps1 -JenkinsServerIP 'your-jenkins-ip'" -ForegroundColor Yellow
    exit 1
}

# Check if key file exists
if (-not (Test-Path $KeyPath)) {
    Write-Host "❌ Key file '$KeyPath' not found" -ForegroundColor Red
    Write-Host "Please ensure the SSH key is in the current directory" -ForegroundColor Yellow
    exit 1
}

Write-Host "🔍 Connecting to Jenkins server: $JenkinsServerIP" -ForegroundColor Yellow

# Commands to fix Docker permission
$dockerFixCommands = @'
echo "🔧 Fixing Jenkins Docker permissions..."

# Check current user and groups
echo "Current user: $(whoami)"
echo "Current groups: $(groups)"

# Check if docker group exists
if ! getent group docker > /dev/null 2>&1; then
    echo "📦 Creating docker group..."
    sudo groupadd docker
else
    echo "✅ Docker group already exists"
fi

# Add jenkins user to docker group
echo "👤 Adding jenkins user to docker group..."
sudo usermod -aG docker jenkins

# Check if jenkins user is now in docker group
echo "✅ Jenkins user groups after adding to docker:"
sudo -u jenkins groups

# Change docker socket permissions (temporary fix)
echo "🔐 Setting Docker socket permissions..."
sudo chmod 666 /var/run/docker.sock

# Restart docker service
echo "🔄 Restarting Docker service..."
sudo systemctl restart docker

# Restart Jenkins service to pick up new group membership
echo "🔄 Restarting Jenkins service..."
sudo systemctl restart jenkins

# Wait for services to restart
echo "⏳ Waiting for services to restart..."
sleep 10

# Check Docker access for jenkins user
echo "🧪 Testing Docker access for jenkins user..."
sudo -u jenkins docker --version
sudo -u jenkins docker ps

echo "✅ Docker permission fix completed!"
echo "📋 Summary:"
echo "  - Added jenkins user to docker group"
echo "  - Set Docker socket permissions"
echo "  - Restarted Docker and Jenkins services"
echo ""
echo "🚀 You can now run the Jenkins pipeline again!"
'@

try {
    # Execute commands on Jenkins server
    Write-Host "📤 Executing Docker permission fix commands..." -ForegroundColor Yellow
    
    # Use SSH to connect and execute commands
    $sshCommand = "ssh -i `"$KeyPath`" -o StrictHostKeyChecking=no ubuntu@$JenkinsServerIP"
    
    # Write commands to temporary file
    $tempScript = "temp_docker_fix.sh"
    $dockerFixCommands | Out-File -FilePath $tempScript -Encoding ASCII
    
    # Copy script to server and execute
    Write-Host "📋 Copying fix script to server..." -ForegroundColor Gray
    & scp -i $KeyPath -o StrictHostKeyChecking=no $tempScript ubuntu@${JenkinsServerIP}:~/docker_fix.sh
    
    Write-Host "⚙️ Executing fix script on server..." -ForegroundColor Gray
    & $sshCommand "chmod +x ~/docker_fix.sh && ~/docker_fix.sh"
    
    # Clean up
    Remove-Item $tempScript -ErrorAction SilentlyContinue
    
    Write-Host ""
    Write-Host "✅ Docker permission fix completed successfully!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 Next Steps:" -ForegroundColor Cyan
    Write-Host "1. Wait 1-2 minutes for services to fully restart" -ForegroundColor Gray
    Write-Host "2. Go to Jenkins and run 'Build Now' again" -ForegroundColor Gray
    Write-Host "3. Monitor the console output for the Docker build stage" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Error executing Docker permission fix: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Manual Fix Instructions:" -ForegroundColor Yellow
    Write-Host "1. SSH into your Jenkins server:" -ForegroundColor Gray
    Write-Host "   ssh -i $KeyPath ubuntu@$JenkinsServerIP" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Run these commands manually:" -ForegroundColor Gray
    Write-Host "   sudo usermod -aG docker jenkins" -ForegroundColor Gray
    Write-Host "   sudo chmod 666 /var/run/docker.sock" -ForegroundColor Gray
    Write-Host "   sudo systemctl restart docker" -ForegroundColor Gray
    Write-Host "   sudo systemctl restart jenkins" -ForegroundColor Gray
    Write-Host ""
    Write-Host "3. Test Docker access:" -ForegroundColor Gray
    Write-Host "   sudo -u jenkins docker --version" -ForegroundColor Gray
}

Write-Host ""
Write-Host "📞 If issues persist, check:" -ForegroundColor Cyan
Write-Host "- Jenkins service status: sudo systemctl status jenkins" -ForegroundColor Gray
Write-Host "- Docker service status: sudo systemctl status docker" -ForegroundColor Gray
Write-Host "- Jenkins user groups: sudo -u jenkins groups" -ForegroundColor Gray
