#!/bin/bash
# Setup Redis Cluster
set -e

echo "Setting up Redis Cluster..."

# Wait for all nodes to be ready
echo "Waiting for Redis cluster nodes to be ready..."
for port in 7000 7001 7002 7003 7004 7005; do
    until docker exec redis_cluster_1 redis-cli -p $port ping > /dev/null 2>&1; do
        echo "Waiting for Redis node on port $port..."
        sleep 2
    done
done

echo "All nodes are ready. Creating cluster..."

# Create cluster
docker exec redis_cluster_1 redis-cli --cluster create \
    redis_cluster_1:7000 \
    redis_cluster_2:7001 \
    redis_cluster_3:7002 \
    redis_cluster_4:7003 \
    redis_cluster_5:7004 \
    redis_cluster_6:7005 \
    --cluster-replicas 1 \
    --cluster-yes

echo ""
echo "Redis Cluster setup complete!"
echo ""
echo "Cluster nodes:"
docker exec redis_cluster_1 redis-cli -p 7000 cluster nodes
echo ""
echo "Cluster info:"
docker exec redis_cluster_1 redis-cli -p 7000 cluster info
