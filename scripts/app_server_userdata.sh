#!/bin/bash
# App Server User Data Script

# Update system
yum update -y

# Install Node.js and npm
curl -sL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install additional tools
yum install -y curl telnet nc

# Create application directory
mkdir -p /opt/app-server
cd /opt/app-server

# Create a simple Node.js application
cat > app.js << 'EOF'
const express = require('express');
const os = require('os');
const app = express();

// Middleware for JSON parsing
app.use(express.json());

// Get instance metadata
const getInstanceInfo = () => {
    return {
        hostname: os.hostname(),
        platform: os.platform(),
        architecture: os.arch(),
        cpus: os.cpus().length,
        memory: `${Math.round(os.totalmem() / 1024 / 1024 / 1024)}GB`,
        uptime: `${Math.round(os.uptime() / 60)} minutes`,
        privateIp: getPrivateIP(),
        timestamp: new Date().toISOString()
    };
};

const getPrivateIP = () => {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const interface of interfaces[name]) {
            if (interface.family === 'IPv4' && !interface.internal) {
                return interface.address;
            }
        }
    }
    return 'unknown';
};

// Health check endpoint
app.get('/', (req, res) => {
    res.json({
        status: 'healthy',
        message: '🚀 Altimetrik App Server is running!',
        server: getInstanceInfo()
    });
});

// Detailed info endpoint
app.get('/info', (req, res) => {
    res.json({
        application: 'Altimetrik App Server',
        version: '1.0.0',
        environment: 'production',
        server: getInstanceInfo(),
        endpoints: [
            'GET /',
            'GET /info',
            'GET /health',
            'POST /api/data',
            'GET /api/users'
        ]
    });
});

// Health endpoint for load balancer
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'UP',
        timestamp: new Date().toISOString()
    });
});

// Sample API endpoints
app.get('/api/users', (req, res) => {
    res.json({
        users: [
            { id: 1, name: 'John Doe', role: 'admin' },
            { id: 2, name: 'Jane Smith', role: 'user' },
            { id: 3, name: 'Bob Johnson', role: 'user' }
        ],
        server: getInstanceInfo().hostname
    });
});

app.post('/api/data', (req, res) => {
    const data = req.body;
    res.json({
        message: 'Data received successfully',
        receivedData: data,
        processedBy: getInstanceInfo().hostname,
        timestamp: new Date().toISOString()
    });
});

// Database simulation endpoint
app.get('/api/database/status', (req, res) => {
    res.json({
        database: {
            status: 'connected',
            type: 'MySQL',
            host: 'app-db.internal',
            connections: Math.floor(Math.random() * 50) + 10
        },
        server: getInstanceInfo().hostname
    });
});

// Process monitoring endpoint
app.get('/api/system/metrics', (req, res) => {
    const loadAvg = os.loadavg();
    res.json({
        system: {
            loadAverage: {
                '1min': loadAvg[0].toFixed(2),
                '5min': loadAvg[1].toFixed(2),
                '15min': loadAvg[2].toFixed(2)
            },
            memoryUsage: process.memoryUsage(),
            uptime: `${Math.round(process.uptime())} seconds`
        },
        server: getInstanceInfo().hostname
    });
});

// Error simulation endpoint for testing
app.get('/api/error', (req, res) => {
    res.status(500).json({
        error: 'Simulated server error',
        server: getInstanceInfo().hostname,
        timestamp: new Date().toISOString()
    });
});

// Start HTTP server on port 8080
const HTTP_PORT = 8080;
app.listen(HTTP_PORT, '0.0.0.0', () => {
    console.log(`🚀 App Server HTTP listening on port ${HTTP_PORT}`);
    console.log(`Server Info: ${JSON.stringify(getInstanceInfo(), null, 2)}`);
});

// Start HTTPS server on port 8443 (with self-signed certificate)
const https = require('https');
const fs = require('fs');

// Create self-signed certificate for HTTPS
const { execSync } = require('child_process');
try {
    execSync('openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes -subj "/C=US/ST=State/L=City/O=Organization/OU=OrgUnit/CN=localhost"');
    
    const httpsOptions = {
        key: fs.readFileSync('key.pem'),
        cert: fs.readFileSync('cert.pem')
    };
    
    const HTTPS_PORT = 8443;
    https.createServer(httpsOptions, app).listen(HTTPS_PORT, '0.0.0.0', () => {
        console.log(`🔒 App Server HTTPS listening on port ${HTTPS_PORT}`);
    });
} catch (error) {
    console.log('⚠️  Could not start HTTPS server:', error.message);
}
EOF

# Create package.json
cat > package.json << 'EOF'
{
  "name": "altimetrik-app-server",
  "version": "1.0.0",
  "description": "Altimetrik Application Server",
  "main": "app.js",
  "scripts": {
    "start": "node app.js",
    "dev": "nodemon app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
EOF

# Install dependencies
npm install

# Create systemd service for the app
cat > /etc/systemd/system/app-server.service << 'EOF'
[Unit]
Description=Altimetrik App Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/app-server
ExecStart=/usr/bin/node app.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production
Environment=PORT=8080

# Logging
StandardOutput=journal
StandardError=journal
SyslogIdentifier=app-server

[Install]
WantedBy=multi-user.target
EOF

# Change ownership to ec2-user
chown -R ec2-user:ec2-user /opt/app-server

# Install OpenSSL for HTTPS certificates
yum install -y openssl

# Enable and start the service
systemctl daemon-reload
systemctl enable app-server
systemctl start app-server

# Create a health check script
cat > /opt/app-server/health-check.sh << 'EOF'
#!/bin/bash
# Health check script for app server

echo "=== App Server Health Check ==="
echo "Date: $(date)"
echo ""

# Check if service is running
if systemctl is-active --quiet app-server; then
    echo "✅ Service Status: RUNNING"
else
    echo "❌ Service Status: NOT RUNNING"
fi

# Check HTTP port 8080
if nc -z localhost 8080; then
    echo "✅ HTTP Port 8080: OPEN"
    
    # Test HTTP endpoint
    HTTP_RESPONSE=$(curl -s http://localhost:8080/ | jq -r '.status' 2>/dev/null || echo "error")
    echo "📝 HTTP Response: $HTTP_RESPONSE"
else
    echo "❌ HTTP Port 8080: CLOSED"
fi

# Check HTTPS port 8443
if nc -z localhost 8443; then
    echo "✅ HTTPS Port 8443: OPEN"
else
    echo "❌ HTTPS Port 8443: CLOSED"
fi

# Check system resources
echo ""
echo "📊 System Resources:"
echo "CPU Load: $(uptime | awk -F'load average:' '{ print $2 }')"
echo "Memory: $(free -h | awk 'NR==2{printf "%.1f%% (%s/%s)", $3*100/$2, $3, $2}')"
echo "Disk: $(df -h / | awk 'NR==2{printf "%s (%s used)", $5, $3}')"

echo ""
echo "=== Health Check Complete ==="
EOF

chmod +x /opt/app-server/health-check.sh

# Install jq for JSON processing
yum install -y jq

# Create log file
echo "App Server setup completed at $(date)" > /var/log/app-server-setup.log

# Run initial health check
/opt/app-server/health-check.sh >> /var/log/app-server-setup.log

# Check service status
sleep 10
systemctl status app-server >> /var/log/app-server-setup.log

echo "App Server installation and configuration completed!" >> /var/log/app-server-setup.log
