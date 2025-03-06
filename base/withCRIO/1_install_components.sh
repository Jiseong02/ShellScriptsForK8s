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

echo "Loading necessary kernel modules and setting sysctl parameters."
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

echo "Installing the dependencies for adding repositories"
sudo apt-get update
sudo apt-get install -y software-properties-common curl

echo "Adding the Kubernetes repository"
curl -fsSL https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$KUBERNETES_VERSION/deb/ /" |
    sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "Adding the CRI-O repository"
OS=xUbuntu_$(lsb_release -rs)
echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /" |
    sudo tee /etc/apt/sources.list.d/cri-o.list

curl -fsSL https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "Installing the packages"
sudo apt-get update
sudo apt-get install -y cri-o cri-o-runc kubelet kubeadm kubectl

echo "Starting and enabling CRI-O service"
sudo systemctl daemon-reload
sudo systemctl enable crio --now

echo "Now you can make kubeadm init or join clusters. https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/"
