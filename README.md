# Homelab - Data Platform Architecture

A complete GitOps-based homelab setup demonstrating modern data platform architecture patterns using Kubernetes, ArgoCD, and automated deployment workflows.

## 🏗️ Architecture Overview

This homelab implements a **3-layer architecture**:

### System Layer
- **ArgoCD**: GitOps controller for automated deployments
- **MinIO**: S3-compatible object storage for data persistence
- **k3d**: Lightweight Kubernetes cluster for development

### Platform Layer  
- **Gitea**: Self-hosted Git repository management
- **PostgreSQL**: Database backend for Gitea

### Application Layer
- **Nginx**: Web server with custom landing page
- **Redis (Valkey)**: Caching layer for applications

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

- **Nginx**: http://localhost:30081
  - Custom homelab dashboard

- **MinIO**: 
  - API: http://localhost:30090
  - Console: http://localhost:30091
  - Username: `admin`
  - Password: `homelab123`

## 📁 Project Structure

```
homelab/
├── Makefile                 # Main build automation
├── bootstrap.yaml           # ArgoCD bootstrap application
├── metal/                   # Cluster infrastructure
│   ├── Makefile            # k3d cluster management
│   └── k3d-dev.yaml        # k3d cluster configuration
├── system/                  # System layer (ArgoCD)
│   ├── Makefile            # ArgoCD deployment
│   ├── applicationset.yaml # Auto-discovery of applications
│   └── argocd/             # ArgoCD Helm chart
├── platform/               # Platform layer
│   └── gitea/              # Gitea Git server
│       ├── Chart.yaml
│       └── values.yaml
└── applications/           # Application layer
    └── nginx/              # Nginx web server
        └── deployment.yaml
```

## 🔄 GitOps Workflow

The homelab uses **ArgoCD ApplicationSet** for automatic application discovery:

1. **Bootstrap**: `bootstrap.yaml` creates the ArgoCD bootstrap application
2. **ApplicationSet**: Automatically discovers applications in `platform/` and `applications/` directories
3. **Sync**: ArgoCD continuously monitors Git repository and deploys changes
4. **Self-Healing**: Applications automatically recover from drift

### ApplicationSet Pattern

```yaml
# system/applicationset.yaml
generators:
- git:
    directories:
    - path: platform/*    # Discovers platform/gitea
    - path: applications/* # Discovers applications/nginx
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
| `make metal` | Create k3d cluster |
| `make system` | Deploy ArgoCD and auto-sync all applications |
| `make status` | Check deployment status |
| `make clean` | Destroy entire cluster |
| `make help` | Show all available commands |

## 🐛 Troubleshooting

### Common Issues and Solutions

#### Port Conflicts
**Problem**: Service fails with "port already allocated"
```
Solution: Check port usage and update NodePort values
kubectl get svc -A | grep <port>
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

- **GitOps Methodology**: Declarative infrastructure and application management
- **Layered Architecture**: Separation of concerns across system/platform/application layers
- **Container Orchestration**: Kubernetes resource management and networking
- **Infrastructure as Code**: Version-controlled infrastructure definitions
- **Automated Deployment**: CI/CD pipelines using ArgoCD
- **Service Discovery**: ApplicationSet pattern for automatic application detection
- **Configuration Management**: Helm charts and Kubernetes manifests

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