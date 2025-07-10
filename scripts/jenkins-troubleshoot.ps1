# Jenkins Debug Script - Run this on the Jenkins server
# This script helps diagnose and fix Jenkins startup issues

Write-Host "Jenkins Troubleshooting Script" -ForegroundColor Green
Write-Host "==============================="

Write-Host "`nTo diagnose the Jenkins startup issue, SSH to your server and run these commands:" -ForegroundColor Yellow

Write-Host "`n1. Check Jenkins service status:" -ForegroundColor Cyan
Write-Host "sudo systemctl status jenkins" -ForegroundColor White

Write-Host "`n2. Check detailed logs:" -ForegroundColor Cyan
Write-Host "sudo journalctl -u jenkins -f" -ForegroundColor White

Write-Host "`n3. Check if Java is properly installed:" -ForegroundColor Cyan
Write-Host "java -version" -ForegroundColor White

Write-Host "`n4. Check Jenkins user and permissions:" -ForegroundColor Cyan
Write-Host "sudo ls -la /var/lib/jenkins/" -ForegroundColor White
Write-Host "id jenkins" -ForegroundColor White

Write-Host "`n5. Try to start Jenkins manually:" -ForegroundColor Cyan
Write-Host "sudo systemctl start jenkins" -ForegroundColor White
Write-Host "sudo systemctl enable jenkins" -ForegroundColor White

Write-Host "`n6. If Jenkins still fails, check configuration:" -ForegroundColor Cyan
Write-Host "sudo cat /etc/sysconfig/jenkins" -ForegroundColor White

Write-Host "`n7. Common fixes:" -ForegroundColor Cyan
Write-Host "# Fix permissions" -ForegroundColor White
Write-Host "sudo chown -R jenkins:jenkins /var/lib/jenkins" -ForegroundColor White
Write-Host "sudo chmod -R 755 /var/lib/jenkins" -ForegroundColor White
Write-Host "" 
Write-Host "# Restart Jenkins" -ForegroundColor White
Write-Host "sudo systemctl restart jenkins" -ForegroundColor White

Write-Host "`n8. Monitor Jenkins startup:" -ForegroundColor Cyan
Write-Host "sudo tail -f /var/log/jenkins/jenkins.log" -ForegroundColor White

Write-Host "`nConnect to your server:" -ForegroundColor Yellow
Write-Host "ssh -i python.pem ec2-user@65.1.240.109" -ForegroundColor Green
