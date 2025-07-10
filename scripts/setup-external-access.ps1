# Install AWS Load Balancer Controller for External Access
# This script installs the AWS Load Balancer Controller to enable external web access

Write-Host "🌐 Setting up External Web Access for EKS Application" -ForegroundColor Green

# Get cluster info
$clusterName = "my-eks-cluster"
$region = "ap-south-1"
$accountId = (aws sts get-caller-identity --query Account --output text)

Write-Host "Cluster: $clusterName" -ForegroundColor Yellow
Write-Host "Region: $region" -ForegroundColor Yellow
Write-Host "Account ID: $accountId" -ForegroundColor Yellow

# Step 1: Download IAM policy
Write-Host "`n📋 Step 1: Downloading AWS Load Balancer Controller IAM policy..." -ForegroundColor Cyan
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.4.4/docs/install/iam_policy.json

# Step 2: Create IAM policy
Write-Host "📋 Step 2: Creating IAM policy..." -ForegroundColor Cyan
try {
    aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
    Write-Host "✅ IAM policy created successfully" -ForegroundColor Green
} catch {
    Write-Host "⚠️  IAM policy might already exist, continuing..." -ForegroundColor Yellow
}

# Step 3: Create service account
Write-Host "📋 Step 3: Creating service account with IAM role..." -ForegroundColor Cyan
$policyArn = "arn:aws:iam::${accountId}:policy/AWSLoadBalancerControllerIAMPolicy"

eksctl create iamserviceaccount `
    --cluster=$clusterName `
    --namespace=kube-system `
    --name=aws-load-balancer-controller `
    --role-name AmazonEKSLoadBalancerControllerRole `
    --attach-policy-arn=$policyArn `
    --approve `
    --region=$region

# Step 4: Install AWS Load Balancer Controller using Helm
Write-Host "📋 Step 4: Installing AWS Load Balancer Controller..." -ForegroundColor Cyan

# Add helm repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install the controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller `
    -n kube-system `
    --set clusterName=$clusterName `
    --set serviceAccount.create=false `
    --set serviceAccount.name=aws-load-balancer-controller `
    --set region=$region `
    --set vpcId=(aws ec2 describe-vpcs --filters "Name=tag:Name,Values=*eks*" --query "Vpcs[0].VpcId" --output text)

Write-Host "✅ AWS Load Balancer Controller installation completed!" -ForegroundColor Green

# Step 5: Wait for controller to be ready
Write-Host "📋 Step 5: Waiting for controller to be ready..." -ForegroundColor Cyan
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=aws-load-balancer-controller -n kube-system --timeout=300s

# Step 6: Check controller status
Write-Host "📋 Step 6: Checking controller status..." -ForegroundColor Cyan
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller

# Step 7: Restart ingress to get external IP
Write-Host "📋 Step 7: Restarting ingress to get external IP..." -ForegroundColor Cyan
kubectl delete ingress sample-web-app-ingress -n sample-apps
kubectl apply -f k8s-apps/sample-web-app/ingress.yaml

Write-Host "`n⏳ Waiting for Load Balancer to provision..." -ForegroundColor Yellow
Write-Host "This may take 2-3 minutes..." -ForegroundColor Yellow

# Monitor ingress for external IP
$timeout = 180
$elapsed = 0
do {
    Start-Sleep -Seconds 10
    $elapsed += 10
    $ingressStatus = kubectl get ingress sample-web-app-ingress -n sample-apps -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>$null
    if ($ingressStatus) {
        Write-Host "🎉 External URL available: http://$ingressStatus" -ForegroundColor Green
        break
    }
    Write-Host "Still waiting... ($elapsed seconds)" -ForegroundColor Yellow
} while ($elapsed -lt $timeout)

if (-not $ingressStatus) {
    Write-Host "⏰ Timeout waiting for external URL. Check manually with:" -ForegroundColor Yellow
    Write-Host "kubectl get ingress -n sample-apps" -ForegroundColor White
} else {
    Write-Host "`n🌐 Your application is now accessible at:" -ForegroundColor Green
    Write-Host "http://$ingressStatus" -ForegroundColor Cyan
    Write-Host "`n✅ Setup completed successfully!" -ForegroundColor Green
}

# Cleanup
Remove-Item iam_policy.json -ErrorAction SilentlyContinue
