#!/bin/bash
# Git Pre-Push Hook Setup Script
# This script sets up a git pre-push hook to automatically run security checks

echo "🔧 Setting up Git Pre-Push Hook for Security"
echo "==========================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository root directory"
    echo "Please run this script from the repository root"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Check if hook already exists
if [ -f ".git/hooks/pre-push" ]; then
    echo "⚠️  Pre-push hook already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled"
        exit 1
    fi
fi

# Copy the hook content
cat > .git/hooks/pre-push << 'EOF'
#!/bin/bash
# Pre-push hook to run security check
# This prevents pushing sensitive files to GitHub

echo "🔒 Running security check before push..."
bash scripts/security-check.sh

if [ $? -ne 0 ]; then
    echo "❌ Push aborted due to security check failure."
    echo "Fix the issues above and try again."
    exit 1
fi

echo "✅ Security check passed. Proceeding with push..."
exit 0
EOF

# Make the hook executable
chmod +x .git/hooks/pre-push

echo "✅ Git pre-push hook installed successfully!"
echo ""
echo "Now the security check will run automatically before every git push."
echo "To test it, try: git push --dry-run"
echo ""
echo "To disable temporarily: git push --no-verify"
echo "To remove: rm .git/hooks/pre-push"
