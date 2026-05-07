# Production containerization and CI/CD

[![CI/CD](https://github.com/tecresearch/git-docker-cicd/actions/workflows/ci-cd.yml/badge.svg?branch=main)](https://github.com/tecresearch/git-docker-cicd/actions/workflows/ci-cd.yml)

This project includes a multi-stage `Dockerfile`, a `docker-compose.yml`, and a GitHub Actions workflow to build, test, and publish the Spring Boot application.

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

Required GitHub secrets
- `DOCKERHUB_USERNAME`
- `DOCKERHUB_TOKEN`

Simple deployment flow
1. Make changes locally.
2. Push them to the `main` branch on GitHub.
3. GitHub Actions will test the code, build the image, and publish the updated Docker image to Docker Hub automatically.

Notes
- For a smaller production image consider building a custom runtime with `jlink` or using a distroless image. This Dockerfile favors clarity and reliability.

