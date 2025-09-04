# TODO:
- Add claude commands

# COMMON COMMANDS:
kubectl port-forward -n argocd svc/argocd-server 8081:80
kubectl port-forward -n gitea svc/gitea-http 8082:3000
kubectl port-forward -n pgadmin4 svc/pgadmin4 8083:80
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo