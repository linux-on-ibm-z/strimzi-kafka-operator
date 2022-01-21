#!/usr/bin/env bash
set -xe

rm -rf ~/.kube

KUBE_VERSION=${KUBE_VERSION:-1.16.0}
COPY_DOCKER_LOGIN=${COPY_DOCKER_LOGIN:-"false"}

DEFAULT_MINIKUBE_MEMORY=$(free -m | grep "Mem" | awk '{print $2}')
DEFAULT_MINIKUBE_CPU=$(awk '$1~/cpu[0-9]/{usage=($2+$4)*100/($2+$4+$5); print $1": "usage"%"}' /proc/stat | wc -l)

MINIKUBE_MEMORY=${MINIKUBE_MEMORY:-$DEFAULT_MINIKUBE_MEMORY}
MINIKUBE_CPU=${MINIKUBE_CPU:-$DEFAULT_MINIKUBE_CPU}

echo "[INFO] MINIKUBE_MEMORY: ${MINIKUBE_MEMORY}"
echo "[INFO] MINIKUBE_CPU: ${MINIKUBE_CPU}"

function install_kubectl {
    if [ "${TEST_KUBECTL_VERSION:-latest}" = "latest" ]; then
        TEST_KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    fi
    curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/${TEST_KUBECTL_VERSION}/bin/linux/s390x/kubectl && chmod +x kubectl
    sudo cp kubectl /usr/local/bin
}

function label_node {
	# It should work for all clusters
	for nodeName in $(kubectl get nodes -o custom-columns=:.metadata.name --no-headers);
	do
		echo ${nodeName};
		kubectl label node ${nodeName} rack-key=zone;
	done
}

if [ "$TEST_CLUSTER" = "minikube" ]; then
    install_kubectl
    if [ "${TEST_MINIKUBE_VERSION:-latest}" = "latest" ]; then
        TEST_MINIKUBE_URL=https://storage.googleapis.com/minikube/releases/latest/minikube-linux-s390x
    else
        TEST_MINIKUBE_URL=https://github.com/kubernetes/minikube/releases/download/${TEST_MINIKUBE_VERSION}/minikube-linux-s390x
    fi

    if [ "$KUBE_VERSION" != "latest" ] && [ "$KUBE_VERSION" != "stable" ]; then
        KUBE_VERSION="v${KUBE_VERSION}"
    fi

    curl -Lo minikube ${TEST_MINIKUBE_URL} && chmod +x minikube
    sudo cp minikube /usr/local/bin

    export MINIKUBE_WANTUPDATENOTIFICATION=false
    export MINIKUBE_WANTREPORTERRORPROMPT=false
    export MINIKUBE_HOME=$HOME
    export CHANGE_MINIKUBE_NONE_USER=true

    mkdir $HOME/.kube || true
    touch $HOME/.kube/config
    grep cgroup /proc/filesystems

    export KUBECONFIG=$HOME/.kube/config
    # We can turn on network polices support by adding the following options --network-plugin=cni --cni=calico
    # We have to allow trafic for ITS when NPs are turned on
    # We can allow NP after Strimzi#4092 which should fix some issues on STs side
    sudo apt-get install linux-image-$(uname -r) socat -y
    sudo systemctl enable docker.service
    sudo systemctl restart docker
    minikube start --vm-driver=none --kubernetes-version=v1.23.1 \
      --extra-config=apiserver.authorization-mode=Node,RBAC \
      --extra-config=kubelet.cgroup-driver=systemd --cpus=${MINIKUBE_CPU}
    sudo systemctl status kubelet

    if [ $? -ne 0 ]
    then
        echo "Minikube failed to start or RBAC could not be properly set up"
        exit 1
    fi

    minikube addons enable default-storageclass

    # Add Docker hub credentials to Minikube
    if [ "$COPY_DOCKER_LOGIN" = "true" ]
    then
      set +ex

      docker exec "minikube" bash -c "echo '$(cat $HOME/.docker/config.json)'| sudo tee -a /var/lib/kubelet/config.json > /dev/null && sudo systemctl restart kubelet"

      set -ex
    fi

    minikube addons enable registry
    minikube addons enable registry-aliases

    kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
else
    echo "Unsupported TEST_CLUSTER '$TEST_CLUSTER'"
    exit 1
fi

label_node
