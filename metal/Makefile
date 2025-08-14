.POSIX:

export KUBECONFIG = $(shell pwd)/kubeconfig.yaml

default: cluster

cluster:
	@echo "Creating k3d cluster..."
	k3d cluster create --config k3d-config.yaml
	k3d kubeconfig get homelab > kubeconfig.yaml
	@echo "Cluster created successfully!"

destroy:
	@echo "Destroying k3d cluster..."
	k3d cluster delete homelab
	rm -f kubeconfig.yaml
	@echo "Cluster destroyed!"

status:
	k3d cluster list