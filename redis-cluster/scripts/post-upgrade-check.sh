#!/bin/bash
set -eo pipefail

NAMESPACE="redis"
REDIS_PASSWORD="$1"

MAX_WAIT=900
INTERVAL=10
elapsed=0

echo "Starting Redis cluster verification..."

# Function for error handling
handle_error() {
    echo "Error during verification:"
    echo "Linha: $1, Código: $2"
    exit 1
}

# LINENO - show the line where the error occurred
trap 'handle_error $LINENO $?' ERR

echo "1/3 - Checking Pod Status..."
while true; do
    # Checks if all pods are Running and Ready
    NOT_READY=$(kubectl get pods -n "$NAMESPACE" \
        -o jsonpath='{range .items[*]}{.status.phase}{":"}{.status.containerStatuses[0].ready}{"\n"}{end}' \
        | grep -v "Running:true" || true)

    if [[ -z "$NOT_READY" ]]; then
        echo "All pods are Running and Ready"
        break
    fi

    if (( elapsed >= MAX_WAIT )); then
        echo "Timeout: Pods not ready after $MAX_WAIT seconds"
        echo "Problem Pods:"
        kubectl get pods -n "$NAMESPACE" | grep -v "Running\|NAME"
        exit 1
    fi

    echo "Waiting pods... (${elapsed}s/${MAX_WAIT}s)"
    sleep $INTERVAL
    elapsed=$((elapsed + INTERVAL))
done

echo "2/3 - Checking cluster health..."
PODS=$(kubectl get pods -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}')

for POD in $PODS; do
    echo "checking pod $POD..."
    
    # Basic connectivity check
    if ! kubectl exec -n "$NAMESPACE" --request-timeout=5s "$POD" -- \
        redis-cli -a "$REDIS_PASSWORD" --no-auth-warning ping | grep -q "PONG"; then
        echo "Error: Pod $POD does not respond to ping"
        exit 1
    fi

    # Detailed cluster verification
    CLUSTER_INFO=$(kubectl exec -n "$NAMESPACE" --request-timeout=5s "$POD" -- \
        redis-cli -a "$REDIS_PASSWORD" --no-auth-warning cluster info 2>/dev/null)

    if ! (grep -q "cluster_state:ok" <<< "$CLUSTER_INFO" && \
          grep -q "cluster_slots_assigned:16384" <<< "$CLUSTER_INFO"); then
        echo "Error: Invalid cluster state on pod $POD"
        echo "Cluster Info:"
        echo "$CLUSTER_INFO"
        exit 1
    fi
done

echo "3/3 - Testing write/read operations..."
MASTER_FOUND=false
for POD in $PODS; do
    # Identifies master nodes
    ROLE=$(kubectl exec -n "$NAMESPACE" --request-timeout=5s "$POD" -- \
        redis-cli -a "$REDIS_PASSWORD" --no-auth-warning role | head -1 2>/dev/null)

    if [[ "$ROLE" == "master" ]]; then
        echo "Testing writing on master $POD..."
        
        # Writing test
        if ! kubectl exec -n "$NAMESPACE" --request-timeout=5s "$POD" -- \
            redis-cli -a "$REDIS_PASSWORD" --no-auth-warning set cicd-test-key "healthcheck" | grep -q "OK"; then
            echo "Error: Failed to write to master $POD"
            exit 1
        fi

        # Teste de leitura
        if ! kubectl exec -n "$NAMESPACE" --request-timeout=5s "$POD" -- \
            redis-cli -a "$REDIS_PASSWORD" --no-auth-warning get cicd-test-key | grep -q "healthcheck"; then
            echo "Error: Failed to read from master $POD"
            exit 1
        fi

        MASTER_FOUND=true
        break
    fi
done

if ! $MASTER_FOUND; then
    echo "Error: No master nodes found"
    exit 1
fi

# Test cleaning
echo "Cleaning test data..."
kubectl exec -n "$NAMESPACE" --request-timeout=5s "$POD" -- \
    redis-cli -a "$REDIS_PASSWORD" --no-auth-warning del cicd-test-key >/dev/null

echo "Verification completed successfully!"
exit 0