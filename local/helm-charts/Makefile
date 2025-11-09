.PHONY: help lint package install uninstall test clean

CHARTS := postgres mysql mongodb redis kafka observability vault
NAMESPACE_DB := db
NAMESPACE_CACHE := cache
NAMESPACE_QUEUE := queue
NAMESPACE_OBSERVABILITY := observability
NAMESPACE_VAULT := vault

help:
	@echo "Available targets:"
	@echo "  lint              - Lint all charts"
	@echo "  package           - Package all charts"
	@echo "  install-all       - Install all charts"
	@echo "  uninstall-all     - Uninstall all charts"
	@echo "  test              - Test all charts"
	@echo "  clean             - Clean packaged charts"
	@echo ""
	@echo "Individual chart targets:"
	@echo "  install-postgres  - Install PostgreSQL"
	@echo "  install-mysql     - Install MySQL"
	@echo "  install-mongodb   - Install MongoDB"
	@echo "  install-redis     - Install Redis"
	@echo "  install-kafka     - Install Kafka"
	@echo "  install-observability - Install Observability stack"
	@echo "  install-vault     - Install Vault"

lint:
	@echo "Linting all charts..."
	@for chart in $(CHARTS); do \
		echo "Linting $$chart..."; \
		helm lint helm-charts/$$chart || exit 1; \
	done
	@echo "All charts passed linting!"

package:
	@echo "Packaging all charts..."
	@mkdir -p packages
	@for chart in $(CHARTS); do \
		echo "Packaging $$chart..."; \
		helm package helm-charts/$$chart -d packages/ || exit 1; \
	done
	@helm repo index packages/ --url https://charts.example.com
	@echo "All charts packaged!"

install-postgres:
	helm upgrade --install postgres ./helm-charts/postgres \
		--namespace $(NAMESPACE_DB) --create-namespace --wait

install-mysql:
	helm upgrade --install mysql ./helm-charts/mysql \
		--namespace $(NAMESPACE_DB) --create-namespace --wait

install-mongodb:
	helm upgrade --install mongodb ./helm-charts/mongodb \
		--namespace $(NAMESPACE_DB) --create-namespace --wait

install-redis:
	helm upgrade --install redis ./helm-charts/redis \
		--namespace $(NAMESPACE_CACHE) --create-namespace --wait

install-kafka:
	helm upgrade --install kafka ./helm-charts/kafka \
		--namespace $(NAMESPACE_QUEUE) --create-namespace --wait

install-observability:
	helm upgrade --install observability ./helm-charts/observability \
		--namespace $(NAMESPACE_OBSERVABILITY) --create-namespace --wait

install-vault:
	helm upgrade --install vault ./helm-charts/vault \
		--namespace $(NAMESPACE_VAULT) --create-namespace --wait

install-all: install-postgres install-mysql install-mongodb install-redis install-kafka install-observability install-vault
	@echo "All charts installed!"

uninstall-postgres:
	helm uninstall postgres -n $(NAMESPACE_DB) || true

uninstall-mysql:
	helm uninstall mysql -n $(NAMESPACE_DB) || true

uninstall-mongodb:
	helm uninstall mongodb -n $(NAMESPACE_DB) || true

uninstall-redis:
	helm uninstall redis -n $(NAMESPACE_CACHE) || true

uninstall-kafka:
	helm uninstall kafka -n $(NAMESPACE_QUEUE) || true

uninstall-observability:
	helm uninstall observability -n $(NAMESPACE_OBSERVABILITY) || true

uninstall-vault:
	helm uninstall vault -n $(NAMESPACE_VAULT) || true

uninstall-all: uninstall-postgres uninstall-mysql uninstall-mongodb uninstall-redis uninstall-kafka uninstall-observability uninstall-vault
	@echo "All charts uninstalled!"

test:
	@echo "Testing all charts..."
	@for chart in $(CHARTS); do \
		echo "Testing $$chart..."; \
		helm template test ./helm-charts/$$chart > /dev/null || exit 1; \
	done
	@echo "All charts passed testing!"

clean:
	@echo "Cleaning packaged charts..."
	@rm -rf packages/
	@echo "Cleaned!"

dry-run-all:
	@echo "Dry run for all charts..."
	@helm install postgres ./helm-charts/postgres -n $(NAMESPACE_DB) --dry-run --debug
	@helm install mysql ./helm-charts/mysql -n $(NAMESPACE_DB) --dry-run --debug
	@helm install mongodb ./helm-charts/mongodb -n $(NAMESPACE_DB) --dry-run --debug
	@helm install redis ./helm-charts/redis -n $(NAMESPACE_CACHE) --dry-run --debug
	@helm install kafka ./helm-charts/kafka -n $(NAMESPACE_QUEUE) --dry-run --debug
	@helm install observability ./helm-charts/observability -n $(NAMESPACE_OBSERVABILITY) --dry-run --debug
	@helm install vault ./helm-charts/vault -n $(NAMESPACE_VAULT) --dry-run --debug
