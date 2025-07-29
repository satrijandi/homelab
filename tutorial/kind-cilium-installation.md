Cilium Quick Installation
This guide will walk you through the quick default installation. It will automatically detect and use the best configuration possible for the Kubernetes distribution you are using. All state is stored using Kubernetes custom resource definitions (CRDs).

This is the best installation method for most use cases. For large environments (> 500 nodes) or if you want to run specific datapath modes, refer to the Getting Started guide.

Should you encounter any issues during the installation, please refer to the Troubleshooting section and/or seek help on Cilium Slack.

Create the Cluster
If you don’t have a Kubernetes Cluster yet, you can use the instructions below to create a Kubernetes cluster locally or using a managed Kubernetes service:

GKEAKSEKSkindminikubeRancher DesktopAlibaba ACK
Install kind >= v0.7.0 per kind documentation: Installation and Usage

curl -LO https://raw.githubusercontent.com/cilium/cilium/1.17.6/Documentation/installation/kind-config.yaml
kind create cluster --config=kind-config.yaml
Note

Cilium may fail to deploy due to too many open files in one or more of the agent pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Install the Cilium CLI
Install the latest version of the Cilium CLI. The Cilium CLI can be used to install Cilium, inspect the state of a Cilium installation, and enable/disable various features (e.g. clustermesh, Hubble).

LinuxmacOSOther
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
Video

To learn more about the Cilium CLI, check out eCHO episode 8: Exploring the Cilium CLI.

Install Cilium
You can install Cilium on any Kubernetes cluster. Pick one of the options below:

GenericGKEAKSEKSOpenShiftRKEk3sAlibaba ACK
These are the generic instructions on how to install Cilium into any Kubernetes cluster. The installer will attempt to automatically pick the best configuration options for you. Please see the other tabs for distribution/platform specific instructions which also list the ideal default configuration for particular platforms.

Requirements:

Kubernetes must be configured to use CNI (see Network Plugin Requirements)

Linux kernel >= 5.4

Tip

See System Requirements for more details on the system requirements.

Install Cilium

Install Cilium into the Kubernetes cluster pointed to by your current kubectl context:

cilium install --version 1.17.6
If the installation fails for some reason, run cilium status to retrieve the overall status of the Cilium deployment and inspect the logs of whatever pods are failing to be deployed.

Tip

You may be seeing cilium install print something like this:

♻️  Restarted unmanaged pod kube-system/event-exporter-gke-564fb97f9-rv8hg
♻️  Restarted unmanaged pod kube-system/kube-dns-6465f78586-hlcrz
♻️  Restarted unmanaged pod kube-system/kube-dns-autoscaler-7f89fb6b79-fsmsg
♻️  Restarted unmanaged pod kube-system/l7-default-backend-7fd66b8b88-qqhh5
♻️  Restarted unmanaged pod kube-system/metrics-server-v0.3.6-7b5cdbcbb8-kjl65
♻️  Restarted unmanaged pod kube-system/stackdriver-metadata-agent-cluster-level-6cc964cddf-8n2rt
This indicates that your cluster was already running some pods before Cilium was deployed and the installer has automatically restarted them to ensure all pods get networking provided by Cilium.

Validate the Installation
To validate that Cilium has been properly installed, you can run

cilium status --wait
   /¯¯\
/¯¯\__/¯¯\    Cilium:         OK
\__/¯¯\__/    Operator:       OK
/¯¯\__/¯¯\    Hubble:         disabled
\__/¯¯\__/    ClusterMesh:    disabled
   \__/

DaemonSet         cilium             Desired: 2, Ready: 2/2, Available: 2/2
Deployment        cilium-operator    Desired: 2, Ready: 2/2, Available: 2/2
Containers:       cilium-operator    Running: 2
                  cilium             Running: 2
Image versions    cilium             quay.io/cilium/cilium:v1.9.5: 2
                  cilium-operator    quay.io/cilium/operator-generic:v1.9.5: 2
Run the following command to validate that your cluster has proper network connectivity:

cilium connectivity test
ℹ️  Monitor aggregation detected, will skip some flow validation steps
✨ [k8s-cluster] Creating namespace for connectivity check...

---------------------------------------------------------------------------------------------------------------------
📋 Test Report
---------------------------------------------------------------------------------------------------------------------
✅ 69/69 tests successful (0 warnings)
Note

The connectivity test may fail to deploy due to too many open files in one or more of the pods. If you notice this error, you can increase the inotify resource limits on your host machine (see Pod errors due to “too many open files”).

Congratulations! You have a fully functional Kubernetes cluster with Cilium. 🎉

Next Steps
Setting up Hubble Observability

Inspecting Network Flows with the CLI

Service Map & Hubble UI

Identity-Aware and HTTP-Aware Policy Enforcement

Setting up Cluster Mesh

