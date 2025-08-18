# CLAUDE.md - Homelab Project Context

## Project Overview
This is a GitOps-based homelab demonstrating modern data platform architecture using Kubernetes, ArgoCD, and automated deployment workflows. The project implements a 4-layer architecture pattern with Infrastructure as Code principles.

## Architecture Layers

### Metal Layer
- **k3d**: Lightweight Kubernetes cluster for development

### System Layer
- **ArgoCD**: GitOps controller for automated deployments
- **MinIO**: S3-compatible object storage for data persistence

### Platform Layer
- **Gitea**: Self-hosted Git repository management
- **PostgreSQL**: Database backend for Gitea

### Application Layer
- **Nginx**: Web server with custom landing page

## Key Commands

### Cluster Management
- `make metal` - Create k3d cluster
- `make system` - Deploy ArgoCD and auto-sync all applications
- `make status` - Check deployment status
- `make clean` - Destroy entire cluster
- `make help` - Show all available commands

### Testing & Validation
- After making changes, always run `make status` to verify deployments
- Use `kubectl get applications -n argocd` to check ArgoCD application status
- Check service access via NodePort endpoints

## Project Structure
```
homelab/
├── Makefile                 # Main build automation
├── bootstrap.yaml           # ArgoCD bootstrap application
├── metal/                   # Cluster infrastructure (k3d)
├── system/                  # System layer (ArgoCD, MinIO)
├── platform/               # Platform layer (Gitea)
├── applications/            # Application layer (Nginx)
└── scripts/                 # Utility scripts
```

## GitOps Workflow
1. **Bootstrap**: `bootstrap.yaml` creates ArgoCD bootstrap application
2. **ApplicationSet**: Auto-discovers applications in `platform/` and `applications/` directories
3. **Sync**: ArgoCD monitors Git and deploys changes automatically
4. **Self-Healing**: Applications recover from drift automatically

## Service Access Points
- **ArgoCD**: http://localhost:30080 (admin/get-password-from-secret)
- **Gitea**: http://localhost:30300 (admin/homelab123)
- **Nginx**: http://localhost:30081
- **MinIO Console**: http://localhost:30091 (admin/homelab123)
- **MinIO API**: http://localhost:30090

## Common Patterns

### Adding New Applications
1. Create directory under `platform/` or `applications/`
2. Add Kubernetes manifests or Helm charts
3. Commit to Git - ArgoCD auto-discovers and deploys

### Configuration Management
- Use Helm values.yaml for application configuration
- Kubernetes manifests for simple deployments
- ApplicationSet automatically discovers new applications

### Troubleshooting
- Check ArgoCD UI for sync status
- Use `kubectl describe application <app-name> -n argocd` for details
- Check pod logs with `kubectl logs -n <namespace>`

## Development Workflow
1. Make configuration changes in Git repository
2. Commit and push changes
3. ArgoCD automatically syncs applications
4. Monitor deployment via ArgoCD UI or `make status`

## Prerequisites
- Docker
- k3d
- kubectl
- helm
- make

## Important Notes
- This is a learning/development environment
- All services use NodePort for external access
- GitOps principles: everything is declarative and version-controlled
- Self-contained setup with minimal external dependencies