#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Build and push CuliShop Docker images to ECR
# Usage:
#   ./build-push-ecr.sh --registry <ECR_REGISTRY> --source <CULISHOP_PATH>
#   ./build-push-ecr.sh --registry <ECR_REGISTRY> --source <CULISHOP_PATH> --service apiservice
# ============================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFRA_ROOT="$(dirname "$SCRIPT_DIR")"

# Default values
REGION="ap-southeast-1"
SOURCE_PATH="/home/culiops/projects/culishop"
SERVICE=""
REGISTRY=""

usage() {
  echo "Usage: $0 --registry <ECR_REGISTRY> [--source <PATH>] [--service <NAME>] [--region <REGION>]"
  echo ""
  echo "Options:"
  echo "  --registry  ECR registry URL (required)"
  echo "  --source    Path to CuliShop source (default: /home/culiops/projects/culishop)"
  echo "  --service   Build only this service (optional)"
  echo "  --region    AWS region (default: ap-southeast-1)"
  exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --registry) REGISTRY="$2"; shift 2 ;;
    --source) SOURCE_PATH="$2"; shift 2 ;;
    --service) SERVICE="$2"; shift 2 ;;
    --region) REGION="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$REGISTRY" ]]; then
  echo "ERROR: --registry is required"
  usage
fi

if [[ ! -d "$SOURCE_PATH/src" ]]; then
  echo "ERROR: CuliShop source not found at $SOURCE_PATH/src"
  exit 1
fi

# App services to build (excludes loadgenerator, shoppingassistantservice, cartservice v1, frontend Go SSR)
SERVICES=(
  apiservice
  reactfrontend
  productcatalogservice
  cartservicev2
  checkoutservice
  currencyservice
  shippingservice
  paymentservice
  emailservice
  recommendationservice
  adservice
)

# ECR login
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region "$REGION" | \
  docker login --username AWS --password-stdin "$REGISTRY"

# Git SHA for tagging
GIT_SHA=$(cd "$SOURCE_PATH" && git rev-parse --short HEAD 2>/dev/null || echo "latest")
echo "📦 Git SHA: $GIT_SHA"

build_and_push() {
  local svc=$1
  local repo="${REGISTRY}/culishop/${svc}"

  echo ""
  echo "🔨 Building ${svc}..."

  if [[ "$svc" == "mysql" ]]; then
    # Custom MySQL image with baked-in schema/seed
    docker build -t "${repo}:latest" -t "${repo}:${GIT_SHA}" \
      -f "${INFRA_ROOT}/docker/mysql/Dockerfile" "$SOURCE_PATH"
  elif [[ "$svc" == "reactfrontend" ]]; then
    # React frontend: VITE_API_URL controls where the browser sends API requests.
    # When behind an ALB with path-based routing (/api/* -> apiservice),
    # leave it empty so the browser uses relative URLs (same origin).
    # Override: set VITE_API_URL env var before running this script
    #   e.g. VITE_API_URL=http://localhost:8090 for local dev
    docker build -t "${repo}:latest" -t "${repo}:${GIT_SHA}" \
      ${VITE_API_URL:+--build-arg VITE_API_URL="${VITE_API_URL}"} \
      "$SOURCE_PATH/src/$svc"
  else
    docker build -t "${repo}:latest" -t "${repo}:${GIT_SHA}" \
      "$SOURCE_PATH/src/$svc"
  fi

  echo "📤 Pushing ${svc}..."
  docker push "${repo}:latest"
  docker push "${repo}:${GIT_SHA}"
  echo "✅ ${svc} pushed to ${repo}"
}

if [[ -n "$SERVICE" ]]; then
  # Single service build
  build_and_push "$SERVICE"
else
  # Build MySQL first (data dependency)
  build_and_push "mysql"

  # Build all app services
  for svc in "${SERVICES[@]}"; do
    build_and_push "$svc"
  done
fi

echo ""
echo "============================================"
echo "✅ All images pushed to ${REGISTRY}"
echo "   Tagged: latest + ${GIT_SHA}"
echo "============================================"
echo ""
echo "Note: Redis uses official redis:7-alpine image directly (no custom build needed)"
