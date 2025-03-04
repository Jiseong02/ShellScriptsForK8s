#!/bin/bash
set -e

echo "===Kubernetes Components installation===" 

echo "Enabling IPv4 packet forwarding."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

echo "Installing the dependencies for adding repositories."
apt-get update
apt-get install -y software-properties-common curl

echo "Adding the Kubernetes repository"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list

echo "Adding the CRI-O repository"
curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/v1.32/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/v1.32/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list

echo "Installing CRI-O, Kubelet, Kubeadm, Kubectl"
apt-get update
apt-get install -y cri-o
systemctl start crio.service
apt-get install -y cri-o kubelet kubeadm kubectl

sudo systemctl enable --now kubelet

echo "Now you can make kubeadm init or join clusters. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/"
