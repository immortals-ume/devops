.PHONY: help up down restart logs ps setup-mongo test-mongo test-cassandra test-couchdb clean

help:
	@echo "NoSQL Databases - Local Setup"
	@echo ""
	@echo "Available commands:"
	@echo "  make up              - Start all NoSQL databases"
	@echo "  make down            - Stop all NoSQL databases"
	@echo "  make restart         - Restart all NoSQL databases"
	@echo "  make logs            - View logs from all containers"
	@echo "  make ps              - Show container status"
	@echo "  make setup-mongo     - Setup MongoDB replica set"
	@echo "  make test-mongo      - Test MongoDB replication"
	@echo "  make test-cassandra  - Test Cassandra cluster"
	@echo "  make test-couchdb    - Test CouchDB"
	@echo "  make clean           - Stop containers and remove volumes"

up:
	docker-compose up -d
	@echo "Waiting for containers to be healthy..."
	@sleep 15
	@echo "Run 'make setup-mongo' to configure MongoDB replica set"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f --tail=100

ps:
	docker-compose ps

setup-mongo:
	./setup_mongo_replicaset.sh

test-mongo:
	@echo "Testing MongoDB replication..."
	docker exec mongo_primary mongosh --eval 'db.getSiblingDB("myapp").test.insertOne({message: "Test at $(shell date)", timestamp: new Date()})'
	@sleep 2
	docker exec mongo_secondary1 mongosh --eval 'db.getSiblingDB("myapp").setSecondaryOk(); db.getSiblingDB("myapp").test.find().pretty()'
	@echo "MongoDB replication test completed!"

test-cassandra:
	@echo "Testing Cassandra cluster..."
	docker exec cassandra_node1 nodetool status
	@echo "Cassandra cluster test completed!"

test-couchdb:
	@echo "Testing CouchDB..."
	curl -s http://admin:admin@localhost:5984/_up
	@echo ""
	@echo "CouchDB test completed!"

clean:
	@echo "WARNING: This will remove all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "All containers and volumes removed."; \
	fi
