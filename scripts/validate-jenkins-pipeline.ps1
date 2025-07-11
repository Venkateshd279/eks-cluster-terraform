# Jenkins Pipeline Validation Script
# This script helps validate that Jenkins is properly configured for the EKS pipeline

param(
    [string]$JenkinsUrl = "http://localhost:8080",
    [string]$JenkinsUser = "",
    [string]$JenkinsToken = ""
)

Write-Host "🔍 Jenkins Pipeline Validation Script" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Function to check if a command exists
function Test-Command {
    param($Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Function to make Jenkins API calls
function Invoke-JenkinsAPI {
    param(
        [string]$Endpoint,
        [string]$Method = "GET"
    )
    
    try {
        $headers = @{}
        if ($JenkinsUser -and $JenkinsToken) {
            $auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${JenkinsUser}:${JenkinsToken}"))
            $headers["Authorization"] = "Basic $auth"
        }
        
        $response = Invoke-RestMethod -Uri "$JenkinsUrl$Endpoint" -Method $Method -Headers $headers
        return $response
    }
    catch {
        Write-Host "❌ API call failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# 1. Check Jenkins Connectivity
Write-Host "`n1. Checking Jenkins Connectivity..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $JenkinsUrl -UseBasicParsing -TimeoutSec 10
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Jenkins is accessible at $JenkinsUrl" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Jenkins returned status code: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Cannot reach Jenkins at $JenkinsUrl" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# 2. Check Required Tools on Jenkins Server
Write-Host "`n2. Checking Required Tools..." -ForegroundColor Yellow

$requiredTools = @(
    @{Name="AWS CLI"; Command="aws"; Version="--version"},
    @{Name="kubectl"; Command="kubectl"; Version="version --client"},
    @{Name="Docker"; Command="docker"; Version="--version"},
    @{Name="Git"; Command="git"; Version="--version"}
)

foreach ($tool in $requiredTools) {
    if (Test-Command $tool.Command) {
        Write-Host "✅ $($tool.Name) is installed" -ForegroundColor Green
        try {
            $version = & $tool.Command $tool.Version.Split() 2>&1
            Write-Host "   Version: $($version[0])" -ForegroundColor Gray
        } catch {
            Write-Host "   Could not get version info" -ForegroundColor Gray
        }
    } else {
        Write-Host "❌ $($tool.Name) is not installed or not in PATH" -ForegroundColor Red
    }
}

# 3. Check Jenkins Plugins
Write-Host "`n3. Checking Jenkins Plugins..." -ForegroundColor Yellow

$requiredPlugins = @(
    "workflow-aggregator",  # Pipeline
    "git",                  # Git
    "pipeline-aws",         # AWS Steps
    "docker-workflow",      # Docker Pipeline
    "kubernetes"            # Kubernetes
)

if ($JenkinsUser -and $JenkinsToken) {
    $plugins = Invoke-JenkinsAPI -Endpoint "/pluginManager/api/json?depth=1"
    if ($plugins) {
        foreach ($pluginName in $requiredPlugins) {
            $plugin = $plugins.plugins | Where-Object { $_.shortName -eq $pluginName }
            if ($plugin) {
                if ($plugin.enabled) {
                    Write-Host "✅ Plugin '$pluginName' is installed and enabled" -ForegroundColor Green
                } else {
                    Write-Host "⚠️ Plugin '$pluginName' is installed but disabled" -ForegroundColor Yellow
                }
            } else {
                Write-Host "❌ Plugin '$pluginName' is not installed" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "⚠️ Cannot check plugins (API access required)" -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️ Cannot check plugins (credentials required)" -ForegroundColor Yellow
    Write-Host "   Provide -JenkinsUser and -JenkinsToken to check plugins" -ForegroundColor Gray
}

# 4. Check AWS Configuration
Write-Host "`n4. Checking AWS Configuration..." -ForegroundColor Yellow

try {
    $awsConfig = aws configure list 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ AWS CLI is configured" -ForegroundColor Green
        $awsConfig | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    } else {
        Write-Host "⚠️ AWS CLI configuration issues" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Cannot check AWS configuration" -ForegroundColor Red
}

# Check AWS identity
try {
    $identity = aws sts get-caller-identity 2>&1
    if ($LASTEXITCODE -eq 0) {
        $identityJson = $identity | ConvertFrom-Json
        Write-Host "✅ AWS Identity verified" -ForegroundColor Green
        Write-Host "   Account: $($identityJson.Account)" -ForegroundColor Gray
        Write-Host "   User/Role: $($identityJson.Arn)" -ForegroundColor Gray
    } else {
        Write-Host "⚠️ Cannot verify AWS identity" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ AWS identity check failed" -ForegroundColor Red
}

# 5. Check EKS Cluster Access
Write-Host "`n5. Checking EKS Cluster Access..." -ForegroundColor Yellow

$clusterName = "my-eks-cluster"
$region = "ap-south-1"

try {
    $clusters = aws eks list-clusters --region $region 2>&1
    if ($LASTEXITCODE -eq 0) {
        $clustersJson = $clusters | ConvertFrom-Json
        if ($clustersJson.clusters -contains $clusterName) {
            Write-Host "✅ EKS cluster '$clusterName' found" -ForegroundColor Green
            
            # Update kubeconfig
            aws eks update-kubeconfig --region $region --name $clusterName 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ kubeconfig updated successfully" -ForegroundColor Green
                
                # Test kubectl access
                $nodes = kubectl get nodes --no-headers 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "✅ kubectl can access the cluster" -ForegroundColor Green
                    Write-Host "   Nodes: $($nodes.Count)" -ForegroundColor Gray
                } else {
                    Write-Host "⚠️ kubectl cannot access the cluster" -ForegroundColor Yellow
                }
            } else {
                Write-Host "⚠️ Failed to update kubeconfig" -ForegroundColor Yellow
            }
        } else {
            Write-Host "❌ EKS cluster '$clusterName' not found" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️ Cannot list EKS clusters" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ EKS cluster check failed" -ForegroundColor Red
}

# 6. Check ECR Repository
Write-Host "`n6. Checking ECR Repository..." -ForegroundColor Yellow

$repoName = "sample-web-app"
$accountId = "897722681721"

try {
    $repos = aws ecr describe-repositories --repository-names $repoName --region $region 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ ECR repository '$repoName' exists" -ForegroundColor Green
        $reposJson = $repos | ConvertFrom-Json
        Write-Host "   Repository URI: $($reposJson.repositories[0].repositoryUri)" -ForegroundColor Gray
    } else {
        Write-Host "⚠️ ECR repository '$repoName' not found" -ForegroundColor Yellow
        Write-Host "   It will be created automatically during the pipeline" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ ECR repository check failed" -ForegroundColor Red
}

# 7. Check Project Structure
Write-Host "`n7. Checking Project Structure..." -ForegroundColor Yellow

$projectFiles = @(
    "k8s-apps\sample-web-app\Jenkinsfile",
    "k8s-apps\sample-web-app\Dockerfile",
    "k8s-apps\sample-web-app\deployment-ecr.yaml",
    "k8s-apps\sample-web-app\service.yaml",
    "k8s-apps\sample-web-app\ingress.yaml",
    "k8s-apps\sample-web-app\namespace.yaml",
    "k8s-apps\sample-web-app\configmap.yaml"
)

foreach ($file in $projectFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file exists" -ForegroundColor Green
    } else {
        Write-Host "❌ $file is missing" -ForegroundColor Red
    }
}

# 8. Pipeline Configuration Recommendations
Write-Host "`n8. Pipeline Configuration Recommendations..." -ForegroundColor Yellow

Write-Host "📋 Jenkins Pipeline Job Configuration:" -ForegroundColor Cyan
Write-Host "   Job Name: eks-sample-web-app-pipeline" -ForegroundColor Gray
Write-Host "   Job Type: Pipeline" -ForegroundColor Gray
Write-Host "   Definition: Pipeline script from SCM" -ForegroundColor Gray
Write-Host "   SCM: Git" -ForegroundColor Gray
Write-Host "   Repository URL: [Your GitHub repository URL]" -ForegroundColor Gray
Write-Host "   Branch: */main" -ForegroundColor Gray
Write-Host "   Script Path: k8s-apps/sample-web-app/Jenkinsfile" -ForegroundColor Yellow

Write-Host "`n📋 Required Credentials in Jenkins:" -ForegroundColor Cyan
Write-Host "   - AWS Credentials (ID: aws-credentials)" -ForegroundColor Gray
Write-Host "   - GitHub Credentials (ID: github-credentials) [if private repo]" -ForegroundColor Gray

# Summary
Write-Host "`n🎯 Validation Summary" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "✅ Green items are properly configured" -ForegroundColor Green
Write-Host "⚠️ Yellow items need attention but may work" -ForegroundColor Yellow  
Write-Host "❌ Red items need to be fixed before running the pipeline" -ForegroundColor Red

Write-Host "`n📚 For detailed setup instructions, see:" -ForegroundColor Cyan
Write-Host "   docs\JENKINS_PIPELINE_SETUP.md" -ForegroundColor Gray

Write-Host "`n🚀 Ready to run the pipeline?" -ForegroundColor Cyan
Write-Host "   1. Create the Jenkins job using the configuration above" -ForegroundColor Gray
Write-Host "   2. Configure the required credentials" -ForegroundColor Gray
Write-Host "   3. Run the pipeline and monitor the results" -ForegroundColor Gray
