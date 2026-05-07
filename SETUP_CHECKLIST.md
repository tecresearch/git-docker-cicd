# 📋 Production Template Setup Checklist

Use this checklist to ensure everything is properly configured before deploying your application.

## ✅ Project Customization

- [ ] Updated `pom.xml` with your application's groupId, artifactId, and dependencies
- [ ] Updated `Dockerfile` if using a different Java version or port
- [ ] Updated `docker-compose.yml` if using a different port or app name
- [ ] Updated `.github/workflows/ci-cd.yml` if image name is different
- [ ] Updated `.github/workflows/deploy.yml` if using different app name
- [ ] Committed all changes and pushed to main: `git push origin main`

## 🔐 GitHub Secrets (6 Required)

Go to **GitHub Settings → Secrets and variables → Actions** and add:

**Docker Hub**
- [ ] `DOCKERHUB_USERNAME` — Your Docker Hub username
- [ ] `DOCKERHUB_TOKEN` — Personal access token from Docker Hub

**VPS Access**
- [ ] `VPS_HOST` — Tailscale IP (e.g., 100.x.y.z)
- [ ] `VPS_USERNAME` — SSH user (usually `ubuntu` or `root`)
- [ ] `VPS_SSH_KEY` — Private SSH key (PEM format)

**Tailscale**
- [ ] `TAILSCALE_AUTHKEY` — Auth key from Tailscale admin console

**Verification:**
```bash
gh secret list -R your-username/your-repo
# Should show all 6 secrets
```

## 🖥️ VPS Preparation

- [ ] VPS created with 1+ CPU, 512MB+ RAM
- [ ] Docker installed: `curl -fsSL https://get.docker.com | sh`
- [ ] User added to docker group: `sudo usermod -aG docker $USER`
- [ ] Tailscale installed: `curl -fsSL https://tailscale.com/install.sh | sh`
- [ ] Connected to Tailscale: `sudo tailscale up`
- [ ] Tailscale IP noted: `tailscale ip -4` (save this for VPS_HOST)
- [ ] Port 8080 accessible (or your custom port)
- [ ] SSH key authentication set up (private key in VPS_SSH_KEY)

## 🔍 Pre-Deploy Testing

### Test SSH Connection (GitHub Actions)
- [ ] GitHub Actions → Test SSH Connection → Run workflow
- [ ] Should complete successfully with Docker version output

### Test Locally (Optional)
```bash
# Build image locally
docker build -t my-app:test .

# Run container
docker run --rm -p 8080:8080 my-app:test

# Test endpoint
curl http://localhost:8080/api/greeting
# Should return: Hello, World!
```

## 🚀 Deploy!

### Option 1: Automatic (Recommended)
```bash
# Push to main
git push origin main

# Watch: GitHub → Actions → CI/CD workflow → Deploy
# Should complete in ~2-3 minutes
```

### Option 2: Manual
- [ ] GitHub → Actions → Deploy to VPS → Run workflow
- [ ] Leave tag as `latest` or specify a commit SHA

## ✨ Verification

After deployment, verify the app is running:

### From GitHub Actions
- [ ] CI/CD workflow: Test & Package — `✅ Success`
- [ ] Publish workflow: Docker image pushed — `✅ Success`
- [ ] Deploy workflow: All steps completed — `✅ Success`

### From VPS
```bash
# SSH via Tailscale (use your Tailscale IP)
ssh user@100.x.y.z

# Verify container is running
docker ps
# Should show: demo-app container running

# Test the application
curl http://localhost:8080/api/greeting
# Should return: Hello, World!

# View logs
docker logs demo-app
# Should show: "Started DemoApplication"

# Check health
docker ps --filter "name=demo-app"
# Should show: Up X seconds (healthy)
```

### From Your Local Machine (if app is publicly exposed)
```bash
# Get VPS public IP
# Replace XXX.XXX.XXX.XXX with your VPS public IP
curl http://XXX.XXX.XXX.XXX:8080/api/greeting
```

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| CI/CD tests fail | Run `./mvnw clean test` locally to debug |
| Docker build fails | Run `docker build -t test .` locally |
| Deploy SSH times out | Run Test SSH Connection workflow; check VPS_HOST IP |
| Container exits | SSH to VPS, run `docker logs demo-app` |
| App not responding | Wait 10-15s for startup; check health with `curl` |
| Permission denied | Verify VPS_SSH_KEY is private key, not public |

See [Troubleshooting Guide](README_PRODUCTION_TEMPLATE.md#troubleshooting) for more details.

## 📚 Documentation Files

- **[README_PRODUCTION.md](README_PRODUCTION.md)** — Overview and quick reference
- **[README_PRODUCTION_TEMPLATE.md](README_PRODUCTION_TEMPLATE.md)** — Comprehensive guide (80 sections)
- **[GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md)** — Secrets configuration
- **[VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md)** — VPS preparation
- **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** — This file

## 🎯 Next Steps

1. ✅ **Customize** your application (pom.xml, Dockerfile)
2. ✅ **Configure** GitHub secrets (6 required)
3. ✅ **Prepare** VPS (Docker, Tailscale)
4. ✅ **Test** SSH connection
5. ✅ **Deploy** (push to main or manual deploy)
6. ✅ **Verify** application is running

---

## 💡 Tips

- **Fast iteration:** Each push to main triggers automatic test → build → deploy
- **Rollback:** Manually deploy with a previous SHA tag (e.g., `sha-abc123def456`)
- **Multiple apps:** Duplicate workflows and secrets for each app
- **Debugging:** Check GitHub Actions logs first, then VPS `docker logs`
- **Security:** Rotate secrets quarterly; use SSH keys, not passwords

---

**Questions?** See the full guide: [README_PRODUCTION_TEMPLATE.md](README_PRODUCTION_TEMPLATE.md)

**Ready?** Follow the checklist above! 🚀

