# Production-Grade CI/CD Template

[![CI/CD](https://github.com/tecresearch/git-docker-cicd/actions/workflows/ci-cd.yml/badge.svg?branch=main)](https://github.com/tecresearch/git-docker-cicd/actions/workflows/ci-cd.yml)

This is a **production-grade template** for Java/Spring Boot applications with:
- ✅ Automated testing via Maven
- ✅ Multi-stage Docker builds with security best practices
- ✅ Automatic Docker image publishing to Docker Hub
- ✅ Secure deployment to private VPS over Tailscale
- ✅ Post-deployment health checks
- ✅ GitHub Actions CI/CD automation

**Perfect for:** Any Java/Spring Boot microservice, API, or web application that needs automated testing, containerization, and deployment.

---

## Quick Start (5 minutes)

### Prerequisites
Before you begin, you need:
1. **GitHub account** with this repo forked or cloned
2. **Docker Hub account** (free tier OK) - [sign up](https://hub.docker.com)
3. **VPS with Docker** (AWS, DigitalOcean, Vultr, GCP, Azure, etc.)
4. **Tailscale account** (free tier OK) - [sign up](https://tailscale.com)

### 1. Fork or Clone This Repository

```bash
# Clone
git clone https://github.com/tecresearch/git-docker-cicd.git
cd git-docker-cicd

# OR fork on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/git-docker-cicd.git
cd git-docker-cicd
```

### 2. Update Application-Specific Files

Edit the following to match your project:

#### `pom.xml`
- Change `<groupId>` and `<artifactId>` to your project name
- Update `<version>` if needed
- Add any additional Maven dependencies

```xml
<groupId>com.example</groupId>
<artifactId>my-awesome-app</artifactId>
```

#### `Dockerfile`
- Update the `EXPOSE` port if your app uses a different port
- Adjust `JAVA_OPTS` heap settings if needed
- If your app isn't a Spring Boot fat jar, adjust the `ENTRYPOINT`

#### `docker-compose.yml`
- Change service name and image if needed
- Adjust ports and environment variables

#### `.github/workflows/deploy.yml`
- Update `image_tag` environment variable if using a different app name

### 3. Create GitHub Secrets

Go to **GitHub** → Your Repo → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Add these secrets (examples provided):

#### Docker Hub Secrets
**`DOCKERHUB_USERNAME`**
```
your-dockerhub-username
```

**`DOCKERHUB_TOKEN`**
- Go to [Docker Hub Settings → Security](https://hub.docker.com/settings/security)
- Click **New Access Token**
- Copy the token (you won't see it again)
- Paste here

#### VPS Access Secrets

**`VPS_HOST`**
```
100.x.y.z
```
(Your VPS Tailscale IP address from `tailscale ip -4` or Tailscale admin console)

**`VPS_USERNAME`**
```
ubuntu
```
(SSH user on your VPS - usually `ubuntu`, `root`, `ec2-user`, etc.)

**`VPS_SSH_KEY`**
```
-----BEGIN OPENSSH PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
...
-----END OPENSSH PRIVATE KEY-----
```
(Your private SSH key. Generate with: `ssh-keygen -t ed25519`)

**`TAILSCALE_AUTHKEY`**
- Go to [Tailscale Admin Console](https://login.tailscale.com/admin/settings/keys)
- Click **Generate auth key**
- Enable "Reusable" and "Expires" (30 days is fine)
- Copy and paste here

### 4. Set Up VPS

SSH into your VPS and run:

```bash
# Install Docker
curl -fsSL https://get.docker.com | sh

# Add your user to docker group (if not root)
sudo usermod -aG docker $USER
newgrp docker

# Install Tailscale
curl -fsSL https://tailscale.com/install.sh | sh

# Join your Tailscale network
sudo tailscale up

# Verify Tailscale IP
tailscale ip -4
```

**Save the Tailscale IP** — this is your `VPS_HOST` secret.

### 5. Push to Main and Deploy

```bash
git add .
git commit -m "Initial application setup"
git push origin main
```

**That's it!** GitHub Actions will:
1. Run tests
2. Build Docker image
3. Push to Docker Hub
4. Deploy to your VPS
5. Verify the application is healthy

Monitor progress: **GitHub** → **Actions** → Watch the workflows run

---

## How It Works

### Architecture

```
Your Local PC
     ↓
GitHub Repository
     ↓
┌────────────────────────────────────────┐
│ GitHub Actions Workflows               │
├────────────────────────────────────────┤
│ 1. CI/CD (ci-cd.yml)                   │
│    └─ Test → Build → Publish Docker    │
│                                         │
│ 2. Deploy (deploy.yml)                 │
│    └─ Tailscale → SSH → Pull → Restart │
│                                         │
│ 3. Test SSH (test-ssh.yml)             │
│    └─ Verify Tailscale connectivity    │
└────────────────────────────────────────┘
     ↓
┌────────────────────────────────────────┐
│ Docker Hub Registry                    │
│ (your-dockerhub-user/my-awesome-app)  │
└────────────────────────────────────────┘
     ↓
┌────────────────────────────────────────┐
│ Your VPS (over Tailscale)              │
│                                         │
│ Docker Container                       │
│ └─ Application on port 8080            │
└────────────────────────────────────────┘
```

### Workflow Sequence (Single Push)

```
Step 1: git push origin main
  ↓
Step 2: CI/CD Workflow Starts
  ├─ Run: ./mvnw test
  ├─ Run: ./mvnw -DskipTests package
  ├─ Build: Docker image
  └─ Push: to Docker Hub (latest + sha-<commit>)
  ↓
Step 3: Deploy Workflow Starts (auto-triggered after CI passes)
  ├─ Install Tailscale on GitHub runner
  ├─ Connect to your Tailscale network
  ├─ SSH into VPS over Tailscale
  ├─ Docker pull latest image
  ├─ Stop/remove old container
  ├─ Start new container
  ├─ Health check (verify app is responding)
  └─ Prune old images
  ↓
Step 4: Your app is LIVE! 🚀
```

### Workflow Files Explained

#### `.github/workflows/ci-cd.yml`
**Triggers:** Push to `main` or Pull Request to `main`

**Jobs:**
- `test`: Runs Maven tests and packages the app
- `docker-build`: Validates Docker build (PRs only)
- `publish`: Pushes Docker image to Docker Hub (main pushes only)

**Image tags created:**
- `your-dockerhub-user/my-awesome-app:latest` (always points to newest)
- `your-dockerhub-user/my-awesome-app:sha-<commit-hash>` (immutable)

#### `.github/workflows/deploy.yml`
**Triggers:** 
- Automatically after CI/CD succeeds on `main`
- OR manually via GitHub Actions UI

**What it does:**
1. Installs Tailscale on the runner
2. Connects to your Tailscale network using `TAILSCALE_AUTHKEY`
3. SSHes into VPS using Tailscale IP
4. Logs into Docker Hub
5. Pulls the Docker image
6. Stops the old container
7. Starts the new container with `--restart unless-stopped`
8. Verifies the app is responding (health check)
9. Cleans up old images

#### `.github/workflows/test-ssh.yml`
**Triggers:** Manual only (for debugging)

**What it does:**
- Connects to Tailscale
- SSHes into VPS
- Runs basic diagnostic commands

Use this to debug connection issues.

---

## Customization Guide

### Changing the Port

Your app runs on a different port? Update three places:

**1. `Dockerfile`**
```dockerfile
EXPOSE 9000  # Change from 8080
```

**2. `docker-compose.yml`**
```yaml
ports:
  - "9000:9000"  # Change from 8080:8080
```

**3. `.github/workflows/deploy.yml`**
```yaml
-p 9000:9000  # Change from 8080:8080
```

### Using Private Docker Registry

Instead of Docker Hub, use private ECR, GCR, etc.?

**In `.github/workflows/ci-cd.yml` (publish job), change:**
```yaml
- name: Log in to Docker Registry
  uses: docker/login-action@v3
  with:
    registry: your-registry.example.com
    username: ${{ secrets.REGISTRY_USERNAME }}
    password: ${{ secrets.REGISTRY_PASSWORD }}
```

**Add secrets:**
- `REGISTRY_USERNAME`
- `REGISTRY_PASSWORD`

### Customizing JVM Settings

Edit `Dockerfile` and `.github/workflows/deploy.yml`:

```dockerfile
ENV JAVA_OPTS="-Xms1g -Xmx2g -XX:+UseG1GC"  # Adjust for your app
```

### Multi-Stage Environments

Deploy to multiple VPS (staging, production)?

**Duplicate `.github/workflows/deploy.yml`:**
- Rename to `deploy-staging.yml`, `deploy-production.yml`
- Update secrets: `VPS_HOST_STAGING`, `VPS_HOST_PRODUCTION`
- Add manual trigger with environment input

### Using Different Java Version

Edit both `pom.xml` and `Dockerfile`:

```xml
<!-- pom.xml -->
<java.version>21</java.version>
```

```dockerfile
# Dockerfile use eclipse-temurin:21-jre-jammy
```

---

## Troubleshooting

### ❌ CI Tests Fail

**Check:** GitHub Actions → CI/CD workflow → Test & Package → Logs

**Common causes:**
- `./mvnw test` fails locally too
- Java version mismatch (check `pom.xml`)
- Missing test dependencies

**Fix:**
```bash
# Test locally first
./mvnw clean test
```

### ❌ Docker Build Fails

**Check:** CI/CD → Build Docker image → Logs

**Common causes:**
- Jar file not found (check pom.xml `<name>` matches)
- Dockerfile syntax error
- Docker Hub credentials wrong

**Fix:**
```bash
# Build locally
docker build -t test-image .
```

### ❌ Deploy Fails to Connect

**Check:** Deploy → Deploy Docker image → Logs

**Error:** `dial tcp ***:22: i/o timeout`

**Causes & fixes:**
1. **Tailscale not connected**
   - Run: `.github/workflows/test-ssh.yml` manually to verify
   - Check `TAILSCALE_AUTHKEY` is valid
   
2. **VPS IP wrong**
   - SSH to VPS: `tailscale ip -4`
   - Update `VPS_HOST` secret with correct IP
   
3. **SSH key wrong**
   - Generate new: `ssh-keygen -t ed25519 -C "github-deploy"`
   - Add public key to VPS: `~/.ssh/authorized_keys`
   - Copy private key to `VPS_SSH_KEY` secret
   
4. **VPS not on Tailscale**
   - SSH to VPS manually and run: `sudo tailscale up`

### ❌ Container Exits After Deploy

**Check:** SSH to VPS, run: `docker logs demo-app`

**Common causes:**
- Application startup error
- Port conflict (something else using 8080)
- Not enough memory

**Fixes:**
```bash
# View logs
docker logs demo-app

# Check port
netstat -tlnp | grep 8080

# Increase heap in deploy.yml
-e JAVA_OPTS="-Xms512m -Xmx1g"
```

### ❌ Health Check Fails After Deploy

**Check:** Deploy → Deploy Docker image → Step: "Waiting for container to be healthy"

**Causes:**
- App startup is slow (increase sleep time)
- Health check endpoint is different
- App crashed right after start

**Fix:**
1. Increase sleep time in `deploy.yml` if app is slow to start
2. Change health check endpoint if not `/api/greeting`

---

## Security Best Practices

### ✅ What This Template Does Right

- **Non-root container user** (runs as `app`, not `root`)
- **Small runtime image** (eclipse-temurin JRE, not full Maven)
- **Secrets in GitHub** (never in code or env files)
- **Immutable image tags** (sha-based tags for rollback)
- **Private network** (Tailscale encrypted VPN)
- **SSH key-based auth** (not password)
- **Read-only permissions** (GitHub token limited to `contents: read`)

### 🔒 Additional Hardening (Optional)

1. **Enable branch protection**
   - GitHub → Settings → Branches → Protect main
   - Require CI to pass before merge
   - Require approved reviews

2. **Scan for secrets**
   - GitHub → Settings → Code security → Enable secret scanning

3. **Monitor dependencies**
   - GitHub → Settings → Dependabot → Enable

4. **Use private image registry**
   - Instead of Docker Hub public, use AWS ECR, Azure ACR, etc.

5. **Add image scanning**
   - Scan for CVEs before publishing

6. **Use short-lived secrets**
   - Docker Hub tokens: 24 hours
   - Tailscale auth keys: 7 days (auto-expire)

---

## Performance Tips

### Build Speed

**Current:** ~2-3 minutes

**Optimize:**
1. GitHub Actions caching (already enabled: `cache-from: type=gha`)
2. Run tests in parallel (update `pom.xml` if needed)
3. Use smaller base image (distroless: `gcr.io/distroless/java17`)

### Deployment Speed

**Current:** ~30 seconds

**Optimize:**
1. Pre-pull image on VPS (cron job)
2. Use health check timeout of 5s instead of 30s
3. Deploy to multiple regions (duplicate workflow)

### Cost Optimization

1. **GitHub Actions:** Free for public repos, 2000 min/month for private
2. **Docker Hub:** Free for public images, $5/month for private
3. **VPS:** $3-5/month minimal (DigitalOcean, Vultr, Linode)
4. **Tailscale:** Free for up to 3 devices, $5/month for more

**Monthly cost estimate:** $8-20 depending on VPS choice

---

## Extending the Template

### Add Staging Environment

Create `.github/workflows/deploy-staging.yml`:
- Different `VPS_HOST_STAGING` secret
- Deploy on PR instead of main push
- Manual approval required

### Add Slack Notifications

Add step in `deploy.yml`:
```yaml
- name: Notify Slack
  uses: slackapi/slack-github-action@v1.24.0
  with:
    payload: |
      {
        "text": "✅ Deployed $IMAGE_TAG to production"
      }
```

### Add Monitoring

Deploy Prometheus/Grafana on VPS:
```yaml
docker run -d -p 9090:9090 prom/prometheus
docker run -d -p 3000:3000 grafana/grafana
```

### Add Database Migrations

If using SQL database:
```yaml
script: |
  docker run --rm \
    --network host \
    my-app:latest \
    ./bin/migrate.sh
```

---

## Support & Debugging

### View Workflow Logs

**GitHub** → Your Repo → **Actions** → Select workflow → View full logs

### SSH to VPS for Debugging

```bash
# Over Tailscale (from anywhere)
tailscale ssh <your-vps-hostname>

# Or direct SSH with Tailscale IP
ssh user@100.x.y.z
```

### Check Tailscale Connection

```bash
# From your laptop
tailscale status

# From VPS
tailscale ip -4
tailscale ip -6
```

### Test Application Endpoint

```bash
# From VPS
curl http://localhost:8080/api/greeting

# From your laptop (if app exposes port publicly)
curl http://<vps-public-ip>:8080/api/greeting
```

---

## FAQ

**Q: Can I deploy to AWS/GCP/Azure?**  
A: Yes! Any VPS with Docker and Tailscale. Works with self-managed servers too.

**Q: What if I don't use Spring Boot?**  
A: Modify `pom.xml`, `Dockerfile`, and health check endpoint. Template works for any Java app.

**Q: Can I deploy multiple apps?**  
A: Duplicate the workflows and secrets (e.g., `deploy-app-2.yml`, `VPS_HOST_APP_2`).

**Q: Is Tailscale required?**  
A: No, but recommended for security. Without it, your VPS SSH port is exposed publicly.

**Q: How do I rollback to a previous version?**  
A: Manually run Deploy workflow with image tag: `sha-<old-commit-hash>`

**Q: Can I run this locally?**  
A: Yes! `docker compose up --build` builds and runs locally.

**Q: What happens if main push breaks the app?**  
A: Health check catches it, logs error, and shows deployment failure in GitHub Actions.

---

## License & Attribution

This template is open source. Feel free to fork, modify, and use for your projects.

**Original Reference:** [tecresearch/git-docker-cicd](https://github.com/tecresearch/git-docker-cicd)

---

## Next Steps

1. ✅ Customize `pom.xml`, `Dockerfile`, workflows
2. ✅ Add GitHub secrets (Docker Hub, VPS, Tailscale)
3. ✅ Set up VPS with Docker & Tailscale
4. ✅ Push to main branch
5. ✅ Watch GitHub Actions automatic pipeline
6. ✅ Access your live app! 🎉

**Questions?**  
Check logs in GitHub Actions → Workflows → Click failed job for error messages.

Happy deploying! 🚀

