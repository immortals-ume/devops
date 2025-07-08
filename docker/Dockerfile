# Build stage
FROM maven:3.8.7-openjdk-11-slim AS build
WORKDIR /app
# Uncomment if you want to copy your project
# COPY . .
# RUN mvn clean package -DskipTests

# Runtime stage
FROM openjdk:11-jre-slim
LABEL authors="kaish"
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

# Create non-root user
RUN useradd -m appuser
USER appuser

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s CMD curl -f http://localhost:8080/ || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
