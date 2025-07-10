# Fix Jenkins EKS Access
param(
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "python.pem",
    
    [Parameter(Mandatory=$false)]
    [string]$JenkinsIP = "13.204.60.118"
)

Write-Host "=========================================="
Write-Host "Fixing Jenkins EKS Access"
Write-Host "=========================================="

$sshBase = "ssh -i $KeyPath -o StrictHostKeyChecking=no ubuntu@$JenkinsIP"

Write-Host "1. Checking current kubeconfig for jenkins user..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'ls -la ~/.kube/ && cat ~/.kube/config 2>/dev/null || echo No kubeconfig found'`""
Write-Host ""

Write-Host "2. Recreating kubeconfig for jenkins user..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster'`""
Write-Host ""

Write-Host "3. Verifying kubeconfig was created..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'ls -la ~/.kube/ && head -10 ~/.kube/config'`""
Write-Host ""

Write-Host "4. Testing kubectl version and cluster info..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'kubectl version --client && kubectl cluster-info'`""
Write-Host ""

Write-Host "5. Testing EKS nodes access..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'kubectl get nodes'`""
Write-Host ""

Write-Host "6. Testing basic kubectl commands..."
& cmd /c "$sshBase `"sudo su - jenkins -c 'kubectl get namespaces && kubectl get pods --all-namespaces'`""
Write-Host ""

Write-Host "If EKS access still fails, we may need to check:"
Write-Host "- EKS cluster endpoint access"
Write-Host "- IAM role permissions"
Write-Host "- Security group rules"
