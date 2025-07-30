# Airflow GitOps Deployment Guide

This guide shows how to deploy Airflow with DAGs using GitOps best practices.

## Files Structure

```
/workspaces/homelab/
├── airflow-gitops.yaml       # ConfigMaps and Secrets
├── airflow-values.yaml       # Helm values override
├── airflow/
│   └── first_dag.py         # DAG source file
└── cleanup-airflow-patches.sh # Cleanup script
```

## GitOps Best Practices Applied

### ✅ What We Fixed

1. **Declarative Configuration**: All resources defined in YAML manifests
2. **Version Control Ready**: DAG files stored in Git, not copied manually
3. **Immutable Infrastructure**: ConfigMaps instead of direct file copies
4. **Proper Helm Integration**: Using values.yaml instead of kubectl patches
5. **Clean Separation**: Configuration separate from application deployment

### ❌ What We Avoided (Anti-patterns)

- Manual `kubectl cp` operations
- Runtime `kubectl patch` commands  
- Hardcoded secrets in pods
- Manual configuration changes

## Deployment Steps

### 1. Apply GitOps Manifests
```bash
kubectl apply -f /workspaces/homelab/airflow-gitops.yaml
```

### 2. Upgrade Airflow with New Values
```bash
helm upgrade airflow apache-airflow/airflow \
  -n airflow \
  -f /workspaces/homelab/airflow-values.yaml
```

### 3. Verify Deployment
```bash
# Check DAG is loaded
kubectl exec -n airflow deployment/airflow-scheduler -- airflow dags list

# Check DAG status
kubectl exec -n airflow deployment/airflow-scheduler -- airflow dags unpause first_dag_hello_world
```

## DAG Management Workflow

### Adding New DAGs
1. Create DAG file in `/workspaces/homelab/airflow/`
2. Update `airflow-gitops.yaml` ConfigMap with new DAG
3. Apply changes: `kubectl apply -f airflow-gitops.yaml`
4. DAGs auto-reload (no pod restarts needed)

### Updating Existing DAGs
1. Modify DAG file in `/workspaces/homelab/airflow/`  
2. Update ConfigMap in `airflow-gitops.yaml`
3. Apply: `kubectl apply -f airflow-gitops.yaml`

### Example: Adding a New DAG
```yaml
# In airflow-gitops.yaml ConfigMap
data:
  first_dag.py: |
    # existing DAG content
  
  second_dag.py: |
    from datetime import datetime, timedelta
    from airflow import DAG
    from airflow.operators.bash import BashOperator
    
    dag = DAG('second_dag', ...)
    # DAG definition
```

## Security Best Practices

- **Secrets Management**: JWT secrets stored in Kubernetes Secrets
- **RBAC**: Proper role-based access control enabled
- **Least Privilege**: ConfigMaps mounted read-only
- **No Hardcoded Credentials**: All sensitive data in Secrets

## Monitoring & Observability

- **Airflow UI**: `kubectl port-forward -n airflow svc/airflow-api-server 8080:8080`
- **Flower (Celery)**: `kubectl port-forward -n airflow svc/airflow-flower 5555:5555`
- **DAG Logs**: Available in Airflow UI and pod logs

## Rollback Strategy

If issues occur:
1. Revert ConfigMap: `kubectl apply -f previous-version.yaml`
2. Or rollback Helm: `helm rollback airflow -n airflow`

## Next Steps

1. **Git Integration**: Set up GitSync for automatic DAG deployment from Git
2. **CI/CD Pipeline**: Automate DAG testing and deployment
3. **Multi-Environment**: Separate dev/staging/prod configurations
4. **Secret Management**: Integrate with external secret management (Vault, etc.)

## Resources Created

- `airflow-jwt-secret` - JWT authentication secret
- `airflow-dags` - DAG files ConfigMap  
- `airflow-config` - Updated Airflow configuration
- Volume mounts in all Airflow components