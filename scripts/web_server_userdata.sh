#!/bin/bash
# Web Server User Data Script

# Update system
yum update -y

# Install Apache HTTP Server
yum install -y httpd

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Install additional tools
yum install -y curl telnet nc

# Create a simple web page
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f4; }
        .container { background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; }
        .info { background-color: #e7f3ff; padding: 15px; border-radius: 4px; margin: 10px 0; }
        .button { background-color: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 4px; cursor: pointer; margin: 5px; }
        .button:hover { background-color: #45a049; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌐 Web Server</h1>
        <div class="info">
            <strong>Server Info:</strong><br>
            Instance ID: <span id="instance-id">Loading...</span><br>
            Private IP: <span id="private-ip">Loading...</span><br>
            Public IP: <span id="public-ip">Loading...</span><br>
            Timestamp: <span id="timestamp"></span>
        </div>
        
        <h2>🔗 Application Server Connectivity</h2>
        <div>
            <button class="button" onclick="testAppServer('${app_server_1_ip}')">Test App Server 1</button>
            <button class="button" onclick="testAppServer('${app_server_2_ip}')">Test App Server 2</button>
        </div>
        <div id="test-results"></div>
        
        <h2>📊 Load Balancer Health Check</h2>
        <p>✅ This page serves as the health check endpoint for the Application Load Balancer</p>
    </div>

    <script>
        // Get instance metadata
        fetch('/api/instance-info')
            .then(response => response.json())
            .then(data => {
                document.getElementById('instance-id').textContent = data.instanceId;
                document.getElementById('private-ip').textContent = data.privateIp;
                document.getElementById('public-ip').textContent = data.publicIp;
            })
            .catch(() => {
                document.getElementById('instance-id').textContent = 'N/A';
                document.getElementById('private-ip').textContent = 'N/A';
                document.getElementById('public-ip').textContent = 'N/A';
            });
        
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
        
        function testAppServer(ip) {
            const resultsDiv = document.getElementById('test-results');
            resultsDiv.innerHTML = '<p>Testing connection to ' + ip + '...</p>';
            
            fetch('/api/test-app-server?ip=' + ip)
                .then(response => response.text())
                .then(data => {
                    resultsDiv.innerHTML = '<div class="info"><strong>Test Result:</strong><br>' + data + '</div>';
                })
                .catch(error => {
                    resultsDiv.innerHTML = '<div class="info" style="background-color: #ffebee;"><strong>Connection Failed:</strong><br>' + error + '</div>';
                });
        }
    </script>
</body>
</html>
EOF

# Create PHP script for dynamic content and API endpoints
cat > /var/www/html/api/instance-info << 'EOF'
#!/bin/bash
echo "Content-Type: application/json"
echo ""

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id 2>/dev/null || echo "unknown")
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null || echo "unknown")
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4 2>/dev/null || echo "unknown")

cat << JSON
{
    "instanceId": "$INSTANCE_ID",
    "privateIp": "$PRIVATE_IP",
    "publicIp": "$PUBLIC_IP",
    "timestamp": "$(date)"
}
JSON
EOF

# Create app server test script
cat > /var/www/html/api/test-app-server << 'EOF'
#!/bin/bash
echo "Content-Type: text/plain"
echo ""

APP_SERVER_IP=$(echo "$QUERY_STRING" | sed -n 's/^.*ip=\([^&]*\).*$/\1/p')

if [ -z "$APP_SERVER_IP" ]; then
    echo "Error: No IP provided"
    exit 1
fi

echo "Testing connection to App Server: $APP_SERVER_IP"
echo "=================================="

# Test port 8080 (HTTP)
if nc -z -w3 $APP_SERVER_IP 8080 2>/dev/null; then
    echo "✅ Port 8080 (HTTP): OPEN"
    
    # Try to get response from app server
    RESPONSE=$(curl -s --connect-timeout 5 http://$APP_SERVER_IP:8080/ || echo "No response")
    echo "📝 Response: $RESPONSE"
else
    echo "❌ Port 8080 (HTTP): CLOSED"
fi

# Test port 8443 (HTTPS)
if nc -z -w3 $APP_SERVER_IP 8443 2>/dev/null; then
    echo "✅ Port 8443 (HTTPS): OPEN"
else
    echo "❌ Port 8443 (HTTPS): CLOSED"
fi

# Test ping
if ping -c 1 -W 3 $APP_SERVER_IP >/dev/null 2>&1; then
    echo "✅ Ping: SUCCESS"
else
    echo "❌ Ping: FAILED"
fi

echo ""
echo "Test completed at: $(date)"
EOF

# Make scripts executable
mkdir -p /var/www/html/api
chmod +x /var/www/html/api/*

# Configure Apache CGI
echo "ScriptAlias /api/ /var/www/html/api/" >> /etc/httpd/conf/httpd.conf
echo "<Directory \"/var/www/html/api\">" >> /etc/httpd/conf/httpd.conf
echo "    AllowOverride None" >> /etc/httpd/conf/httpd.conf
echo "    Options ExecCGI" >> /etc/httpd/conf/httpd.conf
echo "    Require all granted" >> /etc/httpd/conf/httpd.conf
echo "</Directory>" >> /etc/httpd/conf/httpd.conf

# Restart Apache to apply changes
systemctl restart httpd

# Create a log file for monitoring
echo "Web Server setup completed at $(date)" > /var/log/web-server-setup.log
echo "App Server IPs: ${app_server_1_ip}, ${app_server_2_ip}" >> /var/log/web-server-setup.log

# Test connectivity to app servers
echo "Testing connectivity to app servers..." >> /var/log/web-server-setup.log
ping -c 3 ${app_server_1_ip} >> /var/log/web-server-setup.log 2>&1
ping -c 3 ${app_server_2_ip} >> /var/log/web-server-setup.log 2>&1
