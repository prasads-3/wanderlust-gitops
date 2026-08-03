#!/bin/bash

set -e

NAMESPACE="monitoring"
RELEASE_NAME="monitoring"
CHART="prometheus-community/kube-prometheus-stack"
VALUES_FILE="../helm-values/kube-prometheus-stack-values.yaml"

echo "=============================================="
echo "      Monitoring Stack Installation"
echo "=============================================="

echo "[1/5] Checking Namespace..."

if kubectl get namespace ${NAMESPACE} >/dev/null 2>&1; then
    echo "Namespace '${NAMESPACE}' already exists."
else
    echo "Creating Namespace '${NAMESPACE}'..."
    kubectl create namespace ${NAMESPACE}
fi

echo
echo "[2/5] Updating Helm Repository..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts 2>/dev/null || true
helm repo update

echo
echo "[3/5] Installing / Upgrading Monitoring Stack..."

helm upgrade --install ${RELEASE_NAME} ${CHART} \
    --namespace ${NAMESPACE} \
    --values ${VALUES_FILE}

echo
echo "[4/5] Waiting for Pods..."

kubectl wait --for=condition=Ready pod \
    --all \
    -n ${NAMESPACE} \
    --timeout=600s

echo
echo "[5/5] Monitoring Stack Installed Successfully."

echo
echo "=============================================="
echo "Installed Components"
echo "=============================================="

kubectl get pods -n ${NAMESPACE}

echo
echo "=============================================="
echo "Next Step"
echo "=============================================="
echo "Run:"
echo "kubectl get svc -n monitoring"
