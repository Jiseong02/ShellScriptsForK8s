#!/bin/bash
set -e

echo "===1. Container runtime installation===" 

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

echo "Installing CRI-O"
apt-get update
apt-get install -y cri-o
systemctl start crio.service

echo "Installing runc."
wget https://github.com/opencontainers/runc/releases/download/v1.2.5/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
rm runc.amd64

echo "Installing CNI plugins."
wget https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.6.2.tgz
rm cni-plugins-linux-amd64-v1.6.2.tgz

echo "===2. Kubernetes Components installation==="

echo "Installing kubelet and kubeadm and kubectl."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
sudo systemctl enable --now kubelet

echo "Now you can make kubeadm init or join clusters. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/"
