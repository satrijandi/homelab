#!/bin/bash

set -e

echo "🚀 Starting Cilium installation with kind cluster"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "📋 Checking prerequisites..."

if ! command_exists kind; then
    echo "❌ Error: kind is not installed. Please install kind first."
    echo "   Visit: https://kind.sigs.k8s.io/docs/user/quick-start/#installation"
    exit 1
fi

if ! command_exists kubectl; then
    echo "❌ Error: kubectl is not installed. Please install kubectl first."
    exit 1
fi

if ! command_exists curl; then
    echo "❌ Error: curl is not installed. Please install curl first."
    exit 1
fi

echo "✅ Prerequisites check passed"

# Step 1: Download kind config for Cilium
echo "📥 Downloading kind config for Cilium..."
curl -LO https://raw.githubusercontent.com/cilium/cilium/1.17.6/Documentation/installation/kind-config.yaml
echo "✅ Downloaded kind-config.yaml"

# Step 2: Create kind cluster
echo "🔧 Creating kind cluster with Cilium configuration..."

# Check if cluster already exists and delete it
if kind get clusters | grep -q "^kind$"; then
    echo "⚠️  Existing 'kind' cluster found. Deleting it..."
    kind delete cluster --name kind
    echo "✅ Existing cluster deleted"
fi

kind create cluster --config=kind-config.yaml
echo "✅ Kind cluster created successfully"

# Step 3: Install Cilium CLI
echo "📦 Installing Cilium CLI..."
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then 
    CLI_ARCH=arm64
fi

curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
echo "✅ Cilium CLI installed successfully"

# Step 4: Install Cilium
echo "🔧 Installing Cilium into the cluster..."
cilium install --version 1.17.6
echo "✅ Cilium installation completed"

# Step 5: Wait for Cilium to be ready
echo "⏳ Waiting for Cilium to be ready..."
cilium status --wait
echo "✅ Cilium is ready"

# Step 6: Run connectivity test
echo "🧪 Running Cilium connectivity test..."
cilium connectivity test
echo "✅ Connectivity test passed"

echo ""
echo "🎉 Cilium installation completed successfully!"
echo "📋 Your cluster is ready with:"
echo "   - Kind cluster: kind-kind"
echo "   - Cilium CNI: v1.17.6"
echo "   - kubectl context: kind-kind"
echo ""
echo "🔍 Use 'kubectl get pods -A' to see all pods"
echo "🔍 Use 'cilium status' to check Cilium status"