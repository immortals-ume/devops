# SonarQube - Code Quality & Security Analysis

Complete code quality and security analysis platform for continuous inspection of code quality.

## Components Included

### SonarQube 10.3.0 Community Edition
- **Web UI**: http://localhost:9000
- Code quality and security analysis
- Support for 29+ programming languages
- Quality gates and metrics
- Default credentials: admin/admin

### PostgreSQL 15
- Database backend for SonarQube
- Persistent storage for analysis results

### SonarScanner CLI 5.0
- Command-line scanner for code analysis
- Available via docker profile

## Quick Start

### 1. Start SonarQube

```bash
docker-compose up -d
```

Wait for SonarQube to start (can take 2-3 minutes):

```bash
# Check status
docker-compose logs -f sonarqube

# Wait for "SonarQube is operational" message
```

### 2. Access SonarQube

- Open http://localhost:9000
- Login with: **admin** / **admin**
- Change password on first login

### 3. Create Your First Project

1. Click "Create Project" → "Manually"
2. Enter project key and name
3. Generate a token
4. Choose your build tool
5. Follow the instructions

## Scanning Projects

### Maven Project

**Add to pom.xml:**
```xml
<properties>
    <sonar.host.url>http://localhost:9000</sonar.host.url>
</properties>
```

**Run analysis:**
```bash
mvn clean verify sonar:sonar \
  -Dsonar.projectKey=my-project \
  -Dsonar.login=your-token
```

### Gradle Project

**Add to build.gradle:**
```groovy
plugins {
    id "org.sonarqube" version "4.4.1.3373"
}

sonar {
    properties {
        property "sonar.projectKey", "my-project"
        property "sonar.host.url", "http://localhost:9000"
        property "sonar.login", "your-token"
    }
}
```

**Run analysis:**
```bash
./gradlew sonar
```

### Node.js Project

**Install scanner:**
```bash
npm install -g sonarqube-scanner
```

**Create sonar-project.properties:**
```properties
sonar.projectKey=my-project
sonar.projectName=My Project
sonar.projectVersion=1.0
sonar.sources=src
sonar.host.url=http://localhost:9000
sonar.login=your-token
```

**Run analysis:**
```bash
sonar-scanner
```

### Python Project

**Install scanner:**
```bash
pip install sonar-scanner
```

**Create sonar-project.properties:**
```properties
sonar.projectKey=my-project
sonar.projectName=My Project
sonar.projectVersion=1.0
sonar.sources=.
sonar.python.version=3.9
sonar.host.url=http://localhost:9000
sonar.login=your-token
```

**Run analysis:**
```bash
sonar-scanner
```

### Using Docker Scanner

**Place your project in `./projects/myproject/`:**

```bash
# Copy project
cp -r /path/to/myproject ./projects/

# Create sonar-project.properties in project root
cat > ./projects/myproject/sonar-project.properties <<EOF
sonar.projectKey=myproject
sonar.projectName=My Project
sonar.sources=.
sonar.host.url=http://sonarqube:9000
sonar.login=your-token
EOF

# Run scanner
docker-compose run --rm sonar_scanner \
  -Dproject.settings=/usr/src/myproject/sonar-project.properties
```

## CI/CD Integration

### GitHub Actions

```yaml
name: SonarQube Analysis

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  sonarqube:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0
      
      - name: SonarQube Scan
        uses: sonarsource/sonarqube-scan-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
          SONAR_HOST_URL: http://your-sonarqube:9000
```

### GitLab CI

```yaml
sonarqube-check:
  image: 
    name: sonarsource/sonar-scanner-cli:latest
    entrypoint: [""]
  variables:
    SONAR_USER_HOME: "${CI_PROJECT_DIR}/.sonar"
    GIT_DEPTH: "0"
  cache:
    key: "${CI_JOB_NAME}"
    paths:
      - .sonar/cache
  script: 
    - sonar-scanner
  only:
    - merge_requests
    - main
```

### Jenkins Pipeline

```groovy
pipeline {
    agent any
    
    stages {
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh 'mvn clean verify sonar:sonar'
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
    }
}
```

## Quality Gates

### Create Custom Quality Gate

1. Go to **Quality Gates** → **Create**
2. Add conditions:
   - Coverage < 80%
   - Duplicated Lines > 3%
   - Maintainability Rating worse than A
   - Reliability Rating worse than A
   - Security Rating worse than A
3. Set as default

### Quality Gate in CI/CD

**Check quality gate status:**
```bash
# Get project status
curl -u admin:admin \
  "http://localhost:9000/api/qualitygates/project_status?projectKey=my-project"
```

## Configuration

### System Requirements

**Increase system limits (required for Elasticsearch):**

```bash
# Linux
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=65536

# macOS (Docker Desktop)
# Settings → Resources → Advanced
# Memory: 4GB minimum
```

**Make permanent (Linux):**
```bash
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=65536" | sudo tee -a /etc/sysctl.conf
```

### Configure Analysis Properties

**Global settings:**
- Administration → Configuration → General Settings

**Project settings:**
- Project → Administration → General Settings

### Install Plugins

1. Go to **Administration** → **Marketplace**
2. Search for plugins
3. Install and restart

**Popular plugins:**
- SonarJava
- SonarJS
- SonarPython
- SonarC#
- SonarGo
- SonarKotlin

## API Usage

### Authentication

**Generate token:**
1. User → My Account → Security
2. Generate Token
3. Use in API calls

### Common API Calls

**Get project metrics:**
```bash
curl -u your-token: \
  "http://localhost:9000/api/measures/component?component=my-project&metricKeys=coverage,bugs,vulnerabilities"
```

**Get issues:**
```bash
curl -u your-token: \
  "http://localhost:9000/api/issues/search?componentKeys=my-project&resolved=false"
```

**Get quality gate status:**
```bash
curl -u your-token: \
  "http://localhost:9000/api/qualitygates/project_status?projectKey=my-project"
```

## Monitoring

### Health Check

```bash
# System health
curl http://localhost:9000/api/system/health

# System status
curl http://localhost:9000/api/system/status
```

### Logs

```bash
# View SonarQube logs
docker-compose logs -f sonarqube

# View database logs
docker-compose logs -f sonarqube_db
```

### Metrics

**Access metrics:**
- Administration → System → System Info
- View memory, CPU, database stats

## Backup & Restore

### Backup

```bash
# Backup database
docker exec sonarqube_db pg_dump -U sonar sonarqube > sonarqube_backup.sql

# Backup data directory
docker cp sonarqube:/opt/sonarqube/data ./sonarqube_data_backup
```

### Restore

```bash
# Restore database
cat sonarqube_backup.sql | docker exec -i sonarqube_db psql -U sonar sonarqube

# Restore data
docker cp ./sonarqube_data_backup sonarqube:/opt/sonarqube/data
docker-compose restart sonarqube
```

## Troubleshooting

### SonarQube Won't Start

**Check logs:**
```bash
docker-compose logs sonarqube
```

**Common issues:**
- Insufficient memory (increase to 4GB)
- vm.max_map_count too low
- Database connection issues

**Fix vm.max_map_count:**
```bash
# Temporary
sudo sysctl -w vm.max_map_count=262144

# Permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

### Analysis Fails

**Check scanner logs:**
```bash
# Enable debug mode
mvn sonar:sonar -X

# Or for sonar-scanner
sonar-scanner -X
```

**Common issues:**
- Invalid token
- Network connectivity
- Missing sonar-project.properties
- Unsupported language version

### Database Connection Issues

```bash
# Check database status
docker exec sonarqube_db pg_isready -U sonar

# Check connection from SonarQube
docker exec sonarqube nc -zv sonarqube_db 5432
```

### Performance Issues

**Increase memory:**
```yaml
# In docker-compose.yml
environment:
  SONAR_WEB_JAVAADDITIONALOPTS: "-Xmx2g -Xms512m"
  SONAR_CE_JAVAADDITIONALOPTS: "-Xmx2g -Xms512m"
```

## Best Practices

### Code Coverage

**Integrate with test coverage tools:**
- JaCoCo (Java)
- Istanbul (JavaScript)
- Coverage.py (Python)
- SimpleCov (Ruby)

**Example with JaCoCo:**
```xml
<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.11</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>test</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### Quality Profiles

1. Create custom quality profile
2. Activate/deactivate rules
3. Set severity levels
4. Assign to projects

### Branch Analysis

**Analyze branches:**
```bash
mvn sonar:sonar \
  -Dsonar.branch.name=feature/my-feature
```

**Analyze pull requests:**
```bash
mvn sonar:sonar \
  -Dsonar.pullrequest.key=123 \
  -Dsonar.pullrequest.branch=feature/my-feature \
  -Dsonar.pullrequest.base=main
```

## Security

⚠️ **For local development only!**

Production recommendations:
- **Change default password** immediately
- **Enable HTTPS** with valid certificates
- **Use strong authentication** (LDAP, SAML, OAuth)
- **Implement RBAC** with proper permissions
- **Regular backups** of database and data
- **Keep updated** with latest security patches
- **Network isolation** - restrict access
- **Audit logs** - enable and monitor
- **Token rotation** - rotate API tokens regularly

## Cleanup

```bash
# Stop services
docker-compose down

# Remove all data
docker-compose down -v
```

## Environment Variables

Create `.env` file:

```env
# Database
SONAR_DB_USER=sonar
SONAR_DB_PASSWORD=sonar
SONAR_DB_NAME=sonarqube

# SonarQube
SONAR_TOKEN=your-token-here
SONAR_PASSWORD=admin
```

## Useful Commands

```bash
# Start SonarQube
docker-compose up -d

# View logs
docker-compose logs -f sonarqube

# Restart SonarQube
docker-compose restart sonarqube

# Check health
curl http://localhost:9000/api/system/health

# Access database
docker exec -it sonarqube_db psql -U sonar sonarqube

# Run scanner
docker-compose run --rm sonar_scanner
```

## Resources

- **Documentation**: https://docs.sonarqube.org/
- **Community**: https://community.sonarsource.com/
- **Rules**: https://rules.sonarsource.com/
- **Plugins**: https://docs.sonarqube.org/latest/instance-administration/marketplace/
