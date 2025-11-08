# Observability Stack - Local Setup

Complete observability solution with metrics, logs, and traces for monitoring and debugging applications.

## Stack Components

### Metrics
- **Prometheus** (port 9090) - Time-series metrics collection and storage
- **Alertmanager** (port 9093) - Alert management and routing
- **Node Exporter** (port 9100) - System/hardware metrics
- **cAdvisor** (port 8080) - Container metrics

### Logs
- **Loki** (port 3100) - Log aggregation system
- **Promtail** - Log shipper for Loki

### Traces
- **Tempo** (ports 3200, 4317, 4318, 9411, 14268) - Distributed tracing backend
- **Jaeger** (port 16686) - Tracing UI and collector

### Visualization
- **Grafana** (port 3000) - Unified dashboards for metrics, logs, and traces

## Quick Start

### 1. Start All Services

```bash
docker-compose up -d
```

### 2. Access UIs

- **Grafana**: http://localhost:3000 (admin/admin)
- **Prometheus**: http://localhost:9090
- **Alertmanager**: http://localhost:9093
- **Jaeger**: http://localhost:16686
- **cAdvisor**: http://localhost:8080

### 3. Verify Services

```bash
# Check all services
docker-compose ps

# Check Prometheus targets
curl http://localhost:9090/api/v1/targets

# Check Loki health
curl http://localhost:3100/ready

# Check Tempo health
curl http://localhost:3200/ready
```

## Usage Examples

### Metrics with Prometheus

**Query CPU usage:**
```promql
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
```

**Query memory usage:**
```promql
(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
```

**Query container metrics:**
```promql
rate(container_cpu_usage_seconds_total{name!=""}[5m]) * 100
```

### Logs with Loki

**Query logs in Grafana:**
```logql
{job="docker"} |= "error"
```

**Filter by container:**
```logql
{container="redis_standalone"} | json | line_format "{{.message}}"
```

**Count errors:**
```logql
sum(count_over_time({job="docker"} |= "error" [5m]))
```

### Traces with Tempo

**Send trace via OTLP (Python example):**
```python
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor

# Setup
trace.set_tracer_provider(TracerProvider())
otlp_exporter = OTLPSpanExporter(endpoint="http://localhost:4317", insecure=True)
span_processor = BatchSpanProcessor(otlp_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

# Create trace
tracer = trace.get_tracer(__name__)
with tracer.start_as_current_span("my-operation"):
    print("Doing work...")
```

**Send trace via Zipkin:**
```bash
curl -X POST http://localhost:9411/api/v2/spans \
  -H 'Content-Type: application/json' \
  -d '[{
    "traceId": "1234567890abcdef",
    "id": "1234567890abcdef",
    "name": "test-span",
    "timestamp": 1234567890000000,
    "duration": 100000,
    "localEndpoint": {
      "serviceName": "test-service"
    }
  }]'
```

## Grafana Dashboards

### Pre-configured Datasources
- Prometheus (metrics)
- Loki (logs)
- Tempo (traces)
- Jaeger (traces)

### Recommended Dashboards

Import these dashboard IDs in Grafana:

**System Monitoring:**
- Node Exporter Full: 1860
- Docker Container & Host Metrics: 179
- cAdvisor: 14282

**Application Monitoring:**
- Loki Dashboard: 13639
- Tempo Dashboard: 16700
- Prometheus Stats: 2

**Database Monitoring:**
- PostgreSQL: 9628
- MySQL: 7362
- Redis: 11835

### Creating Custom Dashboards

1. Go to Grafana → Dashboards → New Dashboard
2. Add Panel
3. Select datasource (Prometheus/Loki/Tempo)
4. Write query
5. Configure visualization
6. Save dashboard

## Alerting

### Configure Alerts in Prometheus

Edit `prometheus/alerts.yml` to add custom alerts:

```yaml
- alert: MyCustomAlert
  expr: my_metric > 100
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "Custom alert triggered"
    description: "Metric exceeded threshold"
```

### Configure Alert Routing

Edit `alertmanager/alertmanager.yml`:

```yaml
receivers:
  - name: 'slack'
    slack_configs:
      - api_url: 'YOUR_WEBHOOK_URL'
        channel: '#alerts'
```

### Test Alerts

```bash
# Trigger test alert
curl -X POST http://localhost:9093/api/v1/alerts \
  -H 'Content-Type: application/json' \
  -d '[{
    "labels": {
      "alertname": "TestAlert",
      "severity": "warning"
    },
    "annotations": {
      "summary": "Test alert"
    }
  }]'
```

## Monitoring Your Applications

### Instrument Application (Python)

```python
from prometheus_client import Counter, Histogram, start_http_server
import time

# Metrics
REQUEST_COUNT = Counter('app_requests_total', 'Total requests')
REQUEST_DURATION = Histogram('app_request_duration_seconds', 'Request duration')

# Start metrics server
start_http_server(8000)

# Use metrics
@REQUEST_DURATION.time()
def process_request():
    REQUEST_COUNT.inc()
    time.sleep(0.1)
```

### Instrument Application (Node.js)

```javascript
const client = require('prom-client');
const express = require('express');

const app = express();
const register = new client.Registry();

// Metrics
const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

// Expose metrics
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});
```

### Add Application to Prometheus

Edit `prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'my-app'
    static_configs:
      - targets: ['my-app:8000']
        labels:
          service: 'my-application'
```

## Performance Tuning

### Prometheus
- Adjust `storage.tsdb.retention.time` for data retention
- Increase `scrape_interval` to reduce load
- Use recording rules for expensive queries

### Loki
- Adjust `retention_period` in loki.yml
- Increase `ingestion_rate_mb` for high-volume logs
- Use label matchers efficiently

### Tempo
- Adjust `max_block_duration` for trace retention
- Configure sampling rate for high-traffic apps
- Use tail-based sampling for important traces

## Troubleshooting

### Prometheus Not Scraping Targets

```bash
# Check targets
curl http://localhost:9090/api/v1/targets

# Check Prometheus logs
docker-compose logs prometheus

# Verify network connectivity
docker exec prometheus wget -O- http://node_exporter:9100/metrics
```

### Loki Not Receiving Logs

```bash
# Check Loki health
curl http://localhost:3100/ready

# Check Promtail logs
docker-compose logs promtail

# Test log ingestion
curl -X POST http://localhost:3100/loki/api/v1/push \
  -H 'Content-Type: application/json' \
  -d '{"streams":[{"stream":{"job":"test"},"values":[["'$(date +%s)000000000'","test log"]]}]}'
```

### Tempo Not Receiving Traces

```bash
# Check Tempo health
curl http://localhost:3200/ready

# Test OTLP endpoint
curl http://localhost:4318/v1/traces

# Check Jaeger UI
open http://localhost:16686
```

### Grafana Datasource Issues

```bash
# Check datasource connectivity
docker exec grafana wget -O- http://prometheus:9090/-/healthy
docker exec grafana wget -O- http://loki:3100/ready
docker exec grafana wget -O- http://tempo:3200/ready
```

## Data Retention

### Prometheus
- Default: 30 days
- Configure in docker-compose.yml: `--storage.tsdb.retention.time=30d`

### Loki
- Default: 31 days (744h)
- Configure in loki.yml: `retention_period: 744h`

### Tempo
- Default: 1 hour
- Configure in tempo.yml: `block_retention: 1h`

### Jaeger
- Uses badger storage (ephemeral: false)
- Data persists in volume

## Security Notes

⚠️ **For local development only!**

Production recommendations:
- Enable authentication for all services
- Use TLS/SSL for communication
- Implement RBAC in Grafana
- Secure Prometheus with basic auth
- Use secrets management for credentials
- Enable audit logging
- Regular security updates

## Integration with Applications

### Spring Boot

```yaml
management:
  endpoints:
    web:
      exposure:
        include: prometheus,health,info
  metrics:
    export:
      prometheus:
        enabled: true
```

### Django

```python
# settings.py
INSTALLED_APPS = [
    'django_prometheus',
]

MIDDLEWARE = [
    'django_prometheus.middleware.PrometheusBeforeMiddleware',
    # ... other middleware
    'django_prometheus.middleware.PrometheusAfterMiddleware',
]
```

### Express.js

```javascript
const promBundle = require('express-prom-bundle');
const metricsMiddleware = promBundle({
  includeMethod: true,
  includePath: true
});
app.use(metricsMiddleware);
```

## Cleanup

```bash
# Stop all services
docker-compose down

# Remove all data
docker-compose down -v
```

## Environment Variables

Create `.env` file:

```env
# Grafana
GF_ADMIN_USER=admin
GF_ADMIN_PASSWORD=admin

# Optional: Configure external services
# SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
# PAGERDUTY_SERVICE_KEY=your-key
```

## Useful Commands

```bash
# View all logs
docker-compose logs -f

# Restart specific service
docker-compose restart prometheus

# Check resource usage
docker stats

# Backup Grafana dashboards
docker exec grafana grafana-cli admin export-dashboard

# Reload Prometheus config
curl -X POST http://localhost:9090/-/reload
```
