.PHONY: help up down restart logs ps setup-cluster test-standalone test-cluster test-sentinel clean

help:
	@echo "Redis Cache - Local Setup"
	@echo ""
	@echo "Available commands:"
	@echo "  make up              - Start all Redis services"
	@echo "  make down            - Stop all Redis services"
	@echo "  make restart         - Restart all Redis services"
	@echo "  make logs            - View logs from all containers"
	@echo "  make ps              - Show container status"
	@echo "  make setup-cluster   - Setup Redis cluster"
	@echo "  make test-standalone - Test standalone Redis"
	@echo "  make test-cluster    - Test Redis cluster"
	@echo "  make test-sentinel   - Test Redis sentinel"
	@echo "  make clean           - Stop containers and remove volumes"

up:
	docker-compose up -d
	@echo "Waiting for Redis services to be ready..."
	@sleep 10
	@echo "Redis services started!"
	@echo "Run 'make setup-cluster' to initialize the Redis cluster"
	@echo "Redis Commander UI: http://localhost:8081"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f --tail=100

ps:
	docker-compose ps

setup-cluster:
	./setup_cluster.sh

test-standalone:
	@echo "Testing Redis Standalone..."
	docker exec redis_standalone redis-cli set test_key "Hello from standalone"
	docker exec redis_standalone redis-cli get test_key
	docker exec redis_standalone redis-cli info replication
	@echo "Standalone test completed!"

test-cluster:
	@echo "Testing Redis Cluster..."
	docker exec redis_cluster_1 redis-cli -c -p 7000 set cluster_key1 "Hello from cluster"
	docker exec redis_cluster_1 redis-cli -c -p 7000 set cluster_key2 "Distributed data"
	docker exec redis_cluster_1 redis-cli -c -p 7000 get cluster_key1
	docker exec redis_cluster_1 redis-cli -p 7000 cluster info
	docker exec redis_cluster_1 redis-cli -p 7000 cluster nodes
	@echo "Cluster test completed!"

test-sentinel:
	@echo "Testing Redis Sentinel..."
	docker exec sentinel1 redis-cli -p 26379 sentinel masters
	docker exec sentinel1 redis-cli -p 26379 sentinel get-master-addr-by-name mymaster
	docker exec redis_sentinel_master redis-cli set sentinel_key "Hello from sentinel"
	docker exec redis_sentinel_replica1 redis-cli get sentinel_key
	@echo "Sentinel test completed!"

clean:
	@echo "WARNING: This will remove all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "All containers and volumes removed."; \
	fi
