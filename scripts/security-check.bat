@echo off
REM Security Check Script for GitHub Push (Windows Batch Version)
REM This script checks for sensitive files before git push

echo 🔒 Security Check for GitHub Push
echo ==================================

echo Checking for sensitive files in git staging area...

REM Check if we're in a git repository
git status >nul 2>&1
if errorlevel 1 (
    echo ❌ Not a git repository or git not found!
    exit /b 1
)

REM List of sensitive file patterns to check
set "SENSITIVE_FILES=terraform.tfvars *.tfstate *.tfstate.* *.pem *.key credentials.* .env .aws/credentials terraform.tfstate.backup"

set "FOUND_SENSITIVE=0"

REM Check each pattern
for %%f in (%SENSITIVE_FILES%) do (
    git diff --cached --name-only | findstr /C:"%%f" >nul 2>&1
    if not errorlevel 1 (
        echo ❌ Found sensitive file in staging: %%f
        set "FOUND_SENSITIVE=1"
    )
)

if "%FOUND_SENSITIVE%"=="1" (
    echo.
    echo ❌ SECURITY WARNING: Sensitive files detected in staging area!
    echo Please unstage these files before pushing:
    echo   git reset HEAD ^<filename^>
    echo.
    echo Or add them to .gitignore if they should never be tracked.
    exit /b 1
) else (
    echo ✅ No sensitive files detected in staging area
)

REM Check if .gitignore exists
if exist ".gitignore" (
    echo ✅ .gitignore file exists
) else (
    echo ❌ .gitignore file not found!
    echo Please create a .gitignore file to protect sensitive data.
    exit /b 1
)

REM Check if terraform.tfvars.example exists
if exist "terraform.tfvars.example" (
    echo ✅ terraform.tfvars.example exists
) else (
    echo ⚠️  terraform.tfvars.example not found
    echo Consider creating an example file for safe sharing
)

echo 🎉 Security check passed! Safe to push to GitHub
echo Remember: Only push terraform.tfvars.example, never terraform.tfvars
exit /b 0
