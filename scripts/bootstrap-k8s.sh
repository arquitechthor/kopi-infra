#!/bin/bash
# Deploy the full Kopi Tools stack to a local Kubernetes cluster.
# Supports: minikube, kind, Docker Desktop K8s.
# Usage: ./bootstrap-k8s.sh [--delete]
set -e

NAMESPACE="kopi"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$SCRIPT_DIR/../k8s"

delete_mode=false
[[ "$1" == "--delete" ]] && delete_mode=true

if $delete_mode; then
    echo "Removing Kopi Tools from Kubernetes..."
    kubectl delete namespace $NAMESPACE --ignore-not-found
    echo "Done."
    exit 0
fi

echo "=== Kopi Tools — Kubernetes Bootstrap ==="
echo ""

# ── Prerequisites ──────────────────────────────────────────────────────────
command -v kubectl >/dev/null 2>&1 || { echo "ERROR: kubectl not found."; exit 1; }
kubectl cluster-info >/dev/null 2>&1 || { echo "ERROR: No Kubernetes cluster reachable."; exit 1; }

# ── Namespace ──────────────────────────────────────────────────────────────
kubectl apply -f "$K8S_DIR/base/namespaces/kopi-apps.yaml"

# ── Secrets ────────────────────────────────────────────────────────────────
SECRETS_FILE="$K8S_DIR/base/secrets/secrets.yaml"
SECRETS_EXAMPLE="$K8S_DIR/base/secrets/secrets.example.yaml"

if [ ! -f "$SECRETS_FILE" ]; then
    echo ""
    echo "IMPORTANT: Secrets file not found."
    echo "  Copy $SECRETS_EXAMPLE to secrets.yaml"
    echo "  Fill in real base64-encoded values, then re-run this script."
    echo "  Or use: kubectl create secret generic kopi-secrets --namespace $NAMESPACE \\"
    echo "    --from-literal=postgres-user=kopi \\"
    echo "    --from-literal=postgres-password=<password> \\"
    echo "    --from-literal=jwt-secret=<min-32-char-secret>"
    echo ""
    exit 1
fi
kubectl apply -f "$SECRETS_FILE"

# ── PostgreSQL ─────────────────────────────────────────────────────────────
echo "Deploying PostgreSQL..."
kubectl apply -f "$K8S_DIR/services/postgres/"
kubectl rollout status deployment/postgres -n $NAMESPACE --timeout=120s

# ── Auth service ───────────────────────────────────────────────────────────
echo "Deploying kopi-auth..."
kubectl apply -f "$K8S_DIR/services/kopi-auth/"
kubectl rollout status deployment/kopi-auth -n $NAMESPACE --timeout=120s

# ── Links service ──────────────────────────────────────────────────────────
echo "Deploying kopi-links..."
kubectl apply -f "$K8S_DIR/services/kopi-links/"
kubectl rollout status deployment/kopi-links -n $NAMESPACE --timeout=120s

# ── Tasks service ──────────────────────────────────────────────────────────
echo "Deploying kopi-tasks..."
kubectl apply -f "$K8S_DIR/services/kopi-tasks/"
kubectl rollout status deployment/kopi-tasks -n $NAMESPACE --timeout=120s

# ── Gateway ────────────────────────────────────────────────────────────────
echo "Deploying kopi-gateway..."
kubectl apply -f "$K8S_DIR/services/kopi-gateway/"
kubectl rollout status deployment/kopi-gateway -n $NAMESPACE --timeout=120s

# ── Ingress ────────────────────────────────────────────────────────────────
kubectl apply -f "$K8S_DIR/base/ingress/ingress.yaml"

echo ""
echo "Deployment complete!"
kubectl get services -n $NAMESPACE
echo ""
echo "Add to /etc/hosts:  127.0.0.1  kopi.local"
echo "Access: http://kopi.local  or  http://localhost:30080"
