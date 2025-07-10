#!/bin/bash
# Security check script for GitHub push
# Run this before every git push to ensure no sensitive data

echo "🔒 Security Check for GitHub Push"
echo "=================================="

# Check if sensitive files are staged
echo "Checking for sensitive files in git staging area..."

sensitive_files=(
    "terraform.tfvars"
    "*.tfstate"
    "*.tfstate.backup"
    "*.pem"
    "*.key"
    "aws-credentials.json"
    ".env"
)

found_sensitive=false

for pattern in "${sensitive_files[@]}"; do
    if git diff --cached --name-only | grep -E "$pattern" > /dev/null; then
        echo "❌ DANGER: Found sensitive file staged: $pattern"
        found_sensitive=true
    fi
done

if [ "$found_sensitive" = true ]; then
    echo ""
    echo "🚨 SECURITY ALERT: Sensitive files detected!"
    echo "Run: git reset HEAD <filename> to unstage sensitive files"
    echo "Never commit sensitive data to version control!"
    exit 1
else
    echo "✅ No sensitive files detected in staging area"
fi

# Check if .gitignore exists and covers key patterns
if [ ! -f ".gitignore" ]; then
    echo "❌ No .gitignore file found!"
    exit 1
fi

echo "✅ .gitignore file exists"

# Check terraform.tfvars.example exists
if [ ! -f "terraform.tfvars.example" ]; then
    echo "❌ terraform.tfvars.example not found!"
    echo "Create an example file without sensitive data"
    exit 1
fi

echo "✅ terraform.tfvars.example exists"

echo ""
echo "🎉 Security check passed! Safe to push to GitHub"
echo "Remember: Only push terraform.tfvars.example, never terraform.tfvars"
