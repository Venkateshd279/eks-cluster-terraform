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
