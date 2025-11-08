.PHONY: help up down restart logs ps test-prometheus test-loki test-tempo clean

help:
	@echo "Observability Stack - Local Setup"
	@echo ""
	@echo "Available commands:"
	@echo "  make up              - Start all observability services"
	@echo "  make down            - Stop all observability services"
	@echo "  make restart         - Restart all observability services"
	@echo "  make logs            - View logs from all containers"
	@echo "  make ps              - Show container status"
	@echo "  make test-prometheus - Test Prometheus metrics"
	@echo "  make test-loki       - Test Loki logs"
	@echo "  make test-tempo      - Test Tempo traces"
	@echo "  make clean           - Stop containers and remove volumes"

up:
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 15
	@echo ""
	@echo "Observability stack started!"
	@echo "Grafana:      http://localhost:3000 (admin/admin)"
	@echo "Prometheus:   http://localhost:9090"
	@echo "Alertmanager: http://localhost:9093"
	@echo "Jaeger:       http://localhost:16686"
	@echo "cAdvisor:     http://localhost:8080"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f --tail=100

ps:
	docker-compose ps

test-prometheus:
	@echo "Testing Prometheus..."
	@echo "Checking health:"
	curl -s http://localhost:9090/-/healthy
	@echo ""
	@echo "Checking targets:"
	curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | {job: .labels.job, health: .health}'
	@echo ""
	@echo "Sample query (CPU usage):"
	curl -s 'http://localhost:9090/api/v1/query?query=100-(avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))*100)' | jq '.data.result'
	@echo "Prometheus test completed!"

test-loki:
	@echo "Testing Loki..."
	@echo "Checking health:"
	curl -s http://localhost:3100/ready
	@echo ""
	@echo "Sending test log:"
	curl -X POST http://localhost:3100/loki/api/v1/push \
		-H 'Content-Type: application/json' \
		-d '{"streams":[{"stream":{"job":"test","level":"info"},"values":[["'$$(date +%s)000000000'","Test log message from Makefile"]]}]}'
	@echo ""
	@echo "Querying logs:"
	curl -s 'http://localhost:3100/loki/api/v1/query?query={job="test"}' | jq '.data.result'
	@echo "Loki test completed!"

test-tempo:
	@echo "Testing Tempo..."
	@echo "Checking health:"
	curl -s http://localhost:3200/ready
	@echo ""
	@echo "Sending test trace via Zipkin:"
	curl -X POST http://localhost:9411/api/v2/spans \
		-H 'Content-Type: application/json' \
		-d '[{"traceId":"'$$(openssl rand -hex 16)'","id":"'$$(openssl rand -hex 8)'","name":"test-span","timestamp":'$$(date +%s)000000',"duration":100000,"localEndpoint":{"serviceName":"test-service"}}]'
	@echo ""
	@echo "Tempo test completed! View traces at http://localhost:16686"

clean:
	@echo "WARNING: This will remove all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "All containers and volumes removed."; \
	fi
