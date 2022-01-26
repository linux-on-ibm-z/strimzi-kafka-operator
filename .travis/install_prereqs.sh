#!/usr/bin/env bash

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata
sudo apt-get install -y apt-utils
sudo apt-get install -y git make cmake gcc-8 g++-8 tar wget patch ruby curl conntrack shellcheck openssl libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev libarchive-dev diffutils gzip file procps python3 perl zip apt-transport-https kubelet kubeadm kubectl
#sudo kubeadm reset
sudo kubeadm init phase certs all
sudo kubeadm init phase kubeconfig all
sudo kubeadm init phase control-plane all --pod-network-cidr=10.244.0.0/16
#sudo kubeadm init --v=1 --skip-phases=certs,kubeconfig,control-plane --ignore-preflight-errors=all --pod-network-cidr=10.244.0.0/16
#sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --v=5
sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-8 40
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 40
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 40
sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++-8 40
