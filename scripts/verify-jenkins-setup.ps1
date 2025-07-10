# Jenkins Setup Verification Script
# Run this to verify that Jenkins and EKS integration is working correctly

param(
    [Parameter(Mandatory=$false)]
    [string]$JenkinsIP = "13.204.60.118"
)

Write-Host "=========================================="
Write-Host "Jenkins Setup Verification"
Write-Host "=========================================="
Write-Host "Jenkins Server: $JenkinsIP"
Write-Host ""

$sshBase = "ssh -i python.pem -o StrictHostKeyChecking=no ubuntu@$JenkinsIP"

Write-Host "✅ 1. Jenkins Service Status"
& cmd /c "$sshBase `"sudo systemctl is-active jenkins`""
Write-Host ""

Write-Host "✅ 2. Jenkins User Configuration"
& cmd /c "$sshBase `"sudo su - jenkins -c 'whoami && pwd && echo \$SHELL'`""
Write-Host ""

Write-Host "✅ 3. AWS CLI Access"
& cmd /c "$sshBase `"sudo su - jenkins -c 'aws sts get-caller-identity'`""
Write-Host ""

Write-Host "✅ 4. kubectl Installation"
& cmd /c "$sshBase `"sudo su - jenkins -c 'kubectl version --client --output=yaml | grep gitVersion'`""
Write-Host ""

Write-Host "✅ 5. EKS Cluster Access"
& cmd /c "$sshBase `"sudo su - jenkins -c 'kubectl get nodes'`""
Write-Host ""

Write-Host "✅ 6. Jenkins Permissions Test"
& cmd /c "$sshBase `"sudo su - jenkins -c 'kubectl get namespaces | wc -l'`""
Write-Host ""

Write-Host "✅ 7. Docker Access"
& cmd /c "$sshBase `"sudo su - jenkins -c 'docker --version && groups'`""
Write-Host ""

Write-Host "=========================================="
Write-Host "Jenkins Access Information"
Write-Host "=========================================="
Write-Host "🌐 Jenkins Web UI: http://$JenkinsIP:8080"
Write-Host "🔐 SSH Access: $sshBase"
Write-Host "👤 Switch to jenkins user: sudo su - jenkins"
Write-Host "📋 EKS Cluster: my-eks-cluster (ap-south-1)"
Write-Host ""
Write-Host "Next Steps:"
Write-Host "1. Access Jenkins UI at http://$JenkinsIP:8080"
Write-Host "2. Install required plugins (if not already done)"
Write-Host "3. Create your first pipeline job"
Write-Host "4. Test deployment to EKS"
Write-Host "=========================================="
