#!/bin/bash
set -e

echo "===Kubernetes Components installation===" 

KUBERNETES_VERSION=v1.32
CRIO_VERSION=v1.32

echo "Enabling IPv4 packet forwarding."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

echo "Installing the dependencies for adding repositories"
apt-get update
apt-get install -y software-properties-common curl

echo "Adding the Kubernetes repository"
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "Add the CRI-O repository"
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list

echo "Now you can make kubeadm init or join clusters. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/"

echo "Installing the packages"
apt-get update
apt-get install -y cri-o kubelet kubeadm kubectl

systemctl start crio.service
