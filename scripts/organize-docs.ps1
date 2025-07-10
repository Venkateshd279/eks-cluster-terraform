# Documentation Organization Script
# This script moves documentation files into a docs/ directory

Write-Host "📚 ORGANIZING DOCUMENTATION FILES" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Green
Write-Host ""

# List of documentation files to move
$DocFiles = @(
    "ARCHITECTURE_DIAGRAM.md",
    "ALL_ENDPOINTS_GUIDE.md", 
    "CUSTOMER_ACCESS_ARCHITECTURE.md",
    "CUSTOMER_ACCESS_GUIDE.md",
    "DEMO_GUIDE_FOR_MANAGER.md",
    "DEMO_QUICK_REFERENCE.md",
    "ENDPOINT_ACCESS_GUIDE.md",
    "BACKEND_SETUP.md",
    "CICD_SETUP_GUIDE.md",
    "DEPLOYMENT_SUCCESS_SUMMARY.md",
    "JENKINS_DEPLOY.md"
)

# Architecture diagram files
$DiagramFiles = @(
    "EKS_Architecture_Diagram.png",
    "EKS_Architecture_Diagram.jpg", 
    "EKS_Architecture_Diagram.pdf"
)

Write-Host "🔍 Documentation files found:" -ForegroundColor Yellow
$existingDocs = @()
foreach ($file in $DocFiles + $DiagramFiles) {
    if (Test-Path $file) {
        $existingDocs += $file
        Write-Host "  ✅ $file" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "📋 Organization Plan:" -ForegroundColor Cyan
Write-Host "  • Create docs/ directory" -ForegroundColor White
Write-Host "  • Create docs/diagrams/ subdirectory" -ForegroundColor White
Write-Host "  • Move $($existingDocs.Count) documentation files" -ForegroundColor White
Write-Host "  • Create docs/README.md with navigation" -ForegroundColor White
Write-Host ""

$confirmation = Read-Host "Proceed with documentation organization? (y/N)"

if ($confirmation -eq 'y' -or $confirmation -eq 'Y') {
    Write-Host ""
    Write-Host "🚀 ORGANIZING DOCUMENTATION..." -ForegroundColor Green
    Write-Host "=============================" -ForegroundColor Green
    
    # Create docs directory
    if (-not (Test-Path "docs")) {
        New-Item -ItemType Directory -Path "docs" | Out-Null
        Write-Host "✅ Created docs/ directory" -ForegroundColor Green
    }
    
    # Create diagrams subdirectory
    if (-not (Test-Path "docs\diagrams")) {
        New-Item -ItemType Directory -Path "docs\diagrams" | Out-Null
        Write-Host "✅ Created docs/diagrams/ directory" -ForegroundColor Green
    }
    
    $movedCount = 0
    
    # Move documentation files
    foreach ($file in $DocFiles) {
        if (Test-Path $file) {
            try {
                Move-Item $file "docs\$file" -Force -ErrorAction Stop
                Write-Host "✅ Moved: $file → docs/$file" -ForegroundColor Green
                $movedCount++
            } catch {
                Write-Host "❌ Failed to move: $file" -ForegroundColor Red
            }
        }
    }
    
    # Move diagram files
    foreach ($file in $DiagramFiles) {
        if (Test-Path $file) {
            try {
                Move-Item $file "docs\diagrams\$file" -Force -ErrorAction Stop
                Write-Host "✅ Moved: $file → docs/diagrams/$file" -ForegroundColor Green
                $movedCount++
            } catch {
                Write-Host "❌ Failed to move: $file" -ForegroundColor Red
            }
        }
    }
    
    # Create docs/README.md
    $docsReadme = @"
# 📚 Documentation

This directory contains all project documentation, guides, and architecture diagrams.

## 📋 Documentation Index

### 🎯 **Demo & Presentation Materials**
- **[Manager Demo Guide](DEMO_GUIDE_FOR_MANAGER.md)** - Complete presentation script
- **[Demo Quick Reference](DEMO_QUICK_REFERENCE.md)** - Quick reference for demo day
- **[Architecture Diagram](ARCHITECTURE_DIAGRAM.md)** - Text-based architecture

### 👥 **Customer Documentation** 
- **[Customer Access Architecture](CUSTOMER_ACCESS_ARCHITECTURE.md)** - How customers access the system
- **[Customer Access Guide](CUSTOMER_ACCESS_GUIDE.md)** - Customer usage instructions
- **[All Endpoints Guide](ALL_ENDPOINTS_GUIDE.md)** - Complete endpoint reference
- **[Endpoint Access Guide](ENDPOINT_ACCESS_GUIDE.md)** - Endpoint testing guide

### 🏗️ **Architecture & Infrastructure**
- **[Backend Setup](BACKEND_SETUP.md)** - S3/DynamoDB backend configuration
- **[CI/CD Setup Guide](CICD_SETUP_GUIDE.md)** - Jenkins pipeline setup
- **[Deployment Success Summary](DEPLOYMENT_SUCCESS_SUMMARY.md)** - Deployment overview
- **[Jenkins Deploy](JENKINS_DEPLOY.md)** - Jenkins configuration details

### 🎨 **Visual Diagrams**
All architecture diagrams are in the [diagrams/](diagrams/) directory:
- **PNG Format**: High-resolution for presentations
- **JPG Format**: Compressed for web use  
- **PDF Format**: Vector format for printing

## 🗂️ Directory Structure

``````
docs/
├── README.md                           # This navigation file
├── diagrams/                           # 🎨 Architecture diagrams
│   ├── EKS_Architecture_Diagram.png    # High-res PNG
│   ├── EKS_Architecture_Diagram.jpg    # Compressed JPG
│   └── EKS_Architecture_Diagram.pdf    # Vector PDF
├── DEMO_GUIDE_FOR_MANAGER.md           # 🎯 Manager presentation
├── DEMO_QUICK_REFERENCE.md             # 🎯 Demo reference card
├── CUSTOMER_ACCESS_ARCHITECTURE.md     # 👥 Customer access flow
├── CUSTOMER_ACCESS_GUIDE.md            # 👥 Customer instructions
├── ARCHITECTURE_DIAGRAM.md             # 🏗️ Text architecture
├── ALL_ENDPOINTS_GUIDE.md              # 🔗 All endpoints
└── [other documentation files]
``````

## 🚀 Quick Navigation

### **For Manager Presentations:**
1. Start with [Manager Demo Guide](DEMO_GUIDE_FOR_MANAGER.md)
2. Use [Demo Quick Reference](DEMO_QUICK_REFERENCE.md) during demo
3. Show [Architecture Diagrams](diagrams/) for visual impact

### **For Customer Onboarding:**
1. Share [Customer Access Guide](CUSTOMER_ACCESS_GUIDE.md)  
2. Provide [Customer Access Architecture](CUSTOMER_ACCESS_ARCHITECTURE.md)
3. Reference [All Endpoints Guide](ALL_ENDPOINTS_GUIDE.md)

### **For Technical Teams:**
1. Review [Architecture Diagram](ARCHITECTURE_DIAGRAM.md)
2. Check [Backend Setup](BACKEND_SETUP.md) for infrastructure
3. Follow [CI/CD Setup Guide](CICD_SETUP_GUIDE.md) for pipelines

## 📱 Usage Tips

- **Presentations**: Use PNG diagrams for best quality
- **Web/Email**: Use JPG diagrams for smaller file size
- **Printing**: Use PDF diagrams for crisp vector output
- **Quick Reference**: Keep Demo Quick Reference open during presentations

## 🔄 Keeping Documentation Updated

When infrastructure changes:
1. Update relevant documentation files
2. Regenerate architecture diagrams if needed
3. Test all demo scripts and update guides
4. Verify customer access instructions

---

**All documentation is version controlled and synced with infrastructure changes.**
"@

    try {
        $docsReadme | Out-File -FilePath "docs\README.md" -Encoding UTF8
        Write-Host "✅ Created docs/README.md with navigation" -ForegroundColor Green
        $movedCount++
    } catch {
        Write-Host "❌ Failed to create docs/README.md" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "🎉 DOCUMENTATION ORGANIZATION COMPLETE!" -ForegroundColor Green
    Write-Host "=======================================" -ForegroundColor Green
    Write-Host "✅ Successfully organized: $movedCount files" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "📁 NEW DOCUMENTATION STRUCTURE:" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    Write-Host "docs/" -ForegroundColor White
    Write-Host "├── README.md                    # 📋 Navigation index" -ForegroundColor Gray
    Write-Host "├── diagrams/" -ForegroundColor White
    Write-Host "│   ├── EKS_Architecture_Diagram.png" -ForegroundColor Gray
    Write-Host "│   ├── EKS_Architecture_Diagram.jpg" -ForegroundColor Gray
    Write-Host "│   └── EKS_Architecture_Diagram.pdf" -ForegroundColor Gray
    Write-Host "├── DEMO_GUIDE_FOR_MANAGER.md    # 🎯 Manager demo" -ForegroundColor Gray
    Write-Host "├── CUSTOMER_ACCESS_GUIDE.md     # 👥 Customer docs" -ForegroundColor Gray
    Write-Host "└── [other documentation files]" -ForegroundColor Gray
    
} else {
    Write-Host ""
    Write-Host "❌ Documentation organization cancelled" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "💡 TIP: Use docs/README.md as your documentation navigation hub" -ForegroundColor Cyan
