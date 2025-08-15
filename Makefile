.PHONY: metal system platform apps clean help setup-repos switch-to-gitea

metal:
	@echo "Setting up k3d cluster..."
	make -C metal cluster

system:
	@echo "Installing system layer (ArgoCD) and deploying applications..."
	@echo "Determining Git repository source..."
	@REPO_URL=$$(./scripts/setup-git-repos.sh get-repo-url); \
	echo "Using repository: $$REPO_URL"; \
	export GIT_REPO_URL="$$REPO_URL"; \
	make -C system install

platform:
	@echo "Platform layer will be deployed via ArgoCD..."
	@echo "Check ArgoCD UI for Gitea deployment status"

apps:
	@echo "Application layer will be deployed via ArgoCD..."
	@echo "Check ArgoCD UI for Nginx deployment status"

status:
	@echo "System Status:"
	make -C system status

clean:
	@echo "Cleaning up entire homelab..."
	make -C metal clean

setup-repos:
	@echo "Setting up Git repositories..."
	./scripts/setup-git-repos.sh push

switch-to-gitea:
	@echo "Switching ArgoCD to use Gitea repository..."
	@if [ "$$(./scripts/setup-git-repos.sh check-repo)" = "exists" ]; then \
		echo "Gitea repository exists, updating ArgoCD configuration..."; \
		export GIT_REPO_URL="http://gitea-http.gitea.svc.cluster.local:3000/ops/homelab.git"; \
		envsubst < bootstrap.yaml.template > bootstrap.yaml; \
		envsubst < system/applicationset.yaml.template > system/applicationset.yaml; \
		kubectl apply -f bootstrap.yaml; \
		kubectl apply -f system/applicationset.yaml; \
		echo "Forcing refresh of ApplicationSet to update all applications..."; \
		kubectl annotate applicationset homelab-layers -n argocd argocd.argoproj.io/refresh=hard --overwrite; \
		echo "Waiting for applications to sync..."; \
		sleep 10; \
		echo "ArgoCD and all applications now using Gitea repository"; \
	else \
		echo "Gitea repository not found. Run 'make setup-repos' first."; \
		exit 1; \
	fi

help:
	@echo "Homelab Data Platform Architecture"
	@echo "=================================="
	@echo "make metal        - Create k3d cluster"
	@echo "make system       - Install ArgoCD and deploy all applications"
	@echo "make setup-repos  - Push code to GitHub and Gitea repositories"
	@echo "make switch-to-gitea - Switch ArgoCD to use local Gitea"
	@echo "make status       - Check deployment status"
	@echo "make clean        - Remove everything"
	@echo ""
	@echo "The 'make system' command will automatically:"
	@echo "  - Use GitHub for initial install (if Gitea not available)"
	@echo "  - Use Gitea for subsequent installs (if available)"
	@echo "  - Deploy: ArgoCD, Gitea (localhost:30300), Nginx (localhost:30081), MinIO (localhost:30090/30091)"