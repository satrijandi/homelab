.PHONY: metal
metal:
	@echo "Creating k3d cluster with latest stable Kubernetes..."
	k3d cluster create homelab \
		--image rancher/k3s:v1.31.0-k3s1 \
		--port "80:80@loadbalancer" \
		--port "443:443@loadbalancer" \
		--port "6443:6443@server:0" \
		--agents 2 \
		--servers 1 \
		--wait
	@echo "k3d cluster 'homelab' created successfully!"
	@echo "Updating kubeconfig..."
	k3d kubeconfig merge homelab --kubeconfig-switch-context
	@echo "Cluster is ready for use!"

.PHONY: clean
clean:
	@echo "Deleting k3d cluster..."
	k3d cluster delete homelab || true
	@echo "k3d cluster deleted!"