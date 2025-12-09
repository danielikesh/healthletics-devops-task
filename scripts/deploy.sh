#!/usr/bin/env bash

# Stop on errors
set -e

# ---- CONFIG ----
CHART_PATH="./helm/myapp"
RELEASE_NAME="healthletic-app"
NAMESPACE="default"

# ---- HELP TEXT ----
usage() {
  echo "Usage: $0 --env <env> --version <x.y.z> --image-registry <repo> [--namespace <ns>]"
  echo
  echo "Example:"
  echo "  $0 --env dev --version 1.0.3 --image-registry xenin007/healthletics-devops --namespace default"
  exit 1
}

ENVIRONMENT=""
APP_VERSION=""
IMAGE_REGISTRY=""

# ---- ARG PARSING (simple) ----
while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENVIRONMENT="$2"
      shift 2
      ;;
    --version)
      APP_VERSION="$2"
      shift 2
      ;;
    --image-registry)
      IMAGE_REGISTRY="$2"
      shift 2
      ;;
    --namespace)
      NAMESPACE="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# ---- BASIC VALIDATION ----
if [[ -z "$ENVIRONMENT" || -z "$APP_VERSION" || -z "$IMAGE_REGISTRY" ]]; then
  echo "ERROR: --env, --version and --image-registry are required."
  usage
fi

# Just a simple semantic version check
if ! [[ "$APP_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: version must look like 1.0.0, got: $APP_VERSION"
  exit 1
fi

echo "Environment : $ENVIRONMENT"
echo "Namespace   : $NAMESPACE"
echo "Version     : $APP_VERSION"
echo "Image       : ${IMAGE_REGISTRY}:${APP_VERSION}"
echo "Release     : $RELEASE_NAME"
echo "Chart path  : $CHART_PATH"
echo

# ---- NAMESPACE ENSURE ----
echo "[1/4] Making sure namespace exists..."
kubectl get namespace "$NAMESPACE" >/dev/null 2>&1 || kubectl create namespace "$NAMESPACE"

# ---- HELM LINT ----
echo "[2/4] Helm lint..."
helm lint "$CHART_PATH"

# ---- DEPLOY ----
echo "[3/4] Deploying with Helm (upgrade --install)..."
helm upgrade "$RELEASE_NAME" "$CHART_PATH" \
  --install \
  --namespace "$NAMESPACE" \
  --set image.repository="$IMAGE_REGISTRY" \
  --set image.tag="$APP_VERSION" \
  --wait --timeout 300s

# ---- POST CHECKS ----
echo "[4/4] Checking pods and services..."
kubectl get pods -n "$NAMESPACE"
kubectl get svc -n "$NAMESPACE"

echo
echo "Deployment finished successfully 🎯"
echo "If something goes wrong, you can rollback with:"
echo "  helm rollback $RELEASE_NAME -n $NAMESPACE"
