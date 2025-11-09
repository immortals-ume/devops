.PHONY: help up down restart logs ps backup restore clean setup-mysql-replication setup-mariadb-replication test-postgres test-mysql test-mariadb test-mssql test-oracle

help:
	@echo "SQL Databases - Local Setup"
	@echo ""
	@echo "Available commands:"
	@echo "  make up                        - Start all database containers"
	@echo "  make down                      - Stop all database containers"
	@echo "  make restart                   - Restart all database containers"
	@echo "  make logs                      - View logs from all containers"
	@echo "  make ps                        - Show container status"
	@echo "  make backup                    - Backup all databases"
	@echo "  make setup-mysql-replication   - Setup MySQL replication"
	@echo "  make setup-mariadb-replication - Setup MariaDB replication"
	@echo "  make test-postgres             - Test PostgreSQL replication"
	@echo "  make test-mysql                - Test MySQL replication"
	@echo "  make test-mariadb              - Test MariaDB replication"
	@echo "  make test-mssql                - Test SQL Server"
	@echo "  make test-oracle               - Test Oracle Database"
	@echo "  make clean                     - Stop containers and remove volumes"

up:
	docker-compose up -d
	@echo "Waiting for containers to be healthy..."
	@sleep 15
	@echo "Databases are starting up."
	@echo "Run 'make setup-mysql-replication' and 'make setup-mariadb-replication' to configure replication."

down:
	docker-compose down

restart:
	docker-compose restart

logs:
	docker-compose logs -f --tail=100

ps:
	docker-compose ps

backup:
	./backup.sh

setup-mysql-replication:
	./setup_mysql_replication.sh

setup-mariadb-replication:
	./setup_mariadb_replication.sh

test-postgres:
	@echo "Testing PostgreSQL replication..."
	@echo "Creating test table on primary..."
	docker exec postgres_primary psql -U root -d myapp -c "DROP TABLE IF EXISTS replication_test;"
	docker exec postgres_primary psql -U root -d myapp -c "CREATE TABLE replication_test (id SERIAL PRIMARY KEY, data TEXT, created_at TIMESTAMP DEFAULT NOW());"
	docker exec postgres_primary psql -U root -d myapp -c "INSERT INTO replication_test (data) VALUES ('Test from primary at $(shell date)');"
	@echo "Waiting for replication..."
	@sleep 2
	@echo "Checking replica..."
	docker exec postgres_replica psql -U root -d myapp -c "SELECT * FROM replication_test;"
	@echo "PostgreSQL replication test completed!"

test-mysql:
	@echo "Testing MySQL replication..."
	@echo "Creating test table on primary..."
	docker exec mysql_primary mysql -u root -proot -e "USE myapp; DROP TABLE IF EXISTS replication_test;"
	docker exec mysql_primary mysql -u root -proot -e "USE myapp; CREATE TABLE replication_test (id INT AUTO_INCREMENT PRIMARY KEY, data VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
	docker exec mysql_primary mysql -u root -proot -e "USE myapp; INSERT INTO replication_test (data) VALUES ('Test from primary at $(shell date)');"
	@echo "Waiting for replication..."
	@sleep 2
	@echo "Checking replica..."
	docker exec mysql_replica mysql -u root -proot -e "USE myapp; SELECT * FROM replication_test;"
	@echo "MySQL replication test completed!"

test-mariadb:
	@echo "Testing MariaDB replication..."
	@echo "Creating test table on primary..."
	docker exec mariadb_primary mariadb -u root -proot -e "USE myapp; DROP TABLE IF EXISTS replication_test;"
	docker exec mariadb_primary mariadb -u root -proot -e "USE myapp; CREATE TABLE replication_test (id INT AUTO_INCREMENT PRIMARY KEY, data VARCHAR(255), created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);"
	docker exec mariadb_primary mariadb -u root -proot -e "USE myapp; INSERT INTO replication_test (data) VALUES ('Test from primary at $(shell date)');"
	@echo "Waiting for replication..."
	@sleep 2
	@echo "Checking replica..."
	docker exec mariadb_replica mariadb -u root -proot -e "USE myapp; SELECT * FROM replication_test;"
	@echo "MariaDB replication test completed!"

test-mssql:
	@echo "Testing SQL Server..."
	docker exec mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -Q "SELECT name FROM sys.databases;"
	docker exec mssql_server /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'YourStrong@Passw0rd' -d myapp -Q "SELECT * FROM users;"
	@echo "SQL Server test completed!"

test-oracle:
	@echo "Testing Oracle Database..."
	docker exec oracle_xe sqlplus -S myapp/myapp@localhost:1521/MYAPP <<< "SELECT * FROM users;"
	@echo "Oracle Database test completed!"

clean:
	@echo "WARNING: This will remove all data!"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker-compose down -v; \
		echo "All containers and volumes removed."; \
	fi
