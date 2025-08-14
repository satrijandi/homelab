.POSIX:
.PHONY: *
.EXPORT_ALL_VARIABLES:

KUBECONFIG = $(shell pwd)/metal/kubeconfig.yaml
KUBE_CONFIG_PATH = $(KUBECONFIG)

default: metal system

metal:
	@echo "Setting up k3d cluster..."
	make -C metal

system:
	@echo "Bootstrapping ArgoCD..."
	make -C system bootstrap

clean:
	@echo "Cleaning up cluster..."
	make -C metal destroy

status:
	@echo "Cluster status:"
	make -C metal status
	@echo "\nArgoCD status:"
	kubectl get pods -n argocd 2>/dev/null || echo "ArgoCD not deployed yet"
	@echo "\nGitea status:"
	kubectl get pods -n gitea 2>/dev/null || echo "Gitea not deployed yet"