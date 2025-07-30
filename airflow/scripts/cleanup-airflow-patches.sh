#!/bin/bash
# Cleanup script for non-GitOps Airflow modifications

echo "🧹 Cleaning up temporary Airflow modifications..."

# Remove temporary ConfigMaps and Secrets
echo "Removing temporary ConfigMap..."
kubectl delete configmap first-dag-config -n airflow --ignore-not-found=true

echo "Removing temporary JWT secret..."
kubectl delete secret airflow-jwt-secret -n airflow --ignore-not-found=true

# Note: The deployment patches would require helm upgrade to properly revert
echo "⚠️  Note: Deployment volume mount patches require Helm upgrade to revert properly"
echo "   Run: helm upgrade airflow apache-airflow/airflow -n airflow -f /workspaces/homelab/airflow-values.yaml"

echo "✅ Cleanup completed. Apply GitOps manifests next:"
echo "   kubectl apply -f /workspaces/homelab/airflow-gitops.yaml"