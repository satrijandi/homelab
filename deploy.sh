#!/bin/bash

set -e

echo "Checking if kind cluster exists..."
if kind get clusters | grep -q "^homelab$"; then
  echo "Kind cluster 'homelab' already exists, skipping creation..."
else
  echo "Creating kind cluster..."
  kind create cluster --config kind-cluster.yaml
fi

echo "Checking if Cilium CLI is installed..."
if ! command -v cilium &> /dev/null; then
  echo "Installing Cilium CLI..."
  CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
  CLI_ARCH=amd64
  if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
  curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
  sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
  sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
  rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
else
  echo "Cilium CLI already installed, skipping..."
fi

echo "Checking if Cilium CNI is installed..."
if kubectl get daemonset -n kube-system cilium &> /dev/null; then
  echo "Cilium CNI already installed, skipping..."
else
  echo "Installing Cilium CNI..."
  cilium install --version 1.17.6
fi

echo "Waiting for Cilium to be ready..."
cilium status --wait

echo "Installing CloudNativePG operator..."
curl -s https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.26/releases/cnpg-1.26.0.yaml | \
  kubectl apply --server-side -f -

echo "Waiting for CloudNativePG operator to be ready..."
kubectl wait --namespace cnpg-system \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=cloudnative-pg \
  --timeout=180s

echo "Waiting for CRDs to be established..."
kubectl wait --for condition=established --timeout=60s crd/clusters.postgresql.cnpg.io

echo "Deploying database..."
./kustomize build k8s/database | kubectl apply -f -

echo "Waiting for PostgreSQL cluster to be ready..."
kubectl wait --namespace database \
  --for=condition=ready cluster \
  postgres-cluster \
  --timeout=300s

echo "Creating linkding namespace and credentials..."
kubectl apply -f k8s/apps/linkding/namespace.yaml
kubectl apply -f k8s/apps/linkding/postgres-app-credentials.yaml

echo "Initializing linkding database with PostgreSQL..."
kubectl apply -f k8s/apps/linkding/init-db-job.yaml

echo "Waiting for linkding database initialization to complete..."
kubectl wait --namespace linkding \
  --for=condition=complete job \
  linkding-init-db \
  --timeout=300s

echo "Deploying applications..."
kubectl delete job linkding-init-db -n linkding --ignore-not-found=true
./kustomize build k8s/apps/linkding | kubectl apply -f -
./kustomize build k8s/apps/pgadmin | kubectl apply -f -

echo "Waiting for applications to be ready..."
kubectl wait --namespace linkding \
  --for=condition=ready pod \
  --selector=app=linkding \
  --timeout=180s

kubectl wait --namespace pgadmin \
  --for=condition=ready pod \
  --selector=app=pgadmin \
  --timeout=180s

echo "Deployment complete!"
echo ""
echo "Use port-forwarding to access applications:"
echo "kubectl port-forward -n linkding svc/linkding-service 8080:80"
echo "kubectl port-forward -n pgadmin svc/pgadmin-service 8081:80"
echo ""
echo "Checking if Cilium connectivity test should run..."
if kubectl get daemonset -n kube-system cilium &> /dev/null && ! kubectl get pod -n cilium-test &> /dev/null; then
  echo "Running Cilium connectivity test..."
  cilium connectivity test
else
  echo "Skipping Cilium connectivity test (already run or Cilium not installed)..."
fi

echo "Applications will be available at:"
echo "- Linkding: http://localhost:8080"
echo "- pgAdmin: http://localhost:8081"
echo ""
echo "Default credentials:"
echo "- Linkding: admin / admin-password"
echo "- pgAdmin: admin@example.com / admin"
echo ""
echo "To check Cilium status: cilium status"
echo "To run connectivity test: cilium connectivity test"