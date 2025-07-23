# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a homelab repository for managing Kubernetes infrastructure using kustomize. The repository is in its initial setup phase and contains tools for container orchestration and cluster management.

## Key Tools and Dependencies

- **kustomize**: Kubernetes configuration management tool (binary located at `/workspaces/homelab/kustomize`)
- **kind**: Kubernetes-in-Docker for local cluster development
- **Claude Code**: AI-powered development assistant

## Development Environment Setup

The repository includes setup commands for the development environment:

```bash
# Install Claude Code globally
npm install -g @anthropic-ai/claude-code

# Update npm to specific version
npm install -g npm@11.4.2

# Install kustomize
curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

# Add kustomize to PATH
export PATH="/workspaces/homelab:$PATH"
source ~/.bashrc

# Install kind (Kubernetes in Docker)
# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

## Common Commands

- **kustomize**: Use the local binary at `/workspaces/homelab/kustomize` for Kubernetes configuration management
- **kind**: Create and manage local Kubernetes clusters for development and testing

## Architecture Notes

This is a homelab infrastructure repository focused on:
- Kubernetes cluster management
- Container orchestration
- Local development with kind clusters
- Configuration management via kustomize

The repository is currently minimal with setup instructions and tooling in place, ready for Kubernetes manifests and configurations to be added.