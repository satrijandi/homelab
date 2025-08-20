# TODO:
- Add claude commands
- Showcase cilium

# COMMON COMMANDS:
k port-forward -n argocd svc/argocd-server 8081:80
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
k port-forward -n gitea svc/gitea-http 8082:3000
k port-forward -n mlflow svc/mlflow 8083:5000
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d