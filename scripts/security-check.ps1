# Security Check Script for GitHub Push (PowerShell Version)
# This script checks for sensitive files before git push

param(
    [switch]$Verbose
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $colorMap = @{
        "Red" = "Red"
        "Green" = "Green"
        "Yellow" = "Yellow"
        "Blue" = "Blue"
        "White" = "White"
    }
    
    Write-Host $Message -ForegroundColor $colorMap[$Color]
}

Write-ColorOutput "🔒 Security Check for GitHub Push" "Blue"
Write-ColorOutput "==================================" "Blue"
Write-Host ""

Write-ColorOutput "Checking for sensitive files in git staging area..." "White"

# Check if we're in a git repository
try {
    $gitStatus = git status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput "❌ Not a git repository or git not found!" "Red"
        exit 1
    }
} catch {
    Write-ColorOutput "❌ Not a git repository or git not found!" "Red"
    exit 1
}

# List of sensitive file patterns to check
$sensitivePatterns = @(
    "terraform.tfvars",
    "*.tfstate",
    "*.tfstate.*",
    "*.pem",
    "*.key",
    "credentials.*",
    ".env",
    ".aws/credentials",
    "terraform.tfstate.backup"
)

$foundSensitive = $false

# Get staged files
$stagedFiles = git diff --cached --name-only 2>&1

if ($stagedFiles -and $LASTEXITCODE -eq 0) {
    foreach ($pattern in $sensitivePatterns) {
        $matchingFiles = $stagedFiles | Where-Object { $_ -like $pattern }
        if ($matchingFiles) {
            foreach ($file in $matchingFiles) {
                Write-ColorOutput "❌ Found sensitive file in staging: $file" "Red"
                $foundSensitive = $true
            }
        }
    }
}

if ($foundSensitive) {
    Write-Host ""
    Write-ColorOutput "❌ SECURITY WARNING: Sensitive files detected in staging area!" "Red"
    Write-ColorOutput "Please unstage these files before pushing:" "Yellow"
    Write-ColorOutput "  git reset HEAD <filename>" "Yellow"
    Write-Host ""
    Write-ColorOutput "Or add them to .gitignore if they should never be tracked." "Yellow"
    exit 1
} else {
    Write-ColorOutput "✅ No sensitive files detected in staging area" "Green"
}

# Check if .gitignore exists
if (Test-Path ".gitignore") {
    Write-ColorOutput "✅ .gitignore file exists" "Green"
} else {
    Write-ColorOutput "❌ .gitignore file not found!" "Red"
    Write-ColorOutput "Please create a .gitignore file to protect sensitive data." "Yellow"
    exit 1
}

# Check if terraform.tfvars.example exists
if (Test-Path "terraform.tfvars.example") {
    Write-ColorOutput "✅ terraform.tfvars.example exists" "Green"
} else {
    Write-ColorOutput "⚠️  terraform.tfvars.example not found" "Yellow"
    Write-ColorOutput "Consider creating an example file for safe sharing" "Yellow"
}

Write-Host ""
Write-ColorOutput "🎉 Security check passed! Safe to push to GitHub" "Green"
Write-ColorOutput "Remember: Only push terraform.tfvars.example, never terraform.tfvars" "Yellow"

if ($Verbose) {
    Write-Host ""
    Write-ColorOutput "Verbose: Checked patterns:" "Blue"
    foreach ($pattern in $sensitivePatterns) {
        Write-ColorOutput "  - $pattern" "Blue"
    }
}

exit 0
