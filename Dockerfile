# Multi-stage Dockerfile
# Build stage: use Maven to build the Spring Boot fat jar
FROM maven:3.9.4-eclipse-temurin-17 AS build
WORKDIR /workspace

# Copy only the files needed to download dependencies first (cached layer)
COPY pom.xml ./
COPY mvnw mvnw
COPY .mvn .mvn

# Ensure the wrapper is executable
RUN chmod +x mvnw

# Download dependencies to leverage Docker cache for unchanged pom
RUN ./mvnw -B -DskipTests dependency:go-offline

# Now copy sources and build the application (skip tests for faster builds)
COPY src src
RUN ./mvnw -B -DskipTests package -DskipTests

# Runtime stage: use a minimal JRE image
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Install curl for HEALTHCHECK (small overhead, required to probe HTTP endpoint)
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# Create non-root user to run the application
RUN groupadd -r app && useradd -r -g app -d /app -s /sbin/nologin app \
	&& mkdir -p /app/logs && chown -R app:app /app

# Copy the jar produced in the build stage. Using wildcard to pick the jar.
COPY --from=build /workspace/target/*.jar app.jar
RUN chown app:app /app/app.jar

EXPOSE 8080

# Default JVM options (can be overridden via environment variable)
ENV JAVA_OPTS="-Xms256m -Xmx512m -Djava.security.egd=file:/dev/./urandom"

# Run as non-root user
USER app

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]

# Simple HTTP healthcheck hitting the app endpoint
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:8080/api/greeting || exit 1

