# Secrets Management - Local Setup

Complete secrets management solution with HashiCorp Vault and Consul for secure storage and distribution of sensitive data.

## Components Included

### HashiCorp Vault 1.15.4
- **API/UI**: http://localhost:8200
- Secrets management and encryption
- Dynamic secrets generation
- Multiple authentication methods
- Root Token: root (dev mode)

### Vault UI (Alternative)
- **URL**: http://localhost:8000
- Enhanced web interface for Vault
- Better visualization and management

### HashiCorp Consul 1.17
- **UI**: http://localhost:8500
- Service discovery and health checking
- Key/value store
- Can be used as Vault storage backend

## Quick Start

### 1. Start All Services

```bash
docker-compose up -d
```

### 2. Access Vault

**Web UI:**
- Open http://localhost:8200
- Token: `root`

**CLI:**
```bash
export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='root'
vault status
```

### 3. Initialize Sample Secrets

```bash
./scripts/init_vault.sh
```

## Usage Examples

### Basic Secret Operations

**Write Secret:**
```bash
vault kv put secret/myapp/config \
    username=admin \
    password=secret123 \
    api_key=abc-def-ghi
```

**Read Secret:**
```bash
vault kv get secret/myapp/config

# Get specific field
vault kv get -field=password secret/myapp/config
```

**List Secrets:**
```bash
vault kv list secret/
vault kv list secret/myapp/
```

**Delete Secret:**
```bash
vault kv delete secret/myapp/config
```

**Undelete Secret:**
```bash
vault kv undelete -versions=1 secret/myapp/config
```

### Python Integration

```python
import hvac

# Initialize client
client = hvac.Client(url='http://localhost:8200', token='root')

# Write secret
client.secrets.kv.v2.create_or_update_secret(
    path='myapp/config',
    secret=dict(username='admin', password='secret123')
)

# Read secret
secret = client.secrets.kv.v2.read_secret_version(path='myapp/config')
print(secret['data']['data']['username'])
```

### Node.js Integration

```javascript
const vault = require('node-vault')({
  apiVersion: 'v1',
  endpoint: 'http://localhost:8200',
  token: 'root'
});

// Write secret
await vault.write('secret/data/myapp/config', {
  data: {
    username: 'admin',
    password: 'secret123'
  }
});

// Read secret
const result = await vault.read('secret/data/myapp/config');
console.log(result.data.data.username);
```

### Java Integration

```java
import com.bettercloud.vault.Vault;
import com.bettercloud.vault.VaultConfig;

VaultConfig config = new VaultConfig()
    .address("http://localhost:8200")
    .token("root")
    .build();

Vault vault = new Vault(config);

// Write secret
Map<String, Object> secrets = new HashMap<>();
secrets.put("username", "admin");
secrets.put("password", "secret123");
vault.logical().write("secret/data/myapp/config", secrets);

// Read secret
LogicalResponse response = vault.logical().read("secret/data/myapp/config");
String username = response.getData().get("username");
```

## Advanced Features

### Dynamic Database Credentials

**Configure PostgreSQL:**
```bash
vault write database/config/postgresql \
    plugin_name=postgresql-database-plugin \
    allowed_roles="readonly" \
    connection_url="postgresql://{{username}}:{{password}}@postgres:5432/myapp" \
    username="root" \
    password="root"

# Create role
vault write database/roles/readonly \
    db_name=postgresql \
    creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; \
        GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";" \
    default_ttl="1h" \
    max_ttl="24h"

# Generate credentials
vault read database/creds/readonly
```

### PKI (Certificate Management)

**Setup PKI:**
```bash
# Enable PKI
vault secrets enable pki

# Configure CA
vault write pki/root/generate/internal \
    common_name="example.com" \
    ttl=87600h

# Configure URLs
vault write pki/config/urls \
    issuing_certificates="http://localhost:8200/v1/pki/ca" \
    crl_distribution_points="http://localhost:8200/v1/pki/crl"

# Create role
vault write pki/roles/example-dot-com \
    allowed_domains="example.com" \
    allow_subdomains=true \
    max_ttl="720h"

# Issue certificate
vault write pki/issue/example-dot-com \
    common_name="test.example.com" \
    ttl="24h"
```

### AWS Dynamic Credentials

**Configure AWS:**
```bash
vault write aws/config/root \
    access_key=AKIAIOSFODNN7EXAMPLE \
    secret_key=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY \
    region=us-east-1

# Create role
vault write aws/roles/my-role \
    credential_type=iam_user \
    policy_document=-<<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": "*"
    }
  ]
}
EOF

# Generate credentials
vault read aws/creds/my-role
```

### Transit Encryption

**Setup Transit Engine:**
```bash
# Enable transit
vault secrets enable transit

# Create encryption key
vault write -f transit/keys/my-key

# Encrypt data
vault write transit/encrypt/my-key \
    plaintext=$(echo "my secret data" | base64)

# Decrypt data
vault write transit/decrypt/my-key \
    ciphertext=vault:v1:8SDd3WHDOjf7mq69CyCqYjBXAiQQAVZRkFM13ok481zoCmHnSeDX9vyf7w==
```

## Authentication Methods

### Token Authentication (Default)

```bash
vault login root
```

### AppRole Authentication

```bash
# Enable AppRole
vault auth enable approle

# Create role
vault write auth/approle/role/my-role \
    secret_id_ttl=10m \
    token_num_uses=10 \
    token_ttl=20m \
    token_max_ttl=30m \
    secret_id_num_uses=40

# Get role ID
vault read auth/approle/role/my-role/role-id

# Generate secret ID
vault write -f auth/approle/role/my-role/secret-id

# Login with AppRole
vault write auth/approle/login \
    role_id=<role-id> \
    secret_id=<secret-id>
```

### Userpass Authentication

```bash
# Enable userpass
vault auth enable userpass

# Create user
vault write auth/userpass/users/myuser \
    password=mypassword \
    policies=default

# Login
vault login -method=userpass \
    username=myuser \
    password=mypassword
```

## Policies

### Create Policy

```bash
# Write policy file
cat > my-policy.hcl <<EOF
path "secret/data/myapp/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/metadata/myapp/*" {
  capabilities = ["list"]
}
EOF

# Apply policy
vault policy write my-policy my-policy.hcl

# Assign policy to token
vault token create -policy=my-policy
```

## Monitoring

### Check Vault Status

```bash
vault status
```

### View Audit Logs

```bash
# Enable audit logging
vault audit enable file file_path=/vault/logs/audit.log

# View logs
docker exec vault cat /vault/logs/audit.log
```

### Metrics

```bash
# Prometheus metrics
curl http://localhost:8200/v1/sys/metrics?format=prometheus
```

## Backup & Restore

### Backup Secrets

```bash
# Export all secrets (requires appropriate permissions)
vault kv get -format=json secret/myapp/config > backup.json
```

### Restore Secrets

```bash
# Import secrets
cat backup.json | jq -r '.data.data' | vault kv put secret/myapp/config -
```

### Backup Vault Data

```bash
# Backup file storage
docker cp vault:/vault/file ./vault_backup
```

## Troubleshooting

### Vault Sealed

```bash
# Check status
vault status

# Unseal (in production, requires unseal keys)
vault operator unseal <unseal-key>
```

### Connection Issues

```bash
# Check if Vault is running
docker exec vault vault status

# Check logs
docker-compose logs vault

# Verify network
curl http://localhost:8200/v1/sys/health
```

### Token Expired

```bash
# Create new token
vault token create

# Renew token
vault token renew
```

## Security Best Practices

⚠️ **For local development only!**

Production recommendations:
- **Never use dev mode** - Use proper storage backend
- **Enable TLS** - Always use HTTPS
- **Seal Vault** - Use auto-unseal with cloud KMS
- **Audit logging** - Enable comprehensive audit logs
- **Least privilege** - Use fine-grained policies
- **Rotate tokens** - Implement token rotation
- **Backup regularly** - Automated backup strategy
- **Monitor access** - Track all secret access
- **Network isolation** - Restrict network access
- **MFA** - Enable multi-factor authentication

## Integration Examples

### Spring Boot

```yaml
spring:
  cloud:
    vault:
      uri: http://localhost:8200
      token: root
      kv:
        enabled: true
        backend: secret
```

### Docker Compose

```yaml
services:
  myapp:
    image: myapp:latest
    environment:
      VAULT_ADDR: http://vault:8200
      VAULT_TOKEN: root
    command: sh -c "vault kv get -field=password secret/myapp/config"
```

### Kubernetes

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  serviceAccountName: myapp
  containers:
  - name: myapp
    image: myapp:latest
    env:
    - name: VAULT_ADDR
      value: "http://vault:8200"
```

## Consul Integration

### Service Registration

```bash
# Register service
curl -X PUT http://localhost:8500/v1/agent/service/register \
  -d '{
    "Name": "myapp",
    "Port": 8080,
    "Check": {
      "HTTP": "http://localhost:8080/health",
      "Interval": "10s"
    }
  }'

# Query service
curl http://localhost:8500/v1/catalog/service/myapp
```

### KV Store

```bash
# Put value
curl -X PUT http://localhost:8500/v1/kv/myapp/config \
  -d 'configuration data'

# Get value
curl http://localhost:8500/v1/kv/myapp/config
```

## Cleanup

```bash
# Stop all services
docker-compose down

# Remove all data
docker-compose down -v
```

## Environment Variables

Create `.env` file:

```env
# Vault
VAULT_ROOT_TOKEN=root
VAULT_ADDR=http://localhost:8200
```

## Useful Commands

```bash
# List all secrets engines
vault secrets list

# List all auth methods
vault auth list

# List all policies
vault policy list

# View policy
vault policy read default

# Token lookup
vault token lookup

# Renew token
vault token renew

# Revoke token
vault token revoke <token>
```
