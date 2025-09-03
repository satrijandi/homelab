# Homelab - Data Platform Architecture

A complete GitOps-based homelab setup demonstrating modern data platform architecture patterns using Kubernetes, ArgoCD, and automated deployment workflows.

## 🏗️ Architecture Overview

This homelab implements a **4-layer architecture**:

### Metal Layer
- **k3d**: Lightweight Kubernetes cluster for development

### System Layer
- **ArgoCD**: GitOps controller for automated deployments
- **MinIO**: S3-compatible object storage for data persistence
- **CloudNative-PG**: PostgreSQL operator for database cluster management

### Platform Layer  
- **Gitea**: Self-hosted Git repository management
- **MLflow**: Machine learning experiment tracking and model registry
- **Zot**: OCI-compliant registry for container images

### Application Layer
- **Nginx**: Web server with custom landing page
- **pgAdmin4**: PostgreSQL database administration interface

## 🚀 Quick Start

### Prerequisites
- Docker
- k3d
- kubectl
- helm
- make

### Setup Commands

```bash
# 1. Create k3d cluster
make metal

# 2. Deploy ArgoCD and all applications
make system

# 3. Check deployment status
make status

# 4. Clean everything up
make clean
```

### Access Services

After running `make system`, access your services:

- **ArgoCD**: http://localhost:30080
  - Username: `admin`
  - Password: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d`

- **Gitea**: http://localhost:30300
  - Username: `admin`
  - Password: `homelab123`

- **MLflow**: http://localhost:30500
  - Machine learning experiment tracking and model registry
  - ⚠️ **PORT CONFLICT**: Zot also configured for port 30500

- **pgAdmin4**: http://localhost:30082
  - Username: `admin@homelab.com`
  - Password: `homelab123`
  - Pre-configured with PostgreSQL connections

- **Nginx**: http://localhost:30081
  - Custom homelab dashboard

- **MinIO**: 
  - API: http://localhost:30090
  - Console: http://localhost:30091
  - Username: `admin`
  - Password: `homelab123`

- **Zot Registry**: http://localhost:30500 ⚠️ **CONFLICTED PORT**
  - OCI-compliant container registry
  - Currently conflicts with MLflow port

## 📁 Project Structure

```
homelab/
├── Makefile                 # Main build automation
├── bootstrap.yaml           # ArgoCD bootstrap application
├── bootstrap.yaml.template  # Template for GitOps repo switching
├── metal/                   # Metal layer - Cluster infrastructure
│   ├── Makefile            # k3d cluster management
│   └── k3d-dev.yaml        # k3d cluster configuration
├── system/                  # System layer
│   ├── argocd/             # ArgoCD GitOps controller
│   ├── minio/              # S3-compatible object storage
│   ├── cloudnative-pg/     # PostgreSQL operator
│   ├── applicationset.yaml # Auto-discovery of applications
│   └── Makefile            # System deployment
├── platform/               # Platform layer
│   ├── gitea/              # Self-hosted Git server
│   ├── mlflow/             # ML experiment tracking
│   └── zot/                # OCI registry
└── applications/           # Application layer
    ├── nginx/              # Web server
    └── pgadmin4/           # PostgreSQL admin interface
```

## 🔄 Advanced GitOps Workflow

The homelab implements a **dual-repository GitOps pattern** with automatic repository switching:

### Initial Setup (GitHub-based)
1. **Bootstrap**: `bootstrap.yaml` creates the ArgoCD bootstrap application using GitHub
2. **ApplicationSet**: Automatically discovers applications in `system/`, `platform/`, and `applications/` directories
3. **Auto-deployment**: ArgoCD deploys CloudNative-PG, MinIO, Gitea, MLflow, pgAdmin4, Nginx

### Repository Migration (GitHub → Gitea)
4. **Repository Setup**: `make setup-repos` pushes code to both GitHub and local Gitea
5. **Repository Switch**: `make switch-to-gitea` updates ArgoCD to use local Gitea repository
6. **Self-contained**: System becomes fully self-hosted with local Git repository

### ApplicationSet Discovery Pattern

```yaml
# system/applicationset.yaml
generators:
- git:
    repoURL: https://github.com/satrijandi/homelab.git  # Initial
    # Later switches to: http://gitea-http.gitea.svc.cluster.local:3000/ops/homelab.git
    directories:
    - path: system/minio           # MinIO object storage
    - path: system/cloudnative-pg  # PostgreSQL operator
    - path: platform/gitea         # Git repository
    - path: applications/*         # All applications (nginx, pgadmin4)
```

### GitOps Repository Switching

The system supports seamless switching from external GitHub to internal Gitea:

```bash
# Template-based configuration
bootstrap.yaml.template → bootstrap.yaml (with correct repo URL)
system/applicationset.yaml.template → system/applicationset.yaml

# Automatic repository detection and switching
./scripts/setup-git-repos.sh get-repo-url  # Detects available repo
```

## 🛠️ Development Workflow

### Making Changes

1. **Modify configurations** in Git repository
2. **Commit and push** changes
3. **ArgoCD automatically syncs** applications
4. **Monitor deployment** via ArgoCD UI or `make status`

### Adding New Applications

1. Create new directory under `platform/` or `applications/`
2. Add Kubernetes manifests or Helm charts
3. Commit to Git - ArgoCD will auto-discover and deploy

## 🔧 Makefile Commands

| Command | Description |
|---------|-------------|
| `make all` | Complete setup (metal → system → setup-repos → switch-to-gitea) |
| `make metal` | Create k3d cluster |
| `make system` | Deploy ArgoCD and auto-sync all applications |
| `make setup-repos` | Push code to GitHub and Gitea repositories |
| `make switch-to-gitea` | Switch ArgoCD to use local Gitea instead of GitHub |
| `make status` | Check deployment status |
| `make clean` | Destroy entire cluster |
| `make help` | Show all available commands and workflow |

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Port Conflicts
**Problem**: Service fails with "port already allocated"
```
Solution: Check port usage and update NodePort values
kubectl get svc -A | grep <port>
```

#### Port Conflicts
**Problem**: MLflow and Zot both configured for NodePort 30500
```yaml
# Solution: Update one service to use different port
# In platform/zot/values.yaml or platform/mlflow/values.yaml
service:
  nodePort: 30501  # Change from 30500
```

#### PostgreSQL Configuration Conflict (Gitea)
**Problem**: `Only one of postgresql or postgresql-ha can be enabled`
```yaml
# Solution: Explicitly disable postgresql-ha in values.yaml
postgresql:
  enabled: true
postgresql-ha:
  enabled: false
```

#### Application OutOfSync
**Problem**: ArgoCD shows application as OutOfSync
```bash
# Solution: Force refresh and sync
kubectl patch application <app-name> -n argocd --type json \
  -p='[{"op": "replace", "path": "/operation", "value": {"sync": {"revision": "HEAD"}}}]'
```

#### Namespace Not Found
**Problem**: Resources fail to deploy due to missing namespace
```bash
# Solution: Ensure CreateNamespace=true in ApplicationSet or create manually
kubectl create namespace <namespace-name>
```

### Logs and Debugging

```bash
# Check ArgoCD application status
kubectl get applications -n argocd

# Describe specific application
kubectl describe application <app-name> -n argocd

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-server

# Check application pods
kubectl get pods -n <namespace>
```

## 🎯 Learning Objectives

This homelab demonstrates:

- **Advanced GitOps**: Dual-repository pattern with automatic GitHub → Gitea migration
- **4-Layer Architecture**: Clean separation across Metal/System/Platform/Application layers
- **Database Operations**: CloudNative-PG operator with pgAdmin4 management interface
- **ML Platform**: MLflow experiment tracking with MinIO artifact storage
- **Container Registry**: Self-hosted Zot OCI registry for container images
- **Infrastructure as Code**: Complete version-controlled infrastructure definitions
- **Automated Deployment**: Sophisticated ArgoCD ApplicationSet patterns
- **Self-Hosting**: Transition from external dependencies to fully self-contained system

## 🔄 Continuous Improvement

### Performance Optimizations
- Resource limits and requests configured for all components
- Persistent storage for stateful applications (Gitea, PostgreSQL)
- Health checks and readiness probes

### Security Features
- Network policies for service isolation
- Pod disruption budgets for availability
- Secret management for sensitive data
- Offline mode for Gitea (no external dependencies)

### Monitoring and Observability
- ArgoCD UI for deployment visibility
- Application health status monitoring
- Resource utilization tracking

## 📚 Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [k3d Documentation](https://k3d.io/)
- [Gitea Documentation](https://docs.gitea.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes and test with `make clean && make metal && make system`
4. Submit pull request

---

**Built with ❤️ for learning modern DevOps practices**