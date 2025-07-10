# Generate Architecture Diagram - Setup and Execution Script
# This script installs required packages and generates visual architecture diagrams

Write-Host "🎨 EKS Architecture Diagram Generator" -ForegroundColor Green

# Check if Python is installed
Write-Host "`n📋 Checking Python installation..." -ForegroundColor Cyan
try {
    $pythonVersion = python --version 2>&1
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Python not found. Please install Python first." -ForegroundColor Red
    Write-Host "   Download from: https://www.python.org/downloads/" -ForegroundColor Yellow
    exit 1
}

# Check if pip is available
Write-Host "`n📋 Checking pip..." -ForegroundColor Cyan
try {
    $pipVersion = pip --version 2>&1
    Write-Host "✅ pip found: $pipVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ pip not found. Please ensure pip is installed with Python." -ForegroundColor Red
    exit 1
}

# Install required packages
Write-Host "`n📦 Installing required Python packages..." -ForegroundColor Cyan
$packages = @("matplotlib", "numpy")

foreach ($package in $packages) {
    Write-Host "Installing $package..." -ForegroundColor Yellow
    try {
        pip install $package --quiet
        Write-Host "✅ $package installed successfully" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to install $package" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Generate the diagram
Write-Host "`n🎨 Generating architecture diagrams..." -ForegroundColor Cyan

# Ensure docs/diagrams directory exists
if (-not (Test-Path "docs\diagrams")) {
    New-Item -ItemType Directory -Path "docs\diagrams" -Force | Out-Null
    Write-Host "✅ Created docs/diagrams directory" -ForegroundColor Green
}

try {
    python generate_architecture_diagram.py
    
    # Move generated files to docs/diagrams if they're in root
    $diagramFiles = @("EKS_Architecture_Diagram.png", "EKS_Architecture_Diagram.jpg", "EKS_Architecture_Diagram.pdf")
    foreach ($file in $diagramFiles) {
        if (Test-Path $file) {
            Move-Item $file "docs\diagrams\$file" -Force
            Write-Host "✅ Moved $file to docs/diagrams/" -ForegroundColor Green
        }
    }
    
    Write-Host "`n🎉 Diagrams generated successfully!" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to generate diagrams" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# List generated files
Write-Host "`n📁 Generated files in docs/diagrams/:" -ForegroundColor Cyan
$diagramFiles = @("EKS_Architecture_Diagram.png", "EKS_Architecture_Diagram.jpg", "EKS_Architecture_Diagram.pdf")

foreach ($file in $diagramFiles) {
    $fullPath = "docs\diagrams\$file"
    if (Test-Path $fullPath) {
        $fileSize = (Get-Item $fullPath).Length
        $fileSizeKB = [math]::Round($fileSize / 1KB, 2)
        Write-Host "✅ $file ($fileSizeKB KB)" -ForegroundColor Green
    } else {
        Write-Host "❌ $file not found" -ForegroundColor Red
    }
}

Write-Host "`n🌐 Alternative: Online Diagram Tools" -ForegroundColor Cyan
Write-Host "If you prefer online tools, you can use:" -ForegroundColor White
Write-Host "• Draw.io (diagrams.net) - Free online diagramming" -ForegroundColor Yellow
Write-Host "• Lucidchart - Professional diagramming" -ForegroundColor Yellow
Write-Host "• Visio Online - Microsoft diagramming" -ForegroundColor Yellow

Write-Host "`n📋 You can also use the detailed ASCII diagram in:" -ForegroundColor Cyan
Write-Host "   docs\ARCHITECTURE_DIAGRAM.md" -ForegroundColor White

Write-Host "`n✅ Architecture diagram generation completed!" -ForegroundColor Green
