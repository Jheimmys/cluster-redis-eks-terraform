#!/bin/bash
echo "=== Redis Cluster Pre-Check ==="

REDIS_PASSWORD="$1"  # Receives the password as a parameter

PODS=$(kubectl get pods -n redis -l app=redis-cluster -o jsonpath='{.items[*].metadata.name}')

for POD in $PODS; do
  echo "Verificando $POD..."
  
  # Check if the pod is responding to the Redis PING command
  kubectl exec -n redis $POD -- bash -c "REDISCLI_AUTH=$REDIS_PASSWORD redis-cli ping | grep -q PONG" || exit 1
  
  # Get Redis cluster information
  CLUSTER_INFO=$(kubectl exec -n redis $POD -- bash -c "REDISCLI_AUTH=$REDIS_PASSWORD redis-cli cluster info")
  
  # Check if the cluster is in ok state
  echo "$CLUSTER_INFO" | grep -q "cluster_state:ok" || exit 1
  
  # Checks if all 16,384 slots in Redis Cluster are allocated
  echo "$CLUSTER_INFO" | grep -q "cluster_slots_assigned:16384" || exit 1
done

echo "Pre-check completed successfully!"