.PHONY: help up down restart logs ps test scan clean

help:
	@echo "SonarQube - Code Quality Analysis"
	@echo ""
	@echo "Available commands:"
	@echo "  make up       - Start SonarQube and PostgreSQL"
	@echo "  make down     - Stop all services"
	@echo "  make restart  - Restart all services"
	@echo "  make logs     - View logs from all containers"
	@echo "  make ps       - Show container status"
	@echo "  make test     - Test SonarQube connectivity"
	@echo "  make scan     - Run scanner on sample project"
	@echo "  make clean    - Stop containers and remove volumes"

up:
	docker-compose up -d
	@echo "Starting SonarQube..."
	@echo "This may take 2-3 minutes..."
	@echo ""
	@echo "Waiting for SonarQube to be ready..."
	@sleep 10
	@echo "SonarQube is starting up!"
	@echo ""
	@echo "SonarQube UI: http://localhost:9000"
	@echo "Default credentials: admin/admin"
	@echo ""
	@echo "Run 'make logs' to monitor startup progress"
	@echo "Look for 'SonarQube is operational' message"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f --tail=100

ps:
	docker-compose ps

test:
	@echo "Testing SonarQube..."
	@echo "Checking system health:"
	curl -s http://localhost:9000/api/system/health | jq '.'
	@echo ""
	@echo "Checking system status:"
	curl -s http://localhost:9000/api/system/status | jq '.'
	@echo ""
	@echo "SonarQube test completed!"

scan:
	@echo "To scan a project, place it in ./projects/ directory"
	@echo "Then run:"
	@echo "  docker-compose run --rm sonar_scanner -Dproject.settings=/usr/src/yourproject/sonar-project.properties"

clean:
	@echo "WARNING: This will remove all data including analysis history!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "All containers and volumes removed."; \
	fi
