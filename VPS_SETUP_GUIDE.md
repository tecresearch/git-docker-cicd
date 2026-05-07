# VPS Setup Guide

Before you can deploy, you need to prepare your VPS with Docker and Tailscale.

## Prerequisites

- A VPS from any provider (AWS, DigitalOcean, Vultr, Linode, GCP, Azure, etc.)
- **OS:** Ubuntu 20.04+ or similar Linux distribution
- **Minimum specs:** 1 CPU, 512MB RAM (1GB+ recommended for Java apps)
- **Network:** Access to internet (for pulling Docker images)
- SSH access to your VPS

---

## Step 1: Connect to Your VPS

Get your VPS public IP from your provider's control panel.

```bash
# Connect via SSH
ssh root@your-vps-public-ip

# Or if using a key file
ssh -i /path/to/key.pem ubuntu@your-vps-public-ip
```

---

## Step 2: Update System

```bash
sudo apt-get update
sudo apt-get upgrade -y
```

---

## Step 3: Install Docker

```bash
# Download and run Docker installer
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Remove script
rm get-docker.sh

# Verify installation
docker --version
# Should output: Docker version XX.XX.X
```

### Add Your User to Docker Group (Optional but Recommended)

If using a non-root user:

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Apply group changes (necessary after first login)
newgrp docker

# Verify (no sudo needed)
docker ps

# OR logout and log back in for changes to take effect
exit
ssh user@your-vps-ip
docker ps  # Should work without sudo
```

---

## Step 4: Install Tailscale

Tailscale creates a secure encrypted network for GitHub Actions to connect to your VPS.

```bash
# Download and run Tailscale installer
curl -fsSL https://tailscale.com/install.sh | sh

# Verify installation
tailscale --version
```

---

## Step 5: Connect to Tailscale Network

```bash
# Start Tailscale (first time)
sudo tailscale up

# A URL will appear - open it in your browser and authenticate
# Example: https://login.tailscale.com/a/...

# After authenticating, your device joins the tailnet
# Verify connection
tailscale status

# Get your Tailscale IP address
tailscale ip -4
# Example output: 100.123.45.67

# Save this IP - it's your VPS_HOST secret value
```

---

## Step 6: Allow SSH Access from GitHub Actions

Make sure GitHub Actions can SSH to your VPS. You need to add your GitHub Actions public key.

### Option A: SSH Key-Based (Recommended for GitHub Secrets)

This is already handled by the deploy workflow, which uses the `VPS_SSH_KEY` secret you provide.

**From the VPS:**

```bash
# View authorized SSH keys
cat ~/.ssh/authorized_keys

# Your public key should be there (matches VM_SSH_KEY)
```

### Option B: Verify SSH Port is Accessible

```bash
# Check SSH is listening (should show port 22)
sudo netstat -tlnp | grep ssh

# Or using ss command
sudo ss -tlnp | grep ssh
```

---

## Step 7: Test Connectivity

From your GitHub secrets should be set, run the test workflow:

**GitHub** → **Actions** → **Test SSH Connection** → **Run workflow**

This should succeed and show:
```
✅ Successfully connected to VPS!
whoami: ubuntu (or your username)
/home/ubuntu (or your home directory)
docker --version: Docker version XX.XX.X
```

---

## Step 8: (Optional) Configure Firewall

If your VPS has a firewall enabled (AWS Security Groups, GCP Firewall, etc.), ensure:

- **Port 22:** Open for SSH (but limited to Tailscale network)
- **Port 8080:** Open for your application (or your custom port)

### AWS Security Group Example

- **Type:** SSH, Protocol: TCP, Port: 22, Source: 0.0.0.0/0 (Tailscale handles security)
- **Type:** Custom TCP, Port: 8080, Source: 0.0.0.0/0 (or your IP range)

### For Public Access to Application

If you want the app accessible on public internet (not recommended):

```bash
# Get your VPS public IP
curl http://ifconfig.me

# Access app
curl http://<vps-public-ip>:8080/api/greeting
```

**Note:** If using only Tailscale (private network), port 8080 is only accessible from your tailnet.

---

## Step 9: Verify Everything Works

Close any existing app containers (from testing), then push code to main:

```bash
# From your local machine
git push origin main
```

**On GitHub:**
1. Go to **Actions** tab
2. Watch **CI/CD** workflow complete
3. Watch **Deploy to VPS** workflow complete
4. Check your VPS:

```bash
ssh user@100.xxx.xxx.xxx  # Use your Tailscale IP

# Check running container
docker ps

# Test the application
curl http://localhost:8080/api/greeting
# Should return: Hello, World!

# View logs
docker logs demo-app

# View container details
docker inspect demo-app
```

---

## Troubleshooting

### ❌ "Docker command not found"

```bash
# Verify installation
which docker
docker --version

# If not found, reinstall
curl -fsSL https://get.docker.com | sh
```

### ❌ "Permission denied: cannot connect to Docker daemon"

```bash
# Solution: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# OR use sudo
sudo docker ps
```

### ❌ Tailscale won't connect

```bash
# Restart Tailscale
sudo systemctl restart tailscaled

# Check status
sudo systemctl status tailscaled

# Reconnect
sudo tailscale down
sudo tailscale up

# Check Tailscale service is running
ps aux | grep tailscaled
```

### ❌ SSH Key authentication fails

```bash
# Verify SSH is accepting your key on VPS
sudo sshd -T | grep pubkeyauth

# Should output: pubkeyauth yes

# Check key permissions
ls -la ~/.ssh/
# Should show: -rw-r--r-- for authorized_keys
# Should show: -rw------- for id_rsa

# Verify GitHub's public key is in authorized_keys
cat ~/.ssh/authorized_keys
```

### ❌ Deployment says "Container exited"

```bash
# Check logs
docker logs demo-app

# Common issues:
# - Port 8080 already in use: docker ps | grep :8080
# - App failed to start: check Java version
# - Out of memory: increase JAVA_OPTS heap

# Restart manually
docker rm demo-app
docker run -d --name demo-app -p 8080:8080 your-image:tag
```

---

## Maintenance

### Keep Docker Updated

```bash
# Check for updates
docker version

# Update Docker
curl -fsSL https://get.docker.com | sh
```

### Clean Up Old Images

```bash
# Remove dangling images
docker image prune

# Remove all unused images
docker image prune -a

# Clean up volumes
docker volume prune
```

### Restart Services After Reboot

Docker and Tailscale should auto-start after reboot. Verify:

```bash
sudo systemctl status docker
sudo systemctl status tailscaled

# Both should show "active (running)"
```

---

## Security Best Practices

### 1. Disable Root SSH (if using a non-root user)

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Find: PermitRootLogin yes
# Change to: PermitRootLogin no

# Restart SSH
sudo systemctl restart ssh
```

### 2. Use SSH Key-Based Auth Only (no passwords)

```bash
# Edit SSH config
sudo nano /etc/ssh/sshd_config

# Find section that has authentication lines
# Ensure: PubkeyAuthentication yes
# Ensure: PasswordAuthentication no

# Restart SSH
sudo systemctl restart ssh
```

### 3. Enable Firewall (UFW on Ubuntu)

```bash
# Enable firewall
sudo ufw enable

# Allow SSH
sudo ufw allow 22/tcp

# Allow your app port
sudo ufw allow 8080/tcp

# Check status
sudo ufw status
```

### 4. Isolate Containers

```bash
# Run app container on custom network
docker network create app-network

# Run container with network
docker run -d --name demo-app --network app-network -p 8080:8080 your-image:tag
```

### 5. Set Resource Limits

```bash
# Limit memory and CPU
docker run -d \
  --name demo-app \
  --memory 512m \
  --cpus 1 \
  -p 8080:8080 \
  your-image:tag
```

---

## Monitoring & Logs

### View Container Logs

```bash
# Real-time logs
docker logs -f demo-app

# Last 100 lines
docker logs --tail 100 demo-app

# Logs with timestamps
docker logs --timestamps demo-app

# Since specific time
docker logs --since 2024-05-08T10:00:00 demo-app
```

### Monitor Resource Usage

```bash
# View CPU, memory, network usage
docker stats demo-app

# Continuous monitoring
docker stats --no-stream
```

---

## Summary

Your VPS is now ready for automated deployments! 

**Checklist:**
- ✅ Docker installed and working
- ✅ Tailscale installed and connected
- ✅ VPS Tailscale IP noted (VPS_HOST)
- ✅ SSH access verified
- ✅ Port 8080 accessible (or your custom port)
- ✅ Firewall configured
- ✅ GitHub Actions can connect (test-ssh.yml passes)

**Next:**
1. Add GitHub secrets (GITHUB_SECRETS_SETUP.md)
2. Push first deploy (git push origin main)
3. Monitor GitHub Actions
4. Access your app at `http://100.x.y.z:8080/api/greeting`

