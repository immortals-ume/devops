# Message Queue Systems - Local Setup

Complete message broker setup with Kafka, RabbitMQ, and ActiveMQ for event streaming and messaging patterns.

## Message Brokers Included

### Apache Kafka 7.5.3 (3-broker cluster)
- **Broker 1**: localhost:9092
- **Broker 2**: localhost:9093
- **Broker 3**: localhost:9094
- **Kafdrop UI**: http://localhost:9000
- Distributed event streaming platform
- High throughput, fault-tolerant

### RabbitMQ 3.12
- **AMQP Port**: localhost:5672
- **Management UI**: http://localhost:15672 (admin/admin)
- Advanced Message Queuing Protocol
- Multiple messaging patterns

### ActiveMQ Classic 5.18.3
- **OpenWire**: localhost:61616
- **Web Console**: http://localhost:8161 (admin/admin)
- **AMQP**: localhost:5671
- **STOMP**: localhost:61613
- **MQTT**: localhost:1883
- JMS-compliant message broker

### Zookeeper 7.5.3
- **Port**: localhost:2181
- Coordination service for Kafka

## Quick Start

### Start All Message Brokers

```bash
docker-compose up -d
```

### Access UIs

- **Kafdrop (Kafka)**: http://localhost:9000
- **RabbitMQ Management**: http://localhost:15672 (admin/admin)
- **ActiveMQ Console**: http://localhost:8161 (admin/admin)

### Verify Services

```bash
# Check all containers
docker-compose ps

# Check Kafka cluster
docker exec kafka1 kafka-broker-api-versions --bootstrap-server localhost:9092

# Check RabbitMQ
docker exec rabbitmq rabbitmqctl status

# Check ActiveMQ
curl http://localhost:8161
```

## Usage Examples

### Kafka

**Create Topic:**
```bash
docker exec kafka1 kafka-topics --create \
  --bootstrap-server localhost:9092 \
  --topic test-topic \
  --partitions 3 \
  --replication-factor 2
```

**List Topics:**
```bash
docker exec kafka1 kafka-topics --list \
  --bootstrap-server localhost:9092
```

**Produce Messages:**
```bash
docker exec -it kafka1 kafka-console-producer \
  --bootstrap-server localhost:9092 \
  --topic test-topic
```

**Consume Messages:**
```bash
docker exec -it kafka1 kafka-console-consumer \
  --bootstrap-server localhost:9092 \
  --topic test-topic \
  --from-beginning
```

**Python Example:**
```python
from kafka import KafkaProducer, KafkaConsumer
import json

# Producer
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)
producer.send('test-topic', {'message': 'Hello Kafka'})
producer.flush()

# Consumer
consumer = KafkaConsumer(
    'test-topic',
    bootstrap_servers=['localhost:9092'],
    value_deserializer=lambda m: json.loads(m.decode('utf-8'))
)
for message in consumer:
    print(message.value)
```

### RabbitMQ

**Create Queue (CLI):**
```bash
docker exec rabbitmq rabbitmqctl add_queue test-queue
```

**Python Example:**
```python
import pika

# Connection
connection = pika.BlockingConnection(
    pika.ConnectionParameters('localhost', 5672, '/', 
    pika.PlainCredentials('admin', 'admin'))
)
channel = connection.channel()

# Declare queue
channel.queue_declare(queue='test-queue', durable=True)

# Publish message
channel.basic_publish(
    exchange='',
    routing_key='test-queue',
    body='Hello RabbitMQ'
)

# Consume message
def callback(ch, method, properties, body):
    print(f"Received: {body}")

channel.basic_consume(queue='test-queue', on_message_callback=callback, auto_ack=True)
channel.start_consuming()
```

**Node.js Example:**
```javascript
const amqp = require('amqplib');

async function sendMessage() {
  const connection = await amqp.connect('amqp://admin:admin@localhost:5672');
  const channel = await connection.createChannel();
  
  await channel.assertQueue('test-queue', { durable: true });
  channel.sendToQueue('test-queue', Buffer.from('Hello RabbitMQ'));
  
  console.log('Message sent');
  await channel.close();
  await connection.close();
}
```

### ActiveMQ

**Java Example:**
```java
import org.apache.activemq.ActiveMQConnectionFactory;
import javax.jms.*;

ConnectionFactory factory = new ActiveMQConnectionFactory("tcp://localhost:61616");
Connection connection = factory.createConnection("admin", "admin");
connection.start();

Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
Destination destination = session.createQueue("test-queue");

// Producer
MessageProducer producer = session.createProducer(destination);
TextMessage message = session.createTextMessage("Hello ActiveMQ");
producer.send(message);

// Consumer
MessageConsumer consumer = session.createConsumer(destination);
Message received = consumer.receive();
System.out.println(((TextMessage) received).getText());
```

**Python Example (STOMP):**
```python
import stomp

conn = stomp.Connection([('localhost', 61613)])
conn.connect('admin', 'admin', wait=True)

# Send message
conn.send(body='Hello ActiveMQ', destination='/queue/test-queue')

# Receive message
class MyListener(stomp.ConnectionListener):
    def on_message(self, frame):
        print(f'Received: {frame.body}')

conn.set_listener('', MyListener())
conn.subscribe(destination='/queue/test-queue', id=1, ack='auto')
```

## Monitoring

### Kafka Monitoring

**Cluster Status:**
```bash
docker exec kafka1 kafka-broker-api-versions --bootstrap-server localhost:9092
```

**Topic Details:**
```bash
docker exec kafka1 kafka-topics --describe \
  --bootstrap-server localhost:9092 \
  --topic test-topic
```

**Consumer Groups:**
```bash
docker exec kafka1 kafka-consumer-groups --list \
  --bootstrap-server localhost:9092

docker exec kafka1 kafka-consumer-groups --describe \
  --bootstrap-server localhost:9092 \
  --group my-group
```

**Using Kafdrop:**
- Open http://localhost:9000
- View topics, partitions, messages
- Monitor consumer lag
- Browse messages

### RabbitMQ Monitoring

**Management UI:**
- Open http://localhost:15672
- View queues, exchanges, connections
- Monitor message rates
- Manage users and permissions

**CLI Commands:**
```bash
# List queues
docker exec rabbitmq rabbitmqctl list_queues

# List exchanges
docker exec rabbitmq rabbitmqctl list_exchanges

# List connections
docker exec rabbitmq rabbitmqctl list_connections

# Cluster status
docker exec rabbitmq rabbitmqctl cluster_status
```

### ActiveMQ Monitoring

**Web Console:**
- Open http://localhost:8161
- View queues and topics
- Monitor connections
- Browse messages

**JMX Metrics:**
```bash
# Check queue depth
curl -u admin:admin http://localhost:8161/api/jolokia/read/org.apache.activemq:type=Broker,brokerName=localhost,destinationType=Queue,destinationName=test-queue/QueueSize
```

## Performance Tuning

### Kafka

**Broker Configuration:**
- Adjust `num.network.threads` for network I/O
- Increase `num.io.threads` for disk I/O
- Tune `log.segment.bytes` for log rolling
- Set appropriate `log.retention.hours`

**Producer Tuning:**
```python
producer = KafkaProducer(
    bootstrap_servers=['localhost:9092'],
    batch_size=16384,
    linger_ms=10,
    compression_type='snappy',
    acks='all'
)
```

**Consumer Tuning:**
```python
consumer = KafkaConsumer(
    'test-topic',
    bootstrap_servers=['localhost:9092'],
    fetch_min_bytes=1024,
    fetch_max_wait_ms=500,
    max_poll_records=500
)
```

### RabbitMQ

**Queue Configuration:**
```bash
# Set queue length limit
docker exec rabbitmq rabbitmqctl set_policy max-length \
  ".*" '{"max-length":10000}' --apply-to queues

# Set message TTL
docker exec rabbitmq rabbitmqctl set_policy ttl \
  ".*" '{"message-ttl":3600000}' --apply-to queues
```

**Prefetch Count:**
```python
channel.basic_qos(prefetch_count=10)
```

### ActiveMQ

**Memory Configuration:**
- Edit `ACTIVEMQ_OPTS` in docker-compose for JVM settings
- Configure `memoryUsage` in activemq.xml
- Set appropriate `storeUsage` limits

## Testing

### Kafka Load Test

```bash
# Producer performance test
docker exec kafka1 kafka-producer-perf-test \
  --topic test-topic \
  --num-records 100000 \
  --record-size 1000 \
  --throughput -1 \
  --producer-props bootstrap.servers=localhost:9092

# Consumer performance test
docker exec kafka1 kafka-consumer-perf-test \
  --bootstrap-server localhost:9092 \
  --topic test-topic \
  --messages 100000
```

### RabbitMQ Load Test

```bash
# Using rabbitmq-perf-test
docker run -it --rm --network queue_messaging \
  pivotalrabbitmq/perf-test:latest \
  --uri amqp://admin:admin@rabbitmq:5672 \
  --producers 10 \
  --consumers 10 \
  --rate 1000
```

### ActiveMQ Load Test

Use JMeter or custom scripts to test ActiveMQ performance.

## Troubleshooting

### Kafka Issues

**Broker Not Starting:**
```bash
# Check logs
docker-compose logs kafka1

# Verify Zookeeper
docker exec zookeeper zkCli.sh ls /brokers/ids

# Check disk space
docker exec kafka1 df -h
```

**Consumer Lag:**
```bash
# Check consumer group lag
docker exec kafka1 kafka-consumer-groups --describe \
  --bootstrap-server localhost:9092 \
  --group my-group
```

### RabbitMQ Issues

**Connection Refused:**
```bash
# Check if RabbitMQ is running
docker exec rabbitmq rabbitmqctl status

# Check logs
docker-compose logs rabbitmq

# Verify network
docker exec rabbitmq netstat -tlnp | grep 5672
```

**Memory Issues:**
```bash
# Check memory usage
docker exec rabbitmq rabbitmqctl status | grep memory

# Adjust memory watermark in rabbitmq.conf
```

### ActiveMQ Issues

**Broker Not Responding:**
```bash
# Check logs
docker-compose logs activemq

# Verify web console
curl http://localhost:8161

# Check JVM memory
docker stats activemq
```

## Message Patterns

### Kafka Patterns
- **Pub/Sub**: Multiple consumers in different groups
- **Event Sourcing**: Append-only log
- **Stream Processing**: Real-time data pipelines
- **Log Aggregation**: Centralized logging

### RabbitMQ Patterns
- **Work Queues**: Task distribution
- **Pub/Sub**: Fanout exchange
- **Routing**: Direct/topic exchanges
- **RPC**: Request/reply pattern

### ActiveMQ Patterns
- **Point-to-Point**: Queue-based messaging
- **Publish/Subscribe**: Topic-based messaging
- **Request/Reply**: Temporary queues
- **Message Groups**: Ordered processing

## Security Notes

⚠️ **For local development only!**

Production recommendations:
- Enable SSL/TLS for all connections
- Use SASL authentication for Kafka
- Implement proper ACLs
- Enable encryption at rest
- Use secrets management
- Regular security updates
- Monitor access logs

## Integration Examples

### Spring Boot with Kafka

```yaml
spring:
  kafka:
    bootstrap-servers: localhost:9092
    consumer:
      group-id: my-group
      auto-offset-reset: earliest
    producer:
      acks: all
```

### Spring Boot with RabbitMQ

```yaml
spring:
  rabbitmq:
    host: localhost
    port: 5672
    username: admin
    password: admin
```

### Spring Boot with ActiveMQ

```yaml
spring:
  activemq:
    broker-url: tcp://localhost:61616
    user: admin
    password: admin
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
# RabbitMQ
RABBITMQ_USER=admin
RABBITMQ_PASSWORD=admin

# ActiveMQ
ACTIVEMQ_USER=admin
ACTIVEMQ_PASSWORD=admin
```

## Useful Commands

```bash
# View all logs
docker-compose logs -f

# Restart specific service
docker-compose restart kafka1

# Check resource usage
docker stats

# Scale Kafka brokers (if needed)
docker-compose up -d --scale kafka=5
```
