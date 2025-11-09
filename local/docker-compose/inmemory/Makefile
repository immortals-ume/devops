.PHONY: help up down restart logs ps test-h2 test-ignite test-hazelcast test-memcached clean

help:
	@echo "In-Memory Databases - Local Setup"
	@echo ""
	@echo "Available commands:"
	@echo "  make up                - Start all in-memory databases"
	@echo "  make down              - Stop all in-memory databases"
	@echo "  make restart           - Restart all in-memory databases"
	@echo "  make logs              - View logs from all containers"
	@echo "  make ps                - Show container status"
	@echo "  make test-h2           - Test H2 database"
	@echo "  make test-ignite       - Test Apache Ignite"
	@echo "  make test-hazelcast    - Test Hazelcast"
	@echo "  make test-memcached    - Test Memcached"
	@echo "  make clean             - Stop containers and remove volumes"

up:
	docker-compose up -d
	@echo "All in-memory databases started!"
	@echo "H2 Console: http://localhost:8082"
	@echo "Hazelcast Health: http://localhost:5701/hazelcast/health"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f --tail=100

ps:
	docker-compose ps

test-h2:
	@echo "Testing H2 Database..."
	@echo "H2 Console available at: http://localhost:8082"
	@echo "JDBC URL: jdbc:h2:tcp://localhost:9092/mem:testdb"
	@echo "User: sa, Password: (empty)"

test-ignite:
	@echo "Testing Apache Ignite..."
	docker exec ignite_inmemory /opt/ignite/bin/control.sh --state
	@echo "Ignite test completed!"

test-hazelcast:
	@echo "Testing Hazelcast..."
	curl -s http://localhost:5701/hazelcast/health/ready
	@echo ""
	@echo "Hazelcast test completed!"

test-memcached:
	@echo "Testing Memcached..."
	@echo "version" | nc localhost 11212
	@echo "stats" | nc localhost 11212 | head -5
	@echo "Memcached test completed!"

clean:
	@echo "WARNING: This will remove all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "All containers and volumes removed."; \
	fi
