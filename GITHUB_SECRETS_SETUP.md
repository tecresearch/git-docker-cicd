# GitHub Actions Secrets Configuration Guide

This file documents all the GitHub Secrets needed for the CI/CD pipeline.

## Required Secrets

### Docker Hub Credentials

#### `DOCKERHUB_USERNAME`
- **Value:** Your Docker Hub username
- **Example:** `tecresearch`
- **Where to get:** [Docker Hub Profile](https://hub.docker.com/settings/profile)

#### `DOCKERHUB_TOKEN`
- **Value:** Personal access token from Docker Hub
- **How to create:**
  1. Go to [Docker Hub Settings → Security](https://hub.docker.com/settings/security)
  2. Click "New Access Token"
  3. Name it `github-actions` or similar
  4. Set permissions: at minimum `Read, Write`
  5. Copy the token (appears once only)
  6. Paste into GitHub secret

---

### VPS Access Credentials

#### `VPS_HOST`
- **Value:** Tailscale IP address of your VPS
- **Example:** `100.123.45.67`
- **How to find:**
  1. SSH to your VPS: `ssh user@your-vps-public-ip`
  2. Run: `tailscale ip -4`
  3. Copy the IP address
  4. Or check Tailscale Admin Console → Machines

#### `VPS_USERNAME`
- **Value:** SSH username for your VPS
- **Examples:** 
  - AWS EC2 Ubuntu: `ubuntu`
  - AWS EC2 Amazon Linux: `ec2-user`
  - DigitalOcean: `root`
  - GCP: your-username or `ubuntu`
  - Generic: usually `root` or your username
- **How to find:** Check your VPS provider documentation

#### `VPS_SSH_KEY`
- **Value:** Private SSH key (PEM format)
- **How to create:**
  ```bash
  # Generate new key
  ssh-keygen -t ed25519 -C "github-deploy" -f ~/.ssh/github-deploy
  # Don't set a passphrase
  
  # View the private key
  cat ~/.ssh/github-deploy
  ```
- **Format:** Must include `-----BEGIN OPENSSH PRIVATE KEY-----` header
- **⚠️ Important:** Never commit this to git, only store in GitHub secrets

---

### Tailscale Network

#### `TAILSCALE_AUTHKEY`
- **Value:** One-time registration key from Tailscale
- **How to create:**
  1. Go to [Tailscale Admin Console](https://login.tailscale.com/admin)
  2. Click **Settings** → **Keys**
  3. Click **Generate auth key**
  4. Enable "**Reusable**" (so multiple runners can join)
  5. Set "**Expires**" to 30 days (safety)
  6. Copy and paste into GitHub secret
  7. Save the key securely (shows once only)

---

## How to Add Secrets to GitHub

### Via GitHub Web UI (Easy)

1. Go to your GitHub repository
2. Click **Settings**
3. In the left sidebar, click **Secrets and variables** → **Actions**
4. Click **New repository secret**
5. **Name:** Exactly as listed above (e.g., `DOCKERHUB_USERNAME`)
6. **Secret:** Paste the value
7. Click **Add secret**

### Via GitHub CLI (Fast)

```bash
# Set DOCKERHUB_USERNAME
gh secret set DOCKERHUB_USERNAME -R your-username/your-repo --body "your-dockerhub-username"

# Set DOCKERHUB_TOKEN (paste when prompted)
gh secret set DOCKERHUB_TOKEN -R your-username/your-repo

# Verify secrets are set
gh secret list -R your-username/your-repo
```

### Via Command Line (One-liner)

```bash
# Copy-paste your secret value
echo "your-secret-value" | gh secret set SECRET_NAME -R your-username/your-repo --body -
```

---

## Verification Checklist

After adding all secrets, verify each one works:

```bash
# 1. Docker Hub credentials
docker login -u <DOCKERHUB_USERNAME> -p "<DOCKERHUB_TOKEN>"
# Should succeed

# 2. SSH key to VPS
ssh -i ~/.ssh/github-deploy <VPS_USERNAME>@<VPS_HOST>
# Should connect without password

# 3. Tailscale connection
tailscale ip  # Should show an IP
# Should be on same network as VPS
```

---

## Secret Rotation & Security

### When to Rotate

- Docker Hub: Every 3 months
- SSH Keys: If compromised or after 1 year
- Tailscale: Quarterly (auto-expires)

### How to Rotate

1. Generate new credential (Docker token, SSH key, Tailscale key)
2. Update the GitHub secret
3. Delete old credential from original service
4. Test with a manual deploy workflow

---

## Troubleshooting

### "Authentication failed" in CI/CD

**Check:** DOCKERHUB_USERNAME and DOCKERHUB_TOKEN are correct
```bash
docker login -u $DOCKERHUB_USERNAME -p "$DOCKERHUB_TOKEN"
```

### "Permission denied (publickey)" in Deploy

**Check:** VPS_SSH_KEY is your **private** key (not public)
```bash
# Should show private key
cat ~/.ssh/github-deploy
# Should NOT be this file:
cat ~/.ssh/github-deploy.pub  # ❌ WRONG!
```

### "Timeout connecting to VPS"

**Check:**
1. VPS_HOST is correct (verify with `tailscale ip -4`)
2. VPS is running and Tailscale service is active
3. TAILSCALE_AUTHKEY is valid (not expired)

---

## Example: Complete Setup

```bash
# 1. Generate SSH key
ssh-keygen -t ed25519 -C "github-deploy" -N "" -f ~/.ssh/github-deploy

# 2. Get Tailscale IP from VPS
ssh user@vps-public-ip
  $ tailscale ip -4
  > 100.123.45.67
  $ exit

# 3. Add public key to VPS authorized_keys
ssh-copy-id -i ~/.ssh/github-deploy user@100.123.45.67

# 4. Verify SSH connection
ssh -i ~/.ssh/github-deploy user@100.123.45.67
  $ whoami  # Should show user
  $ exit

# 5. Create Docker Hub token
# Go to https://hub.docker.com/settings/security → New Access Token

# 6. Create Tailscale auth key
# Go to https://login.tailscale.com/admin → Settings → Keys → Generate

# 7. Add to GitHub
gh secret set DOCKERHUB_USERNAME --body "your-username"
gh secret set DOCKERHUB_TOKEN  # Paste when prompted
gh secret set VPS_HOST --body "100.123.45.67"
gh secret set VPS_USERNAME --body "ubuntu"
gh secret set VPS_SSH_KEY < ~/.ssh/github-deploy  # Paste private key
gh secret set TAILSCALE_AUTHKEY  # Paste auth key

# 8. Test
git push origin main  # Trigger workflow!
```

---

## Support

- **GitHub Secrets Help:** https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions
- **Tailscale Docs:** https://tailscale.com/kb/
- **Docker Hub API Tokens:** https://docs.docker.com/docker-hub/access-tokens/

