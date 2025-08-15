.PHONY: install bootstrap status clean

install:
	@echo "Installing ArgoCD and setting up GitOps..."
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm dependency build argocd/
	helm upgrade --install argocd argocd/ -n argocd --wait
	@echo "ArgoCD installed successfully!"
	@echo "Waiting for ArgoCD to be ready..."
	kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
	@echo "Applying bootstrap configuration..."
	kubectl apply -f ../bootstrap.yaml
	@echo ""
	@echo "🎉 ArgoCD is ready!"
	@echo "Access ArgoCD at: http://localhost:30080"
	@echo "Get admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"

bootstrap: install

status:
	@echo "ArgoCD Status:"
	kubectl get pods -n argocd
	@echo ""
	@echo "Applications:"
	kubectl get applications -n argocd
	@echo ""
	@echo "ApplicationSets:"
	kubectl get applicationsets -n argocd

clean:
	@echo "Removing ArgoCD..."
	kubectl delete -f ../bootstrap.yaml --ignore-not-found=true
	helm uninstall argocd -n argocd --ignore-not-found
	kubectl delete namespace argocd --ignore-not-found=true
	@echo "ArgoCD removed!"