#!/bin/bash
# Initialize Vault with sample secrets
set -e

export VAULT_ADDR='http://localhost:8200'
export VAULT_TOKEN='root'

echo "Waiting for Vault to be ready..."
until vault status > /dev/null 2>&1; do
    echo "Waiting for Vault..."
    sleep 2
done

echo "Vault is ready!"
echo ""

# Enable KV v2 secrets engine
echo "Enabling KV v2 secrets engine..."
vault secrets enable -path=secret kv-v2 2>/dev/null || echo "KV v2 already enabled"

# Store sample secrets
echo "Storing sample secrets..."
vault kv put secret/database/config \
    username=dbuser \
    password=dbpassword \
    host=localhost \
    port=5432

vault kv put secret/api/keys \
    api_key=sample-api-key-12345 \
    api_secret=sample-api-secret-67890

vault kv put secret/app/config \
    environment=development \
    debug=true \
    log_level=info

echo ""
echo "Sample secrets created!"
echo ""
echo "To read secrets:"
echo "  vault kv get secret/database/config"
echo "  vault kv get secret/api/keys"
echo "  vault kv get secret/app/config"
echo ""

# Enable database secrets engine
echo "Enabling database secrets engine..."
vault secrets enable database 2>/dev/null || echo "Database engine already enabled"

# Enable AWS secrets engine
echo "Enabling AWS secrets engine..."
vault secrets enable -path=aws aws 2>/dev/null || echo "AWS engine already enabled"

# Enable PKI secrets engine
echo "Enabling PKI secrets engine..."
vault secrets enable pki 2>/dev/null || echo "PKI engine already enabled"

echo ""
echo "Vault initialization complete!"
echo "Access Vault UI at: http://localhost:8200"
echo "Root Token: root"
