# 🚀 Production-Grade CI/CD Template for Java/Spring Boot

[![CI/CD](https://github.com/tecresearch/git-docker-cicd/actions/workflows/ci-cd.yml/badge.svg?branch=main)](https://github.com/tecresearch/git-docker-cicd/actions/workflows/ci-cd.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A **complete, production-ready template** for Java/Spring Boot applications with automated testing, Docker containerization, and secure VPS deployment.

Push once. Your app tests, builds, publishes, and deploys automatically. ✨

---

## 🎯 What Is This?

This is a reusable **CI/CD template** that brings together:

- ✅ **Java/Spring Boot** application with REST API
- ✅ **Automated Testing** via Maven on every push
- ✅ **Docker** multi-stage builds (secure, optimized)
- ✅ **GitHub Actions** workflows for CI/CD
- ✅ **Docker Hub** image publishing (with tags)
- ✅ **Tailscale** secure private network connection
- ✅ **VPS Deployment** over encrypted connection
- ✅ **Health Checks** automatic verification

**Perfect for:** Any team that wants to deploy Java apps to their own infrastructure without managing complex DevOps tooling.

---

## ⚡ Quick Start (5 Minutes)

### 1. Clone This Repository

```bash
git clone https://github.com/tecresearch/git-docker-cicd.git my-app
cd my-app
```

### 2. Customize for Your App

Edit these files:
- **`pom.xml`** — Change groupId, artifactId, add dependencies
- **`Dockerfile`** — Update Java version or port if needed
- **`docker-compose.yml`** — Update app name and port
- **`.github/workflows/`** — Update image name if different

### 3. Create GitHub Secrets (6 Required)

```bash
# Docker Hub
gh secret set DOCKERHUB_USERNAME --body "your-dockerhub-username"
gh secret set DOCKERHUB_TOKEN  # Paste your Docker Hub token

# VPS Access
gh secret set VPS_HOST --body "100.x.y.z"  # Your Tailscale IP
gh secret set VPS_USERNAME --body "ubuntu"  # SSH user
gh secret set VPS_SSH_KEY < ~/.ssh/github-deploy  # Private key

# Tailscale
gh secret set TAILSCALE_AUTHKEY  # Paste auth key
```

See **[GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md)** for detailed instructions.

### 4. Prepare Your VPS

```bash
# SSH to your VPS and run:
curl -fsSL https://get.docker.com | sh
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

See **[VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md)** for full walkthrough.

### 5. Deploy!

```bash
git push origin main
```

**GitHub Actions will automatically:**
1. ✅ Run Maven tests
2. ✅ Build Docker image
3. ✅ Push to Docker Hub
4. ✅ Deploy to your VPS
5. ✅ Verify health

**Your app is live in ~3 minutes!** 🎉

---

## 📚 Documentation

| Document | Purpose |
|----------|---------|
| **[README_PRODUCTION_TEMPLATE.md](README_PRODUCTION_TEMPLATE.md)** | Complete 615-line setup guide (start here if new) |
| **[GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md)** | Configure all 6 required secrets step-by-step |
| **[VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md)** | Prepare your VPS with Docker & Tailscale |
| **[SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)** | Verify each step before deploy |
| **[README_PRODUCTION.md](README_PRODUCTION.md)** | Production features overview |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Your Local PC                        │
│  (Git push origin main)                                     │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                    GitHub Repository                        │
└────────────────────────┬────────────────────────────────────┘
                         ↓
┌─────────────────────────────────────────────────────────────┐
│              GitHub Actions Workflows                       │
│  1. CI/CD: Test → Build → Publish to Docker Hub            │
│  2. Deploy: Tailscale SSH → Pull → Restart                 │
└────────────────┬──────────────────────────┬─────────────────┘
                 ↓                          ↓
        ┌──────────────────┐      ┌─────────────────────┐
        │  Docker Hub      │      │  Your VPS           │
        │  (Image Store)   │      │  (App Running)      │
        └──────────────────┘      │  Port 8080          │
                                   │  Healthy ✅        │
                                   └─────────────────────┘
```

---

## 🔐 Security & Best Practices

- ✅ **Non-root container** runs as unprivileged user
- ✅ **Multi-stage builds** keep image small and secure
- ✅ **SSH key authentication** (no passwords)
- ✅ **Tailscale VPN** encrypts all traffic
- ✅ **Secrets in GitHub** (never in code)
- ✅ **Immutable image tags** for safe rollbacks
- ✅ **Health checks** verify app is responding
- ✅ **Limited permissions** (GitHub token: read-only)

---

## 🛠️ What's Included

### Files
```
├── README.md                          # This file
├── README_PRODUCTION_TEMPLATE.md     # Comprehensive guide (615 lines)
├── README_PRODUCTION.md              # Production overview
├── GITHUB_SECRETS_SETUP.md           # Secrets configuration
├── VPS_SETUP_GUIDE.md                # VPS preparation
├── SETUP_CHECKLIST.md                # Verification checklist
│
├── Dockerfile                        # Multi-stage build
├── docker-compose.yml                # Local development
├── pom.xml                           # Maven config
├── mvnw / mvnw.cmd                   # Maven wrapper
│
├── .github/workflows/
│   ├── ci-cd.yml                     # Test, build, publish
│   ├── deploy.yml                    # VPS deployment
│   └── test-ssh.yml                  # Debug connectivity
│
└── src/
    ├── main/java/.../GreetingController.java  # REST API
    └── test/java/.../GreetingControllerTest.java
```

### Workflows

**CI/CD Workflow** (`.github/workflows/ci-cd.yml`)
- Triggers on: push to `main`, PR to `main`, manual dispatch
- Jobs:
  - `test` — Run Maven tests & package
  - `docker-build` — Validate Docker build (PRs only)
  - `publish` — Push image to Docker Hub (main only)

**Deploy Workflow** (`.github/workflows/deploy.yml`)
- Triggers on: CI/CD success (auto) or manual dispatch
- Steps:
  - Install & connect Tailscale
  - SSH to VPS
  - Pull image & restart container
  - Health check verification

**Test SSH Workflow** (`.github/workflows/test-ssh.yml`)
- Manual trigger for debugging Tailscale connectivity

---

## 🚀 First Deployment

### Make a Change
```bash
# Edit a file
echo "// Updated" >> src/main/java/com/example/demo/GreetingController.java

# Commit & push
git add .
git commit -m "My first production deployment"
git push origin main
```

### Watch It Deploy
```
GitHub Actions → Actions tab → Watch workflows run
```

**Timeline:**
- 0s — CI/CD starts (test & build)
- 2:30m — Image published to Docker Hub
- 2:35m — Deploy workflow starts automatically
- 3:00m — ✅ App is live on your VPS!

---

## 🎨 Customization

### Change Port (Default: 8080)

1. **Dockerfile**
   ```dockerfile
   EXPOSE 9000  # Change from 8080
   ```

2. **docker-compose.yml**
   ```yaml
   ports:
     - "9000:9000"
   ```

3. **.github/workflows/deploy.yml**
   ```yaml
   -p 9000:9000
   ```

### Change Application Name

Update `IMAGE_NAME` in `.github/workflows/`:
- `ci-cd.yml`: Change `demo-app` to your app name
- `deploy.yml`: Update image name references

### Use Different Java Version

1. **pom.xml**
   ```xml
   <java.version>21</java.version>
   ```

2. **Dockerfile**
   ```dockerfile
   FROM eclipse-temurin:21-jre-jammy
   ```

### Add Dependencies

Edit **pom.xml** and add under `<dependencies>`:
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
```

---

## 🐛 Troubleshooting

### Tests Fail
```bash
# Run locally
./mvnw clean test

# Check for Java version issues, missing dependencies
```

### Docker Build Fails
```bash
# Build locally
docker build -t test .

# Check Dockerfile syntax, jar file name
```

### Deploy SSH Times Out
```bash
# Run test workflow
GitHub Actions → Test SSH Connection → Run workflow

# Check:
# - VPS_HOST is correct (tailscale ip -4)
# - VPS is running Tailscale
# - SSH key is correct
```

### App Container Exits
```bash
# SSH to VPS
ssh user@100.x.y.z

# Check logs
docker logs demo-app

# Check port conflict
netstat -tlnp | grep 8080
```

See **[README_PRODUCTION_TEMPLATE.md#troubleshooting](README_PRODUCTION_TEMPLATE.md#troubleshooting)** for more details.

---

## 📊 Workflow Status

Check your workflows at: https://github.com/tecresearch/git-docker-cicd/actions

Your fork URL: https://github.com/YOUR_USERNAME/git-docker-cicd/actions

---

## 💰 Cost

**Monthly estimate:**
- GitHub Actions: Free (2000 min for private repos)
- Docker Hub: Free (public images)
- VPS: $3-5 (DigitalOcean 512MB)
- Tailscale: Free (up to 3 devices)

**Total: $3-5/month** 🎉

---

## 🤝 Contributing

This is a template. Feel free to:
- ✅ Fork and customize for your projects
- ✅ Add features (database, caching, monitoring)
- ✅ Improve documentation
- ✅ Share feedback

To contribute back:
1. Fork the repo
2. Create a branch
3. Make improvements
4. Submit a PR

---

## 📋 Next Steps

1. **Read the guide:** [README_PRODUCTION_TEMPLATE.md](README_PRODUCTION_TEMPLATE.md)
2. **Configure secrets:** [GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md)
3. **Prepare VPS:** [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md)
4. **Follow checklist:** [SETUP_CHECKLIST.md](SETUP_CHECKLIST.md)
5. **Deploy:** `git push origin main`

---

## ❓ FAQ

**Q: Can I deploy to AWS/GCP/Azure?**  
A: Yes! Any VPS with Docker. Works with EC2, Compute Engine, Virtual Machines, etc.

**Q: What if I don't know Docker?**  
A: That's fine! The template handles it. You just edit code and push.

**Q: Can I use a different Java framework?**  
A: Yes, adjust `pom.xml` and `Dockerfile` for your framework.

**Q: Is Tailscale required?**  
A: Recommended for security, but you can SSH directly if VPS is publicly accessible.

**Q: How do I rollback?**  
A: Manually deploy an older image tag via GitHub Actions.

**Q: Can I deploy multiple apps?**  
A: Yes, duplicate workflows with different secrets.

**Q: What about databases?**  
A: Run as separate container or managed service; adjust JDBC URL env vars.

---

## 📞 Support

- **Questions?** Check [README_PRODUCTION_TEMPLATE.md](README_PRODUCTION_TEMPLATE.md)
- **Secrets help?** See [GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md)
- **VPS issues?** Read [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md)
- **Stuck?** GitHub Issues on this repo

---

## 📄 License

This template is MIT licensed — use freely for any project.

---

## 🏆 What You Get

A **production-ready, reusable template** that you can fork for every future Java project:

- ✅ Tests run automatically
- ✅ Images build & publish automatically
- ✅ Apps deploy automatically
- ✅ Health checks verify success
- ✅ Rollbacks are safe (immutable tags)
- ✅ No manual DevOps work needed

**Push code. App goes live. Done.** 🚀

---

## 🙌 Credits

Built as a production-grade template demonstrating best practices for:
- Java Spring Boot containerization
- GitHub Actions CI/CD automation
- Secure VPS deployment over Tailscale
- Enterprise-grade DevOps workflows

**Repository:** https://github.com/tecresearch/git-docker-cicd

---

## 🚀 Ready to Deploy?

```bash
# 1. Customize
git clone <repo> my-app
cd my-app
# Edit pom.xml, Dockerfile, etc.

# 2. Configure
gh secret set DOCKERHUB_USERNAME --body "..."
gh secret set DOCKERHUB_TOKEN
gh secret set VPS_HOST --body "100.x.y.z"
gh secret set VPS_USERNAME --body "ubuntu"
gh secret set VPS_SSH_KEY < ~/.ssh/id_ed25519
gh secret set TAILSCALE_AUTHKEY

# 3. Deploy
git push origin main

# ✨ Done! Your app is live in 3 minutes!
```

**Welcome to production-grade CI/CD automation!** 🎉

---

## 👨‍💻 Developer

**Software Engineer:** Brijesh Nishad

Built this production-grade CI/CD template to simplify Java/Spring Boot containerization and deployment for teams worldwide.

---

**Happy deploying!** 🚀

