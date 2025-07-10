const { spawn } = require('child_process');
const http = require('http');

console.log('🚀 Opening EKS Application in VS Code...');

// Start port forwarding
const portForward = spawn('kubectl', [
    'port-forward', 
    'service/sample-web-app-service', 
    '8080:80', 
    '-n', 
    'sample-apps'
], {
    stdio: 'pipe'
});

portForward.stdout.on('data', (data) => {
    console.log(`Port forward: ${data}`);
});

portForward.stderr.on('data', (data) => {
    console.log(`Port forward: ${data}`);
});

// Wait for port forwarding to be ready
setTimeout(() => {
    // Test if the service is available
    const req = http.get('http://localhost:8080', (res) => {
        console.log('✅ Application is accessible at http://localhost:8080');
        
        // Open in VS Code Simple Browser
        const vscode = spawn('code', ['--command', 'vscode.open', 'http://localhost:8080']);
        
        vscode.on('close', (code) => {
            console.log('VS Code command completed');
        });
        
    }).on('error', (err) => {
        console.log('❌ Application not accessible:', err.message);
    });
    
}, 3000);

// Handle cleanup
process.on('SIGINT', () => {
    console.log('Stopping port forwarding...');
    portForward.kill();
    process.exit();
});
