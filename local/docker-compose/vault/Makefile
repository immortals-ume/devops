.PHONY: help up down restart logs ps init test clean

help:
	@echo "Secrets Management - Local Setup"
	@echo ""
	@echo "Available commands:"
	@echo "  make up       - Start Vault and Consul"
	@echo "  make down     - Stop all services"
	@echo "  make restart  - Restart all services"
	@echo "  make logs     - View logs from all containers"
	@echo "  make ps       - Show container status"
	@echo "  make init     - Initialize Vault with sample secrets"
	@echo "  make test     - Test Vault connectivity"
	@echo "  make clean    - Stop containers and remove volumes"

up:
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 10
	@echo ""
	@echo "Secrets management started!"
	@echo "Vault UI:        http://localhost:8200 (token: root)"
	@echo "Vault UI Alt:    http://localhost:8000"
	@echo "Consul UI:       http://localhost:8500"
	@echo ""
	@echo "Run 'make init' to initialize Vault with sample secrets"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f --tail=100

ps:
	docker-compose ps

init:
	./scripts/init_vault.sh

test:
	@echo "Testing Vault..."
	@export VAULT_ADDR='http://localhost:8200' && \
	export VAULT_TOKEN='root' && \
	vault status
	@echo ""
	@echo "Testing secret operations..."
	@export VAULT_ADDR='http://localhost:8200' && \
	export VAULT_TOKEN='root' && \
	vault kv put secret/test key=value && \
	vault kv get secret/test && \
	vault kv delete secret/test
	@echo ""
	@echo "Vault test completed!"

clean:
	@echo "WARNING: This will remove all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "All containers and volumes removed."; \
	fi
