.POSIX:
.PHONY: *
.EXPORT_ALL_VARIABLES:

KUBECONFIG = $(shell pwd)/metal/kubeconfig.yaml
KUBE_CONFIG_PATH = $(KUBECONFIG)

default: metal system post-install

metal:
	@echo "Setting up k3d cluster..."
	make -C metal

system:
	@echo "Bootstrapping ArgoCD..."
	make -C system bootstrap

post-install:
	@echo "Waiting for services to be ready..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
	@echo "Getting ArgoCD admin password..."
	kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""

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