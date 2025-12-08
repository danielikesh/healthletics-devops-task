#!/usr/bin/env bash
set -euo pipefail

#####################################
# CONFIG (change only if needed)
#####################################
RELEASE_NAME="healthletic-app"
CHART_PATH="./helm/myapp"
NAMESPACE="default"

# Docker Hub image repo
IMAGE_REPO="xenin007/healthletics-devops"

# K8s Service name (from service.yaml)
SERVICE_NAME="healthletic-app"
SERVICE_PORT=8080
#####################################


usage() {
  echo "Usage: $0 <image-tag>"
  echo "Example: $0 0.1.0"
  exit 1
}

if [ $# -ne 1 ]; then
  echo "Error: image tag is required."
  usage
fi

IMAGE_TAG="$1"

echo "======================================="
echo "Deploying ${RELEASE_NAME}"
echo "  Namespace : ${NAMESPACE}"
echo "  Chart     : ${CHART_PATH}"
echo "  Image     : ${IMAGE_REPO}:${IMAGE_TAG}"
echo "======================================="

echo
echo ">> Running helm lint..."
helm lint "${CHART_PATH}"

echo
echo ">> Deploying with helm upgrade --install..."
helm upgrade --install "${RELEASE_NAME}" "${CHART_PATH}" \
  --namespace "${NAMESPACE}" \
  --create-namespace \
  --set image.repository="${IMAGE_REPO}" \
  --set image.tag="${IMAGE_TAG}" \
  --wait --timeout 300s

echo
echo ">> Pods after deployment:"
kubectl get pods -n "${NAMESPACE}"

echo
echo ">> Running in-cluster smoke test on /health ..."

set +e
HTTP_CODE=$(
  kubectl run curl-test --rm -i --tty \
    --image=curlimages/curl \
    --restart=Never \
    -n "${NAMESPACE}" -- \
    curl -s -o /dev/null -w "%{http_code}" "http://${SERVICE_NAME}:${SERVICE_PORT}/health" \
  | tr -dc '0-9'
)
RESULT=$?
set -e

echo
if [ "$RESULT" -eq 0 ] && [ "$HTTP_CODE" -eq 200 ]; then
  echo "✅ Smoke test passed (HTTP 200). Deployment looks good."
  exit 0
else
  echo "❌ Smoke test failed."
  echo "    HTTP_CODE = ${HTTP_CODE}"
  echo
  echo "You can rollback with:"
  echo "  helm rollback ${RELEASE_NAME} 1 --namespace ${NAMESPACE}"
  exit 1
fi