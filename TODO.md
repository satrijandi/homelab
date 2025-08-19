# TODO:
- Add claude commands

# COMMON COMMANDS:
k port-forward -n argocd svc/argocd-server 8081:80
k port-forward -n gitea svc/gitea-http 8082:3000
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d