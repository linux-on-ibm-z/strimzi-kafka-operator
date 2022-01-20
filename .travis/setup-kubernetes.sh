#!/usr/bin/env bash
set -x

rm -rf ~/.kube

function install_kubectl {
    if [ "${TEST_KUBECTL_VERSION:-latest}" = "latest" ]; then
        TEST_KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    fi
    curl -Lo kubectl https://storage.googleapis.com/kubernetes-release/release/${TEST_KUBECTL_VERSION}/bin/linux/s390x/kubectl && chmod +x kubectl
    sudo cp kubectl /usr/bin
}

function wait_for_minikube {
    i="0"

    while [ $i -lt 60 ]
    do
        # The role needs to be added because Minikube is not fully prepared for RBAC.
        # Without adding the cluster-admin rights to the default service account in kube-system
        # some components would be crashing (such as KubeDNS). This should have no impact on
        # RBAC for Strimzi during the system tests.
        kubectl create clusterrolebinding add-on-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:default
        if [ $? -ne 0 ]
        then
            sleep 1
        else
            return 0
        fi
        i=$[$i+1]
    done

    return 1
}

function label_node {

    if [ "$TEST_CLUSTER" = "minikube" ]; then
        echo $(kubectl get nodes)
        kubectl label node minikube rack-key=zone
    fi
}

if [ "$TEST_CLUSTER" = "minikube" ]; then
    install_kubectl
    TEST_MINIKUBE_URL=https://storage.googleapis.com/minikube/releases/latest/minikube-linux-s390x
    TEST_MINIKUBE_URL=https://github.com/kubernetes/minikube/releases/download/${TEST_MINIKUBE_VERSION}/minikube-linux-s390x
    curl -Lo minikube ${TEST_MINIKUBE_URL} && chmod +x minikube
    sudo cp minikube /usr/bin

    export MINIKUBE_WANTUPDATENOTIFICATION=false
    export MINIKUBE_WANTREPORTERRORPROMPT=false
    export MINIKUBE_HOME=$HOME
    export CHANGE_MINIKUBE_NONE_USER=true
    
    mkdir $HOME/.kube || true
    touch $HOME/.kube/config

    export KUBECONFIG=$HOME/.kube/config
    sudo apt-get install linux-image-$(uname -r)
    sudo -E minikube start --kubernetes-version=v1.22.3 \
      --extra-config=apiserver.authorization-mode=RBAC \
      --vm-driver=none
    sudo chown -R travis: /home/travis/.minikube/
    sudo -E minikube addons enable default-storageclass

    wait_for_minikube

    if [ $? -ne 0 ]
    then
        echo "Minikube failed to start or RBAC could not be properly set up"
        exit 1
    fi
else
    echo "Unsupported TEST_CLUSTER '$TEST_CLUSTER'"
    exit 1
fi

if [ "$TRAVIS" = false ]; then
    label_node
fi
