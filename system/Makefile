.PHONY: install bootstrap status clean

install:
	@echo "Installing Cilium CNI..."
	helm repo add cilium https://helm.cilium.io/
	helm repo update
	helm upgrade --install cilium cilium/cilium --version 1.16.5 \
		--namespace kube-system \
		--set kubeProxyReplacement=true \
		--set operator.replicas=1
	@echo "Waiting for Cilium to be ready..."
	kubectl wait --for=condition=ready pod -l k8s-app=cilium -n kube-system --timeout=300s
	@echo "Installing ArgoCD and setting up GitOps..."
	@echo "Using Git repository: $${GIT_REPO_URL:-https://github.com/satrijandi/homelab.git}"
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm dependency build argocd/
	helm upgrade --install argocd argocd/ -n argocd
	@echo "ArgoCD installed successfully!"
	@echo "Waiting for ArgoCD to be ready..."
	kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
	@echo "Generating configuration from templates..."
	envsubst < ../bootstrap.yaml.template > ../bootstrap.yaml
	envsubst < applicationset.yaml.template > applicationset.yaml
	@echo "Applying bootstrap configuration..."
	kubectl apply -f ../bootstrap.yaml
	@echo "Deploying ApplicationSet for automatic app discovery..."
	kubectl apply -f applicationset.yaml
	@echo "Waiting for ApplicationSet to discover applications..."
	sleep 50
	@echo "Syncing discovered applications..."
	kubectl patch application gitea -n argocd --type='merge' -p='{"operation":{"sync":{"revision":"main"}}}' || echo "Gitea app not ready yet"
	kubectl patch application nginx -n argocd --type='merge' -p='{"operation":{"sync":{"revision":"main"}}}' || echo "Nginx app not ready yet"
	@echo ""
	@echo "🎉 ArgoCD and applications are ready!"
	@echo "Access ArgoCD at: http://localhost:30080"
	@echo "Access Gitea at: http://localhost:30300"
	@echo "Get ArgoCD admin password: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"

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