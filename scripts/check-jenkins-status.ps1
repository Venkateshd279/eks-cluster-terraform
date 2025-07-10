# Monitor Jenkins initialization status
param(
    [string]$JenkinsIP = "65.1.240.109",
    [string]$KeyFile = "python.pem"
)

Write-Host "Monitoring Jenkins initialization on $JenkinsIP..." -ForegroundColor Green
Write-Host "================================================================"

# Function to check if Jenkins is responding
function Check-Jenkins {
    try {
        $response = Invoke-WebRequest -Uri "http://$JenkinsIP:8080" -Method Head -TimeoutSec 5 -ErrorAction SilentlyContinue
        return $response.StatusCode
    }
    catch {
        return 0
    }
}

Write-Host "Checking web interface..." -ForegroundColor Yellow
$httpCode = Check-Jenkins

if ($httpCode -eq 200 -or $httpCode -eq 403) {
    Write-Host "✅ Jenkins is accessible! HTTP Code: $httpCode" -ForegroundColor Green
    Write-Host "🌐 Access Jenkins at: http://$JenkinsIP:8080" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "To get the initial admin password, SSH to the server:" -ForegroundColor Yellow
    Write-Host "ssh -i $KeyFile ec2-user@$JenkinsIP" -ForegroundColor White
    Write-Host "sudo cat /var/lib/jenkins/secrets/initialAdminPassword" -ForegroundColor White
}
else {
    Write-Host "⏳ Jenkins is still initializing... HTTP Code: $httpCode" -ForegroundColor Yellow
    Write-Host "Please wait a few more minutes and try again." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================================"
Write-Host "Manual commands to check status:" -ForegroundColor Cyan
Write-Host "SSH: ssh -i $KeyFile ec2-user@$JenkinsIP"
Write-Host "Check logs: sudo tail -f /var/log/jenkins-setup.log"
Write-Host "Check Jenkins service: sudo systemctl status jenkins"
Write-Host "Get initial password: sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
Write-Host ""
Write-Host "Expected initialization time: 5-10 minutes" -ForegroundColor Yellow
