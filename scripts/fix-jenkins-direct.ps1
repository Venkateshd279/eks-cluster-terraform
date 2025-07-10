# Direct SSH commands to fix Jenkins user configuration
param(
    [Parameter(Mandatory=$false)]
    [string]$KeyPath = "python.pem",
    
    [Parameter(Mandatory=$false)]
    [string]$JenkinsIP = "65.1.240.109"
)

Write-Host "=========================================="
Write-Host "Fixing Jenkins User via Direct SSH Commands"
Write-Host "=========================================="

$sshBase = "ssh -i $KeyPath -o StrictHostKeyChecking=no ec2-user@$JenkinsIP"

Write-Host "1. Setting up jenkins user shell and home directory..."
& cmd /c "$sshBase `"sudo usermod -s /bin/bash jenkins`""
& cmd /c "$sshBase `"sudo mkdir -p /var/lib/jenkins`""
& cmd /c "$sshBase `"sudo chown jenkins:jenkins /var/lib/jenkins`""
& cmd /c "$sshBase `"sudo chmod 755 /var/lib/jenkins`""

Write-Host "2. Creating .bashrc for jenkins user..."
$bashrcContent = @'
# .bashrc for jenkins user
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
export PATH=$PATH:/usr/local/bin:/opt/aws-cli/v2/current/bin
export KUBECONFIG=/var/lib/jenkins/.kube/config
complete -C '/opt/aws-cli/v2/current/bin/aws_completer' aws
if command -v kubectl &> /dev/null; then
    source <(kubectl completion bash)
fi
'@

$escapedBashrc = $bashrcContent -replace '"', '\"' -replace '`', '\`'
& cmd /c "$sshBase `"sudo bash -c 'cat > /var/lib/jenkins/.bashrc << EOF
$escapedBashrc
EOF'`""
& cmd /c "$sshBase `"sudo chown jenkins:jenkins /var/lib/jenkins/.bashrc`""

Write-Host "3. Creating .kube directory..."
& cmd /c "$sshBase `"sudo mkdir -p /var/lib/jenkins/.kube`""
& cmd /c "$sshBase `"sudo chown jenkins:jenkins /var/lib/jenkins/.kube`""
& cmd /c "$sshBase `"sudo chmod 700 /var/lib/jenkins/.kube`""

Write-Host "4. Installing kubectl if needed..."
& cmd /c "$sshBase `"which kubectl || (curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.28.3/2023-11-14/bin/linux/amd64/kubectl && chmod +x kubectl && sudo mv kubectl /usr/local/bin/)`""

Write-Host "5. Configuring EKS kubeconfig for jenkins user..."
& cmd /c "$sshBase `"sudo -u jenkins aws eks update-kubeconfig --region ap-south-1 --name my-eks-cluster --kubeconfig /var/lib/jenkins/.kube/config`""
& cmd /c "$sshBase `"sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config`""
& cmd /c "$sshBase `"sudo chmod 600 /var/lib/jenkins/.kube/config`""

Write-Host "6. Testing jenkins user configuration..."
& cmd /c "$sshBase `"sudo -u jenkins bash -c 'echo Current user: \$(whoami); echo Home: \$HOME; echo PATH: \$PATH'`""
& cmd /c "$sshBase `"sudo -u jenkins kubectl version --client`""
& cmd /c "$sshBase `"sudo -u jenkins kubectl get nodes`""

Write-Host ""
Write-Host "=========================================="
Write-Host "Jenkins user configuration completed!"
Write-Host "=========================================="
Write-Host ""
Write-Host "You can now test with:"
Write-Host "$sshBase"
Write-Host "sudo su - jenkins"
Write-Host "kubectl get nodes"
