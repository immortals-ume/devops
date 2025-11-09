.PHONY: help up down restart logs ps test-kafka test-rabbitmq test-activemq create-topic clean

help:
	@echo "Message Queue Systems - Local Setup"
	@echo ""
	@echo "Available commands:"
	@echo "  make up              - Start all message brokers"
	@echo "  make down            - Stop all message brokers"
	@echo "  make restart         - Restart all message brokers"
	@echo "  make logs            - View logs from all containers"
	@echo "  make ps              - Show container status"
	@echo "  make test-kafka      - Test Kafka cluster"
	@echo "  make test-rabbitmq   - Test RabbitMQ"
	@echo "  make test-activemq   - Test ActiveMQ"
	@echo "  make create-topic    - Create test Kafka topic"
	@echo "  make clean           - Stop containers and remove volumes"

up:
	docker-compose up -d
	@echo "Waiting for services to be ready..."
	@sleep 20
	@echo ""
	@echo "Message brokers started!"
	@echo "Kafdrop (Kafka):      http://localhost:9000"
	@echo "RabbitMQ Management:  http://localhost:15672 (admin/admin)"
	@echo "ActiveMQ Console:     http://localhost:8161 (admin/admin)"

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f --tail=100

ps:
	docker-compose ps

test-kafka:
	@echo "Testing Kafka cluster..."
	@echo "Listing brokers:"
	docker exec kafka1 kafka-broker-api-versions --bootstrap-server localhost:9092 | head -5
	@echo ""
	@echo "Listing topics:"
	docker exec kafka1 kafka-topics --list --bootstrap-server localhost:9092
	@echo ""
	@echo "Kafka cluster test completed!"

test-rabbitmq:
	@echo "Testing RabbitMQ..."
	@echo "Checking status:"
	docker exec rabbitmq rabbitmqctl status | grep -A 5 "Status of node"
	@echo ""
	@echo "Listing queues:"
	docker exec rabbitmq rabbitmqctl list_queues
	@echo ""
	@echo "RabbitMQ test completed!"

test-activemq:
	@echo "Testing ActiveMQ..."
	@echo "Checking web console:"
	curl -s -u admin:admin http://localhost:8161/api/jolokia/read/org.apache.activemq:type=Broker,brokerName=localhost | jq '.value.BrokerName'
	@echo ""
	@echo "ActiveMQ test completed!"

create-topic:
	@echo "Creating test Kafka topic..."
	docker exec kafka1 kafka-topics --create \
		--bootstrap-server localhost:9092 \
		--topic test-topic \
		--partitions 3 \
		--replication-factor 2
	@echo "Topic created! Describing topic:"
	docker exec kafka1 kafka-topics --describe \
		--bootstrap-server localhost:9092 \
		--topic test-topic

clean:
	@echo "WARNING: This will remove all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "All containers and volumes removed."; \
	fi
