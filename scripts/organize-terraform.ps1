# Terraform Files Organization Script
# This script moves all Terraform files into a dedicated terraform/ directory

Write-Host "📁 ORGANIZING TERRAFORM FILES" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path "main.tf")) {
    Write-Host "❌ Error: main.tf not found. Please run this script from the project root directory." -ForegroundColor Red
    exit 1
}

Write-Host "🔍 Current Terraform files found:" -ForegroundColor Yellow

# List of Terraform files to move
$TerraformFiles = @(
    "main.tf",
    "variables.tf", 
    "output.tf",
    "versions.tf",
    "backend.tf",
    "data.tf",
    "locals.tf",
    "jenkins-server.tf",
    "terraform.tfvars",
    "terraform.tfvars.example"
)

# List of Terraform directories/files to move
$TerraformAssets = @(
    ".terraform",
    ".terraform.lock.hcl",
    "terraform.tfstate",
    "terraform.tfstate.backup"
)

# Count existing files
$existingFiles = @()
foreach ($file in $TerraformFiles + $TerraformAssets) {
    if (Test-Path $file) {
        $existingFiles += $file
        Write-Host "  ✅ $file" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📋 Organization Plan:" -ForegroundColor Cyan
Write-Host "  • Create terraform/ directory" -ForegroundColor White
Write-Host "  • Move $($existingFiles.Count) Terraform files and assets" -ForegroundColor White
Write-Host "  • Update .gitignore for new structure" -ForegroundColor White
Write-Host "  • Create terraform/README.md with usage instructions" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Proceed with reorganization? (y/N)"

if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
    Write-Host ""
    Write-Host "🚀 REORGANIZING TERRAFORM FILES..." -ForegroundColor Green
    Write-Host "=================================" -ForegroundColor Green
    
    # Create terraform directory
    if (-not (Test-Path "terraform")) {
        New-Item -ItemType Directory -Path "terraform" | Out-Null
        Write-Host "✅ Created terraform/ directory" -ForegroundColor Green
    } else {
        Write-Host "⚠️  terraform/ directory already exists" -ForegroundColor Yellow
    }
    
    $movedCount = 0
    $failedCount = 0
    
    # Move Terraform files
    foreach ($file in $existingFiles) {
        if (Test-Path $file) {
            try {
                $destination = "terraform\$file"
                
                # Handle special cases for directories
                if ($file -eq ".terraform" -or $file -eq ".terraform.lock.hcl") {
                    if (Test-Path "terraform\$file") {
                        Remove-Item "terraform\$file" -Recurse -Force -ErrorAction SilentlyContinue
                    }
                }
                
                Move-Item $file $destination -Force -ErrorAction Stop
                Write-Host "✅ Moved: $file → terraform/$file" -ForegroundColor Green
                $movedCount++
            } catch {
                Write-Host "❌ Failed to move: $file - $($_.Exception.Message)" -ForegroundColor Red
                $failedCount++
            }
        }
    }
    
    Write-Host ""
    Write-Host "📝 CREATING TERRAFORM README..." -ForegroundColor Yellow
    
    # Create terraform/README.md
    $terraformReadme = @"
# 🏗️ Terraform Infrastructure

This directory contains all Terraform configuration files for the EKS infrastructure.

## 📁 Directory Structure

``````
terraform/
├── main.tf                    # Main infrastructure configuration
├── variables.tf               # Input variables
├── output.tf                  # Output values
├── versions.tf                # Provider version constraints
├── backend.tf                 # S3/DynamoDB backend configuration
├── data.tf                    # Data sources
├── locals.tf                  # Local values
├── jenkins-server.tf          # Jenkins server configuration (if exists)
├── terraform.tfvars           # Variable values (gitignored)
├── terraform.tfvars.example   # Example variable values
├── .terraform/                # Terraform working directory
├── .terraform.lock.hcl        # Provider version locks
├── terraform.tfstate          # Current state (if local)
└── terraform.tfstate.backup   # State backup (if local)
``````

## 🚀 Usage Instructions

### **Initial Setup**
``````bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply infrastructure
terraform apply
``````

### **Daily Operations**
``````bash
# Check infrastructure status
terraform show

# Update infrastructure
terraform plan
terraform apply

# Destroy infrastructure (when needed)
terraform destroy
``````

### **Configuration**
1. Copy ``terraform.tfvars.example`` to ``terraform.tfvars``
2. Update variables in ``terraform.tfvars`` with your values
3. Run ``terraform init`` to initialize
4. Run ``terraform plan`` to review changes
5. Run ``terraform apply`` to deploy

## 🔧 Backend Configuration

The infrastructure uses **S3 + DynamoDB** for remote state management:
- **S3 Bucket**: Stores Terraform state files
- **DynamoDB Table**: Provides state locking
- **Encryption**: State files are encrypted at rest

## 📊 Key Resources Created

- **EKS Cluster**: Kubernetes cluster with worker nodes
- **VPC**: Virtual Private Cloud with public/private subnets  
- **ALB**: Application Load Balancer for web traffic
- **EC2**: Web servers, app servers, Jenkins server
- **IAM**: Roles and policies for secure access
- **S3/DynamoDB**: Backend state management

## 🛡️ Security Features

- Private subnets for app servers and EKS workers
- Security groups with least privilege access
- IAM roles with minimal required permissions
- Encrypted storage and communication

## 📋 Common Commands

``````bash
# Format Terraform files
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List all resources
terraform state list

# Import existing resource
terraform import [resource_type].[name] [resource_id]

# Move state resource
terraform state mv [old_name] [new_name]
``````

## 🔍 Troubleshooting

**State Locked Error:**
``````bash
terraform force-unlock [LOCK_ID]
``````

**Provider Issues:**
``````bash
terraform init -upgrade
``````

**State Drift:**
``````bash
terraform refresh
terraform plan
``````

## 🌍 Multi-Environment Support

To manage multiple environments, use workspaces:
``````bash
# Create workspace
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod

# Switch workspace
terraform workspace select dev

# List workspaces
terraform workspace list
``````

---

## 📞 Support

For infrastructure issues:
1. Check ``terraform plan`` output
2. Review AWS CloudTrail logs
3. Check EKS cluster status
4. Verify IAM permissions

**Generated by Terraform organization script**
"@

    try {
        $terraformReadme | Out-File -FilePath "terraform\README.md" -Encoding UTF8
        Write-Host "✅ Created terraform/README.md with usage instructions" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to create terraform/README.md" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "📝 UPDATING PROJECT STRUCTURE..." -ForegroundColor Yellow
    
    # Update main README.md to reference new structure
    if (Test-Path "README.md") {
        try {
            $readmeContent = Get-Content "README.md" -Raw
            
            # Add note about Terraform directory
            $terraformNote = @"

## 📁 Project Structure

``````
eks-cluster-terraform/
├── terraform/                 # 🏗️ All Terraform infrastructure files
│   ├── main.tf               # Main configuration
│   ├── variables.tf          # Variables
│   └── README.md             # Terraform-specific documentation
├── scripts/                   # 🔧 Utility and demo scripts
├── k8s-apps/                  # ☸️ Kubernetes applications
├── cicd/                      # 🚀 CI/CD pipeline configuration
├── docs/                      # 📚 Architecture and demo guides
└── README.md                  # This file
``````

**Quick Start:**
1. ``cd terraform && terraform init && terraform apply``
2. Run demo: ``.\scripts\demo-live.ps1``
3. Access app: Check ``CUSTOMER_ACCESS_ARCHITECTURE.md``

"@
            
            # Insert after first heading if not already present
            if ($readmeContent -notmatch "## 📁 Project Structure") {
                $lines = $readmeContent -split "`n"
                $insertIndex = 1
                for ($i = 0; $i -lt $lines.Count; $i++) {
                    if ($lines[$i] -match "^#[^#]") {
                        $insertIndex = $i + 1
                        break
                    }
                }
                $lines = $lines[0..($insertIndex-1)] + $terraformNote.Split("`n") + $lines[$insertIndex..($lines.Count-1)]
                $lines -join "`n" | Out-File "README.md" -Encoding UTF8
                Write-Host "✅ Updated main README.md with new project structure" -ForegroundColor Green
            }
        } catch {
            Write-Host "⚠️  Could not update main README.md automatically" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "🎉 REORGANIZATION COMPLETE!" -ForegroundColor Green
    Write-Host "===========================" -ForegroundColor Green
    Write-Host "✅ Successfully moved: $movedCount files/directories" -ForegroundColor Green
    if ($failedCount -gt 0) {
        Write-Host "❌ Failed to move: $failedCount items" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "📁 NEW PROJECT STRUCTURE:" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    Write-Host "terraform/                 # 🏗️ All Terraform files" -ForegroundColor White
    Write-Host "├── main.tf                # Main infrastructure" -ForegroundColor Gray
    Write-Host "├── variables.tf           # Input variables" -ForegroundColor Gray
    Write-Host "├── output.tf              # Outputs" -ForegroundColor Gray
    Write-Host "├── backend.tf             # State backend" -ForegroundColor Gray
    Write-Host "├── terraform.tfvars       # Your variables" -ForegroundColor Gray
    Write-Host "└── README.md              # Terraform docs" -ForegroundColor Gray
    Write-Host ""
    Write-Host "scripts/                   # 🔧 Demo and utility scripts" -ForegroundColor White
    Write-Host "k8s-apps/                  # ☸️ Kubernetes applications" -ForegroundColor White
    Write-Host "cicd/                      # 🚀 CI/CD configuration" -ForegroundColor White
    Write-Host "docs/                      # 📚 Documentation" -ForegroundColor White
    
    Write-Host ""
    Write-Host "🚀 NEXT STEPS:" -ForegroundColor Cyan
    Write-Host "1. cd terraform" -ForegroundColor White
    Write-Host "2. terraform init" -ForegroundColor White
    Write-Host "3. terraform plan" -ForegroundColor White
    Write-Host "4. terraform apply" -ForegroundColor White
    
} else {
    Write-Host ""
    Write-Host "❌ Reorganization cancelled - No files moved" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "💡 TIP: All Terraform operations should now be run from the terraform/ directory" -ForegroundColor Cyan
