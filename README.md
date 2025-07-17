# Homelab Kubernetes GitOps

This repository contains Kubernetes manifests for a homelab environment using GitOps principles with CloudNativePG and pgAdmin.

## Architecture

### Infrastructure Components
- **CloudNativePG Operator**: PostgreSQL operator for Kubernetes (v1.26.0)
- **PostgreSQL Cluster**: 3-instance highly available PostgreSQL cluster
- **Namespace Management**: Separated infrastructure and applications

### Applications
- **pgAdmin**: Web-based PostgreSQL administration interface
- **Linkding**: Bookmark management application (existing)

## Directory Structure

```
├── infrastructure/
│   ├── cloudnative-pg/          # CloudNativePG operator installation
│   ├── databases/               # PostgreSQL cluster configuration
│   └── kustomization.yaml       # Infrastructure overlay
├── applications/
│   ├── pgadmin/                 # pgAdmin deployment
│   ├── linkding/                # Linkding application (existing)
│   └── kustomization.yaml       # Applications overlay
└── kustomization.yaml           # Root overlay
```

## Deployment Instructions

### Prerequisites
- Kubernetes cluster with kubectl access
- Kustomize CLI tool
- Storage class `local-path` available
- Ingress controller (nginx) installed

### 1. Deploy Infrastructure

```bash
# Deploy CloudNativePG operator
kubectl apply -k infrastructure/cloudnative-pg/

# Wait for operator to be ready
kubectl rollout status deployment -n cnpg-system cnpg-controller-manager

# Deploy PostgreSQL cluster
kubectl apply -k infrastructure/databases/

# Check cluster status
kubectl get cluster -n databases
kubectl get pods -n databases
```

### 2. Deploy Applications

```bash
# Deploy pgAdmin
kubectl apply -k applications/pgadmin/

# Check pgAdmin deployment
kubectl get pods -n pgadmin
kubectl get svc -n pgadmin
```

### 3. Complete Deployment

```bash
# Deploy everything at once
kubectl apply -k .
```

## Configuration

### PostgreSQL Cluster
- **Instances**: 3 (1 primary, 2 replicas)
- **Database**: `app` with user `app`
- **Storage**: 10Gi per instance
- **Backup**: Configured for S3-compatible storage (requires credential setup)

### pgAdmin Access
- **URL**: https://pgadmin.homelab.local (configure in `/etc/hosts`)
- **Username**: admin@homelab.local
- **Password**: changeme123 (change in production)

### Security Notes
- Default passwords are set in secrets - **change these in production**
- Update `infrastructure/databases/postgres-credentials.yaml` with secure passwords
- Configure proper backup credentials in `backup-credentials` secret
- Set up proper TLS certificates for ingress

## Monitoring

```bash
# Check PostgreSQL cluster status
kubectl get cluster -n databases postgres-cluster

# View PostgreSQL logs
kubectl logs -n databases -l cnpg.io/cluster=postgres-cluster

# Check pgAdmin logs
kubectl logs -n pgadmin -l app=pgadmin

# Port forward for local access
kubectl port-forward -n pgadmin svc/pgadmin-service 8080:80
```

## Maintenance

### Backup Configuration
Configure S3-compatible storage credentials in `infrastructure/databases/postgres-credentials.yaml`:

```yaml
stringData:
  ACCESS_KEY_ID: "your-actual-access-key"
  SECRET_ACCESS_KEY: "your-actual-secret-key"
```

### Scaling
To scale PostgreSQL replicas:
```bash
kubectl patch cluster -n databases postgres-cluster -p '{"spec":{"instances":5}}' --type=merge
```

## Troubleshooting

### Common Issues
1. **Pods stuck in Pending**: Check storage class and node resources
2. **pgAdmin can't connect**: Verify PostgreSQL service name and credentials
3. **Ingress not working**: Ensure ingress controller is installed and configured

### Useful Commands
```bash
# Check all resources
kubectl get all -n databases
kubectl get all -n pgadmin

# Describe cluster for troubleshooting
kubectl describe cluster -n databases postgres-cluster

# Get connection details
kubectl get secret -n databases postgres-cluster-app -o yaml
```
