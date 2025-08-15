.PHONY: cluster clean

cluster:
	@echo "Starting or creating k3d cluster..."
	k3d cluster start homelab-dev || k3d cluster create --config k3d-dev.yaml
	@echo "Updating kubeconfig..."
	k3d kubeconfig get homelab-dev > kubeconfig.yaml
	@echo "Merging with default kubeconfig..."
	k3d kubeconfig merge homelab-dev --kubeconfig-merge-default --kubeconfig-switch-context
	@echo "Cluster is ready for use!"

clean:
	@echo "Deleting k3d cluster..."
	k3d cluster delete homelab-dev || true
	@echo "Removing kubeconfig..."
	rm -f kubeconfig.yaml
	@echo "k3d cluster deleted!"