# Docker Usage Guide

## Building Images

### Maven/Java
```sh
# From project root
cd docker
# Build the image (replace <tag> as needed)
docker build -f Dockerfile -t myapp-maven:<tag> ..
```

### Gradle/Java
```sh
cd docker
# Build the image (replace <tag> as needed)
docker build -f Dockerfile-gradle -t myapp-gradle:<tag> ..
```

## Tagging and Pushing Images
```sh
# Tag the image for your registry
docker tag myapp-maven:<tag> <your-registry>/myapp-maven:<tag>
# Push the image
docker push <your-registry>/myapp-maven:<tag>
```

## Best Practices
- Use multi-stage builds to keep images small and secure.
- Always run as a non-root user in production.
- Add a HEALTHCHECK to your Dockerfile.
- Use a `.dockerignore` file to speed up builds and avoid leaking secrets.
- Pin base image versions for reproducibility.
- Scan images for vulnerabilities (see CI/CD pipeline below).

## Sample CI/CD Pipeline (GitHub Actions)
```yaml
name: Docker Build & Push
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
      - name: Login to DockerHub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      - name: Build Docker image
        run: |
          docker build -f docker/Dockerfile -t ${{ secrets.DOCKER_USERNAME }}/myapp-maven:${{ github.sha }} .
      - name: Push Docker image
        run: |
          docker push ${{ secrets.DOCKER_USERNAME }}/myapp-maven:${{ github.sha }}
      - name: Scan image for vulnerabilities
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: ${{ secrets.DOCKER_USERNAME }}/myapp-maven:${{ github.sha }}
```

---
For more advanced scenarios (multi-arch, private registries, etc.), see Docker and CI/CD documentation. 