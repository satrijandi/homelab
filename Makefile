.PHONY: metal system platform apps clean help

metal:
	@echo "Setting up k3d cluster..."
	make -C metal cluster

system:
	@echo "Installing system layer (ArgoCD)..."
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
	make -C system clean || true
	make -C metal clean

help:
	@echo "Homelab Data Platform Architecture"
	@echo "=================================="
	@echo "make metal   - Create k3d cluster"
	@echo "make system  - Install ArgoCD (GitOps)"
	@echo "make status  - Check deployment status"
	@echo "make clean   - Remove everything"
	@echo ""
	@echo "After 'make system', ArgoCD will automatically deploy:"
	@echo "  - Platform layer: Gitea (localhost:30300)"
	@echo "  - Application layer: Nginx (localhost:30080)"