.PHONY: help up-db up-nosql up-inmemory up-cache up-queue up-observability up-vault up-sonarqube up-all down clean

help:
	@echo "Infrastructure DevOps - Quick Commands"
	@echo ""
	@echo "Local Setup Commands:"
	@echo "  make up-db            - Start SQL databases"
	@echo "  make up-nosql         - Start NoSQL databases"
	@echo "  make up-inmemory      - Start in-memory databases"
	@echo "  make up-cache         - Start Redis cache"
	@echo "  make up-queue         - Start message brokers"
	@echo "  make up-observability - Start monitoring stack"
	@echo "  make up-vault         - Start secrets management"
	@echo "  make up-sonarqube     - Start code quality analysis"
	@echo "  make up-all           - Start all local services"
	@echo "  make down             - Stop all services"
	@echo "  make clean            - Stop and remove all volumes"
	@echo ""
	@echo "For more commands, see Makefiles in local-setup subdirectories"

up-db:
	cd local-setup/db && docker-compose up -d

up-nosql:
	cd local-setup/nosql && docker-compose up -d

up-inmemory:
	cd local-setup/inmemory && docker-compose up -d

up-cache:
	cd local-setup/cache && docker-compose up -d

up-queue:
	cd local-setup/queue && docker-compose up -d

up-observability:
	cd local-setup/observability && docker-compose up -d

up-vault:
	cd local-setup/vault && docker-compose up -d

up-sonarqube:
	cd local-setup/sonarqube && docker-compose up -d

up-all: up-db up-nosql up-inmemory up-cache up-queue up-observability up-vault up-sonarqube
	@echo "All local services started!"

down:
	cd local-setup/db && docker-compose down 2>/dev/null || true
	cd local-setup/nosql && docker-compose down 2>/dev/null || true
	cd local-setup/inmemory && docker-compose down 2>/dev/null || true
	cd local-setup/cache && docker-compose down 2>/dev/null || true
	cd local-setup/queue && docker-compose down 2>/dev/null || true
	cd local-setup/observability && docker-compose down 2>/dev/null || true
	cd local-setup/vault && docker-compose down 2>/dev/null || true
	cd local-setup/sonarqube && docker-compose down 2>/dev/null || true
	@echo "All services stopped"

clean:
	cd local-setup/db && docker-compose down -v 2>/dev/null || true
	cd local-setup/nosql && docker-compose down -v 2>/dev/null || true
	cd local-setup/inmemory && docker-compose down -v 2>/dev/null || true
	cd local-setup/cache && docker-compose down -v 2>/dev/null || true
	cd local-setup/queue && docker-compose down -v 2>/dev/null || true
	cd local-setup/observability && docker-compose down -v 2>/dev/null || true
	cd local-setup/vault && docker-compose down -v 2>/dev/null || true
	cd local-setup/sonarqube && docker-compose down -v 2>/dev/null || true
	@echo "All services stopped and volumes removed"
