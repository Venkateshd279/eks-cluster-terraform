# Setup Customer-Friendly Domain for Your Application
# This script helps you configure a proper domain for customer access

Write-Host "🌐 Setting Up Customer-Friendly Domain Access" -ForegroundColor Green

# Get current ALB DNS name
$albDNS = terraform output -raw web_alb_dns_name
Write-Host "Current ALB DNS: $albDNS" -ForegroundColor Yellow

Write-Host "`n📋 Customer Access Setup Options:" -ForegroundColor Cyan

Write-Host "`n1️⃣ IMMEDIATE (Current Working URL):" -ForegroundColor White
Write-Host "   http://$albDNS" -ForegroundColor Green
Write-Host "   Status: ✅ Working now for customers" -ForegroundColor Green

Write-Host "`n2️⃣ RECOMMENDED (Custom Domain Setup):" -ForegroundColor White
Write-Host "   https://your-app.com → $albDNS" -ForegroundColor Cyan
Write-Host "   Benefits: Professional, memorable, HTTPS" -ForegroundColor White

Write-Host "`n3️⃣ ENTERPRISE (Full Production Setup):" -ForegroundColor White
Write-Host "   https://app.your-domain.com (Main app)" -ForegroundColor Cyan
Write-Host "   https://api.your-domain.com (API access)" -ForegroundColor Cyan
Write-Host "   https://admin.your-domain.com (Admin panel)" -ForegroundColor Cyan

Write-Host "`n🛡️ Security Layers for Customer Access:" -ForegroundColor Magenta
Write-Host "   ✅ WAF (Web Application Firewall)" -ForegroundColor Green
Write-Host "   ✅ SSL/TLS Certificates" -ForegroundColor Green
Write-Host "   ✅ CloudFront CDN" -ForegroundColor Green
Write-Host "   ✅ Rate Limiting" -ForegroundColor Green

Write-Host "`n📱 Customer Access Methods:" -ForegroundColor Cyan
Write-Host "   🌐 Web Browser: Direct access via URL" -ForegroundColor White
Write-Host "   📱 Mobile App: API calls to your domain" -ForegroundColor White
Write-Host "   🔗 API Integration: RESTful API access" -ForegroundColor White

Write-Host "`n🚫 What Customers Should NEVER Access:" -ForegroundColor Red
Write-Host "   ❌ App servers directly (10.0.10.176, 10.0.11.29)" -ForegroundColor Red
Write-Host "   ❌ Individual web servers by IP" -ForegroundColor Red
Write-Host "   ❌ EKS worker nodes" -ForegroundColor Red
Write-Host "   ❌ Jenkins or admin servers" -ForegroundColor Red

Write-Host "`n🎯 Customer Traffic Flow:" -ForegroundColor Cyan
Write-Host "   Customer → Domain → ALB → Web Servers → App Servers" -ForegroundColor White

Write-Host "`n📊 To Set Up Custom Domain:" -ForegroundColor Green
Write-Host "1. Register domain (e.g., your-app.com)" -ForegroundColor White
Write-Host "2. Create Route 53 hosted zone" -ForegroundColor White
Write-Host "3. Add CNAME record pointing to:" -ForegroundColor White
Write-Host "   $albDNS" -ForegroundColor Yellow
Write-Host "4. Request SSL certificate via ACM" -ForegroundColor White
Write-Host "5. Update ALB listener for HTTPS" -ForegroundColor White

Write-Host "`n🔧 Quick Setup Commands:" -ForegroundColor Cyan
Write-Host "# Create hosted zone" -ForegroundColor Gray
Write-Host "aws route53 create-hosted-zone --name your-app.com --caller-reference `$(Get-Date -Format 'yyyyMMddHHmmss')" -ForegroundColor Gray

Write-Host "`n# Request SSL certificate" -ForegroundColor Gray
Write-Host "aws acm request-certificate --domain-name your-app.com --validation-method DNS" -ForegroundColor Gray

Write-Host "`n✅ Current Customer URL (Ready Now):" -ForegroundColor Green
Write-Host "http://$albDNS" -ForegroundColor Cyan

Write-Host "`nShare this URL with your customers! 🎉" -ForegroundColor Green
