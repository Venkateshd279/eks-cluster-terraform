# Jenkins Docker Permission Fix - Quick Guide

## 🚨 **Problem**: 
Jenkins can't access Docker daemon due to permission issues.

## 🔧 **Quick Fix** (Choose one method):

### **Method 1: Automated Script**
```powershell
# Run the automated fix script
.\scripts\fix-jenkins-docker-permission.ps1 -JenkinsServerIP "YOUR_JENKINS_IP"
```

### **Method 2: Manual SSH Commands**
```bash
# 1. SSH into Jenkins server
ssh -i python.pem ubuntu@YOUR_JENKINS_IP

# 2. Add jenkins user to docker group
sudo usermod -aG docker jenkins

# 3. Set docker socket permissions
sudo chmod 666 /var/run/docker.sock

# 4. Restart services
sudo systemctl restart docker
sudo systemctl restart jenkins

# 5. Test docker access
sudo -u jenkins docker --version
sudo -u jenkins docker ps
```

### **Method 3: Alternative Docker Socket Fix**
```bash
# If above doesn't work, try this approach:
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
sudo systemctl restart jenkins
```

## ✅ **Verification**
After applying the fix:

1. **Check Jenkins user groups**:
   ```bash
   sudo -u jenkins groups
   # Should show: jenkins docker
   ```

2. **Test Docker access**:
   ```bash
   sudo -u jenkins docker --version
   sudo -u jenkins docker ps
   # Should work without errors
   ```

3. **Check services are running**:
   ```bash
   sudo systemctl status docker
   sudo systemctl status jenkins
   # Both should be active
   ```

## 🚀 **After Fix**
1. Wait 1-2 minutes for services to restart
2. Go to Jenkins pipeline
3. Click **"Build Now"**
4. Monitor console output - Docker build should now work

## 🔍 **Common Issues & Solutions**

### **Issue**: "docker: command not found"
**Solution**: Install Docker on Jenkins server:
```bash
sudo apt update
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

### **Issue**: Jenkins service won't start
**Solution**: Check Jenkins logs:
```bash
sudo journalctl -u jenkins -f
sudo systemctl restart jenkins
```

### **Issue**: Still getting permission denied
**Solution**: Try nuclear option:
```bash
# Make docker socket accessible to all (less secure)
sudo chmod 777 /var/run/docker.sock
```

## 📋 **Root Cause**
- Jenkins runs as `jenkins` user
- Docker daemon runs as `root` user  
- Docker socket (`/var/run/docker.sock`) has restricted permissions
- Solution: Add `jenkins` user to `docker` group

## 🎯 **Expected Result**
After fix, your pipeline should proceed through:
1. ✅ Create ECR Repository
2. ✅ Build Docker Image ← **This stage should now work**
3. ✅ Push to ECR
4. ✅ Deploy to EKS

## 📞 **Need Help?**
If the fix doesn't work:
1. Check Jenkins server logs: `sudo journalctl -u jenkins -f`
2. Check Docker logs: `sudo journalctl -u docker -f`
3. Verify user permissions: `sudo -u jenkins groups`
4. Test manual docker command: `sudo -u jenkins docker ps`
