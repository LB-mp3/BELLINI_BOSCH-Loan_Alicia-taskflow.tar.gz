#!/bin/bash
set -e

echo "=== TaskFlow communication tests ==="

FRONT_NS="taskflow-frontend"
BACK_NS="taskflow-backend"

echo ""
echo "→ Getting API Gateway pod..."
GATEWAY_POD=$(kubectl get pod -n $FRONT_NS -l app=api-gateway -o jsonpath="{.items[0].metadata.name}")

echo "API Gateway pod: $GATEWAY_POD"
echo ""

echo "=== Testing API Gateway routes ==="

echo "- /health"
kubectl exec -n $FRONT_NS $GATEWAY_POD -- curl -s http://localhost/health

echo ""
echo "- /auth"
kubectl exec -n $FRONT_NS $GATEWAY_POD -- curl -s http://localhost/auth

echo ""
echo "- /tasks"
kubectl exec -n $FRONT_NS $GATEWAY_POD -- curl -s http://localhost/tasks

echo ""
echo "- /notifications"
kubectl exec -n $FRONT_NS $GATEWAY_POD -- curl -s http://localhost/notifications

echo ""
echo "- /metrics"
kubectl exec -n $FRONT_NS $GATEWAY_POD -- curl -s http://localhost/metrics

echo ""
echo "=== Testing backend services directly ==="

echo "→ Auth service"
kubectl run test-auth --rm -i --restart=Never \
  --image=curlimages/curl \
  -n $BACK_NS -- curl -s http://auth-svc:5000

echo ""
echo "→ Tasks service"
kubectl run test-tasks --rm -i --restart=Never \
  --image=curlimages/curl \
  -n $BACK_NS -- curl -s http://tasks-svc:8081

echo ""
echo "→ Notifications service"
kubectl run test-notifications --rm -i --restart=Never \
  --image=curlimages/curl \
  -n $BACK_NS -- curl -s http://notifications-svc:3001

echo ""
echo "→ Metrics service"
kubectl run test-metrics --rm -i --restart=Never \
  --image=curlimages/curl \
  -n $BACK_NS -- curl -s http://metrics-svc:5001

echo ""
echo "=== All communication tests passed successfully ✅ ==="
