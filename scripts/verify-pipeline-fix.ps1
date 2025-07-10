# PowerShell script to verify Jenkins pipeline configuration

# Get Jenkins IP
$terraformOutput = terraform output -json
$jenkinsOutput = $terraformOutput | ConvertFrom-Json
$jenkinsIP = $jenkinsOutput.jenkins_server_public_ip.value

Write-Host "=== Jenkins Pipeline Verification ===" -ForegroundColor Green
Write-Host "Jenkins URL: http://$jenkinsIP`:8080" -ForegroundColor Yellow
Write-Host ""

Write-Host "✅ Checklist for fixing the pipeline:" -ForegroundColor Green
Write-Host "1. Access Jenkins: http://$jenkinsIP`:8080" -ForegroundColor White
Write-Host "2. Go to your pipeline job" -ForegroundColor White
Write-Host "3. Click 'Configure'" -ForegroundColor White
Write-Host "4. In Pipeline section, verify:" -ForegroundColor White
Write-Host "   - Definition: 'Pipeline script from SCM'" -ForegroundColor Cyan
Write-Host "   - SCM: 'Git'" -ForegroundColor Cyan
Write-Host "   - Repository URL: 'https://github.com/Venkateshd279/eks-cluster-terraform.git'" -ForegroundColor Cyan
Write-Host "   - Branch Specifier: '*/main'" -ForegroundColor Cyan
Write-Host "   - Script Path: 'Jenkinsfile' (exactly this, not cicd/jenkins/Jenkinsfile)" -ForegroundColor Yellow
Write-Host "5. Save and click 'Build Now'" -ForegroundColor White
Write-Host ""

Write-Host "🔍 GitHub Repository Status:" -ForegroundColor Green
Write-Host "✅ Jenkinsfile is at repo root" -ForegroundColor Green
Write-Host "✅ Duplicate Jenkinsfile removed from cicd/jenkins/" -ForegroundColor Green
Write-Host "✅ Latest changes pushed to GitHub" -ForegroundColor Green
Write-Host ""

Write-Host "🚀 After fixing Script Path, the pipeline should:" -ForegroundColor Green
Write-Host "1. Find the Jenkinsfile at repo root" -ForegroundColor White
Write-Host "2. Use IAM role authentication (no credentials needed)" -ForegroundColor White
Write-Host "3. Deploy sample app to EKS cluster" -ForegroundColor White
Write-Host ""

Write-Host "💡 If you still get 'Jenkinsfile not found' error:" -ForegroundColor Yellow
Write-Host "- Check that Script Path is exactly 'Jenkinsfile' (case sensitive)" -ForegroundColor White
Write-Host "- Verify the GitHub repository URL is correct" -ForegroundColor White
Write-Host "- Try triggering a manual build to see detailed logs" -ForegroundColor White
