.PHONY: metal clean

metal:
	@echo "Setting up k3d cluster..."
	make -C metal cluster

clean:
	@echo "Cleaning up k3d cluster..."
	make -C metal clean