# Test Jenkins Pipeline Setup
# This script helps you verify that Jenkins can access the pipeline

Write-Host "Testing Jenkins Pipeline Setup..." -ForegroundColor Green

# Get Jenkins IP
$jenkinsIP = terraform output -raw jenkins_public_ip
Write-Host "Jenkins IP: $jenkinsIP" -ForegroundColor Yellow

# Test Jenkins accessibility
try {
    $response = Invoke-WebRequest -Uri "http://${jenkinsIP}:8080" -TimeoutSec 10 -UseBasicParsing
    Write-Host "✓ Jenkins is accessible at http://${jenkinsIP}:8080" -ForegroundColor Green
} catch {
    Write-Host "✗ Jenkins is not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

# Check if GitHub repo is accessible
try {
    $response = Invoke-WebRequest -Uri "https://github.com/Venkateshd279/eks-cluster-terraform" -TimeoutSec 10 -UseBasicParsing
    Write-Host "✓ GitHub repository is accessible" -ForegroundColor Green
} catch {
    Write-Host "✗ GitHub repository is not accessible: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`nNext Steps:" -ForegroundColor Cyan
Write-Host "1. Open http://${jenkinsIP}:8080 in your browser" -ForegroundColor White
Write-Host "2. Create a new Pipeline job named 'eks-ci-cd-pipeline'" -ForegroundColor White
Write-Host "3. Configure it to use GitHub repo: https://github.com/Venkateshd279/eks-cluster-terraform.git" -ForegroundColor White
Write-Host "4. Set Script Path to: Jenkinsfile" -ForegroundColor White
Write-Host "5. Save and run the pipeline" -ForegroundColor White

Write-Host "`nJenkinsfile Contents Preview:" -ForegroundColor Cyan
Write-Host "The pipeline will:" -ForegroundColor White
Write-Host "- Clone your GitHub repository" -ForegroundColor White
Write-Host "- Build Docker image using ECR" -ForegroundColor White
Write-Host "- Deploy to EKS cluster" -ForegroundColor White
Write-Host "- Use IAM role for AWS authentication (no credentials needed)" -ForegroundColor White
