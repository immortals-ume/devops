# CI/CD Configuration Guide

Complete CI/CD setup for Jenkins, GitHub Actions, and GitLab CI.

## Overview

This repository includes comprehensive CI/CD configurations for:
- ✅ **GitHub Actions** - 5 workflows
- ✅ **GitLab CI** - Enhanced pipeline
- ✅ **Jenkins** - Declarative pipeline

## GitHub Actions Workflows

### 1. CI Pipeline (`.github/workflows/ci.yml`)

**Triggers:**
- Push to main/master/develop
- Pull requests

**Jobs:**
- Lint code
- Run tests with coverage
- Security scanning (Trivy, npm audit)
- Build Docker image
- Push to GitHub Container Registry

**Usage:**
```bash
# Automatically runs on push/PR
# View results in Actions tab
```

### 2. Kubernetes Deployment (`.github/workflows/cd-kubernetes.yml`)

**Triggers:**
- Push to main/master (k8s/** changes)
- Manual workflow dispatch

**Features:**
- Deploy to multiple environments
- Kubectl configuration
- Smoke tests
- Deployment verification

**Usage:**
```bash
# Manual deployment
# Go to Actions → CD - Kubernetes Deployment → Run workflow
# Select environment: dev, sit, uat, preprod, production
```

### 3. Helm Deployment (`.github/workflows/cd-helm.yml`)

**Triggers:**
- Push to main/master (helm-charts/** changes)
- Manual workflow dispatch

**Features:**
- Deploy specific charts or all
- Environment selection
- Helm release verification

**Usage:**
```bash
# Manual deployment
# Actions → CD - Helm Deployment → Run workflow
# Select environment and chart
```

### 4. Helmfile Deployment (`.github/workflows/cd-helmfile.yml`)

**Triggers:**
- Push to main/master (helmfile/** changes)
- Manual workflow dispatch

**Features:**
- Multi-service orchestration
- Dependency management
- Diff before apply
- Multiple actions (diff, apply, sync, destroy)

**Usage:**
```bash
# Manual deployment
# Actions → CD - Helmfile Deployment → Run workflow
# Select environment and action
```

### 5. Docker Publish (`.github/workflows/docker-publish.yml`)

**Triggers:**
- Push to main/master
- Tags (v*)
- Pull requests

**Features:**
- Multi-platform builds (amd64, arm64)
- Semantic versioning
- Image signing with cosign
- Cache optimization

**Usage:**
```bash
# Automatically runs on push
# Tag for release: git tag v1.0.0 && git push --tags
```

## GitLab CI Pipeline

### Stages

1. **Validate** - YAML, Helm, Kubernetes validation
2. **Test** - Unit and integration tests
3. **Security** - Trivy, npm audit, SonarQube
4. **Build** - Docker image and Helm packages
5. **Deploy Dev** - Development environment
6. **Deploy Staging** - Staging environment
7. **Deploy Production** - Production environment

### Features

- ✅ Parallel job execution
- ✅ Caching for faster builds
- ✅ Security scanning
- ✅ Code coverage reporting
- ✅ Manual deployment gates
- ✅ Environment-specific deployments
- ✅ Helmfile integration

### Usage

```bash
# Automatically runs on push
# Manual deployments require approval in GitLab UI
```

### Required Variables

Set in GitLab CI/CD Settings → Variables:

```
CI_REGISTRY_USER        # GitLab registry username
CI_REGISTRY_PASSWORD    # GitLab registry password
KUBE_CONFIG            # Base64 encoded kubeconfig for dev
KUBE_CONFIG_STAGING    # Base64 encoded kubeconfig for staging
KUBE_CONFIG_PROD       # Base64 encoded kubeconfig for production
SONAR_HOST_URL         # SonarQube server URL
SONAR_TOKEN            # SonarQube authentication token
```

## Jenkins Pipeline

### Features

- ✅ Declarative pipeline syntax
- ✅ Parallel execution
- ✅ Manual approval gates
- ✅ Comprehensive testing
- ✅ Security scanning
- ✅ Multi-environment deployment
- ✅ Smoke tests

### Stages

1. **Checkout** - Get source code
2. **Validate** - Validate configurations
3. **Test** - Unit and integration tests
4. **Security Scan** - Multiple security tools
5. **Build** - Docker image
6. **Package** - Helm charts
7. **Deploy Dev** - Development (manual)
8. **Deploy Staging** - Staging (manual)
9. **Deploy Production** - Production (manual, admin only)
10. **Smoke Tests** - Post-deployment verification

### Setup

#### 1. Install Required Plugins

```
- Docker Pipeline
- Kubernetes CLI
- SonarQube Scanner
- Pipeline
- Git
- Credentials Binding
```

#### 2. Configure Credentials

In Jenkins → Manage Jenkins → Credentials:

```
docker-hub-credentials    # Docker Hub username/password
kubeconfig-dev           # Kubernetes config for dev
kubeconfig-staging       # Kubernetes config for staging
kubeconfig-prod          # Kubernetes config for production
sonar-token              # SonarQube token
```

#### 3. Configure Tools

In Jenkins → Global Tool Configuration:

```
- Docker
- kubectl (v1.28.0)
- Helm (v3.13.0)
- SonarQube Scanner
```

#### 4. Create Pipeline Job

```
1. New Item → Pipeline
2. Pipeline → Definition: Pipeline script from SCM
3. SCM: Git
4. Repository URL: <your-repo-url>
5. Script Path: Jenkinsfile
6. Save
```

### Usage

```bash
# Trigger manually or via webhook
# Approve deployments in Jenkins UI
```

## Environment Setup

### GitHub Actions

#### Required Secrets

Settings → Secrets and variables → Actions:

```
KUBECONFIG              # Base64 encoded kubeconfig
SONAR_TOKEN            # SonarQube token
SONAR_HOST_URL         # SonarQube server URL
```

#### Encode kubeconfig

```bash
cat ~/.kube/config | base64 | tr -d '\n'
```

### GitLab CI

#### Required Variables

Settings → CI/CD → Variables:

```
KUBE_CONFIG            # Base64 encoded kubeconfig (dev)
KUBE_CONFIG_STAGING    # Base64 encoded kubeconfig (staging)
KUBE_CONFIG_PROD       # Base64 encoded kubeconfig (production)
SONAR_TOKEN            # SonarQube token
SONAR_HOST_URL         # SonarQube server URL
```

### Jenkins

#### Configure Credentials

```bash
# Docker Hub
Username: <docker-username>
Password: <docker-password>

# Kubernetes
Kind: Secret file
File: kubeconfig

# SonarQube
Kind: Secret text
Secret: <sonar-token>
```

## Deployment Workflows

### Development Deployment

**GitHub Actions:**
```bash
Actions → CD - Helmfile Deployment → Run workflow
Environment: dev
Action: apply
```

**GitLab CI:**
```bash
# Automatically triggered on develop branch
# Manual approval required
```

**Jenkins:**
```bash
# Build develop branch
# Approve "Deploy to Development" stage
```

### Production Deployment

**GitHub Actions:**
```bash
Actions → CD - Helmfile Deployment → Run workflow
Environment: production
Action: diff  # Review changes first
Action: apply # Deploy
```

**GitLab CI:**
```bash
# Push to main branch
# Approve staging deployment
# Approve production deployment
```

**Jenkins:**
```bash
# Build main branch
# Approve "Deploy to Staging"
# Approve "Deploy to Production" (admin only)
```

## Best Practices

### 1. Always Review Changes

```bash
# GitHub Actions
helmfile -e production diff

# GitLab CI
# Check diff job output

# Jenkins
# Review diff in console output
```

### 2. Use Manual Approvals

- Development: Optional
- Staging: Recommended
- Production: Required

### 3. Run Smoke Tests

```bash
# Verify deployment
kubectl get pods -A
kubectl run smoke-test --image=curlimages/curl --rm -i --restart=Never -- \
  curl -f http://myapp.myapp.svc.cluster.local/health
```

### 4. Monitor Deployments

```bash
# Watch pods
kubectl get pods -n myapp -w

# Check logs
kubectl logs -n myapp -l app=backend -f

# Check events
kubectl get events -n myapp --sort-by='.lastTimestamp'
```

### 5. Rollback if Needed

**Helm:**
```bash
helm rollback <release-name> -n <namespace>
```

**Helmfile:**
```bash
helmfile -e production sync  # Restore to defined state
```

**Kubernetes:**
```bash
kubectl rollout undo deployment/<name> -n <namespace>
```

## Troubleshooting

### GitHub Actions

**Issue: Workflow not triggering**
```bash
# Check workflow file syntax
# Verify branch names in triggers
# Check repository settings → Actions
```

**Issue: Deployment fails**
```bash
# Check secrets are set correctly
# Verify kubeconfig is valid
# Check cluster connectivity
```

### GitLab CI

**Issue: Pipeline fails**
```bash
# Check CI/CD variables
# Verify runner is available
# Check job logs for errors
```

**Issue: Cannot connect to cluster**
```bash
# Verify KUBE_CONFIG variable
# Check base64 encoding
# Test kubeconfig locally
```

### Jenkins

**Issue: Build fails**
```bash
# Check credentials configuration
# Verify plugins are installed
# Check tool configurations
# Review console output
```

**Issue: Deployment hangs**
```bash
# Check cluster connectivity
# Verify kubectl/helm versions
# Check resource availability
```

## Security Considerations

### 1. Secrets Management

- Never commit secrets to repository
- Use CI/CD secret management
- Rotate secrets regularly
- Use least-privilege access

### 2. Image Security

- Scan images for vulnerabilities
- Use specific image tags (not latest)
- Sign images with cosign
- Use private registries

### 3. Access Control

- Require approvals for production
- Limit who can approve deployments
- Use branch protection rules
- Enable audit logging

### 4. Network Security

- Use NetworkPolicies
- Enable TLS everywhere
- Restrict cluster access
- Use VPN for sensitive environments

## Monitoring & Alerts

### Setup Notifications

**GitHub Actions:**
```yaml
# Add to workflow
- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

**GitLab CI:**
```yaml
# Add to .gitlab-ci.yml
after_script:
  - 'curl -X POST -H "Content-Type: application/json" -d "{\"text\":\"Pipeline $CI_PIPELINE_STATUS\"}" $SLACK_WEBHOOK'
```

**Jenkins:**
```groovy
// Add to Jenkinsfile post section
post {
    failure {
        slackSend(
            color: 'danger',
            message: "Build failed: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
        )
    }
}
```

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [GitLab CI Documentation](https://docs.gitlab.com/ee/ci/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Helm Documentation](https://helm.sh/docs/)
- [Helmfile Documentation](https://github.com/helmfile/helmfile)

## Support

For issues or questions:
1. Check pipeline logs
2. Verify configurations
3. Test locally first
4. Review this guide
5. Check tool documentation

---

**Last Updated**: November 9, 2024  
**Version**: 1.0  
**Status**: Complete
