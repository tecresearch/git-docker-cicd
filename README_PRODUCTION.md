# Production-Grade CI/CD Template

[![CI/CD](https://github.com/tecresearch/git-docker-cicd/actions/workflows/ci-cd.yml/badge.svg?branch=main)](https://github.com/tecresearch/git-docker-cicd/actions/workflows/ci-cd.yml)

**This is a production-ready template for Java/Spring Boot applications** with automated testing, Docker containerization, and secure VPS deployment over Tailscale.

## 📚 Documentation

This project includes comprehensive guides for setup and customization:

### 👉 **Start Here:** [Production Template Complete Guide](README_PRODUCTION_TEMPLATE.md)
- Full setup instructions (5 minutes)
- Architecture overview
- Troubleshooting guide
- FAQ and examples

### 🔧 Component Guides
- **VPS Setup:** [VPS_SETUP_GUIDE.md](VPS_SETUP_GUIDE.md) — Install Docker, Tailscale, prepare deployments
- **GitHub Secrets:** [GITHUB_SECRETS_SETUP.md](GITHUB_SECRETS_SETUP.md) — Configure credentials and access keys
- **Local Development:** [docker-compose.yml](docker-compose.yml) — `docker compose up --build`

## 🚀 Quick Start (for experienced users)

This project includes a multi-stage `Dockerfile`, a `docker-compose.yml`, and GitHub Actions workflows to build, test, and publish the Spring Boot application.

How the Dockerfile works
- Build stage: uses the project's Maven wrapper (`./mvnw`) to download dependencies and package the application. Dependencies are fetched in a separate cached layer for faster incremental builds.
- Runtime stage: based on Eclipse Temurin JRE 17 (Debian jammy), creates a non-root `app` user, installs `curl` for health checks, copies the built fat jar, and runs it with configurable `JAVA_OPTS`.

Build & run locally
1. Ensure Docker is installed and the Docker daemon is running.
2. Build the image:
```
docker build -t demo-app:latest .
```
3. Run the container:
```
docker run --rm -p 8080:8080 --name demo-app demo-app:latest
```
Or using Docker Compose:
```
docker compose up --build
```

Healthcheck
The image exposes a simple Docker HEALTHCHECK which calls `/api/greeting`.

Environment configuration
- `JAVA_OPTS` can be provided at runtime to tune heap or GC settings.

CI/CD workflow
- Workflow file: `.github/workflows/ci-cd.yml`
- PRs to `main` run validation only.
- Pushes to `main` run tests, package the app, and automatically publish the Docker image to Docker Hub.
- CI steps:
  - run Maven tests with `./mvnw test`
  - package the application with `./mvnw -DskipTests package`
  - validate the Docker build on pull requests
- CD pushes these Docker Hub tags on every `main` push:
  - `your-dockerhub-user/demo-app:latest`
  - `your-dockerhub-user/demo-app:sha-<commit-sha>`
- Recommended next step: protect the `main` branch and require the CI workflow to pass before merging.

Deployment workflow
- Workflow file: `.github/workflows/deploy.yml`
- Trigger: automatic after successful `CI/CD` completion on `main`, plus manual (`workflow_dispatch`)
- What it does:
  1. Connects the GitHub runner to your Tailscale network
  2. SSHes into the VPS over Tailscale
  3. Logs into Docker Hub on the VPS
  4. Pulls the selected image tag
  5. Stops/removes the old `demo-app` container
  6. Starts the new container with the updated image
- Automatic deployments use the tested commit tag: `sha-<commit-sha>`
- Manual deployments default to `latest`, and you can override the tag when running the workflow manually (for example, `sha-<commit-sha>`)

Required GitHub secrets
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`
- `TAILSCALE_AUTHKEY`
- `VPS_HOST`
- `VPS_USERNAME`
- `VPS_SSH_KEY`

Simple deployment flow
1. Make changes locally.
2. Push them to the `main` branch on GitHub.
3. GitHub Actions will test the code, build the image, and publish the updated Docker image to Docker Hub automatically.
4. After CI passes, GitHub Actions will automatically deploy the matching image to the VPS over Tailscale.
5. You can still run the deployment workflow manually if needed.

Notes
- For a smaller production image consider building a custom runtime with `jlink` or using a distroless image. This Dockerfile favors clarity and reliability.

