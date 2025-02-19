#!/bin/bash
set -e

echo "===0. Environment settings==="

cd /
sudo apt-get update
sudo swapoff -a
sudo sed -i '/\sswap\s/s/^/#/' /etc/fstab

echo "Migrating Systemd to Cgroup v2 from Cgroup v1"
sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=1 /' /etc/default/grub
sudo update-grub
sudo umount /sys/fs/cgroup/systemd
sudo mount -t cgroup2 none /sys/fs/cgroup/systemd
sudo systemctl daemon-reexec

echo "===1. Container runtime installation===" 

echo "Enabling IPv4 packet forwarding."
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF
sudo sysctl --system

echo "Installing containerd."
wget https://github.com/containerd/containerd/releases/download/v2.0.2/containerd-2.0.2-linux-amd64.tar.gz
tar Cxzvf /usr/local containerd-2.0.2-linux-amd64.tar.gz
rm containerd-2.0.2-linux-amd64.tar.gz

echo "Enabling containerd service."
wget -P /lib/systemd/system https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
systemctl daemon-reload
systemctl enable --now containerd

echo "Installing runc."
wget https://github.com/opencontainers/runc/releases/download/v1.2.5/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc
rm runc.amd64

echo "Installing CNI plugins."
wget https://github.com/containernetworking/plugins/releases/download/v1.6.2/cni-plugins-linux-amd64-v1.6.2.tgz
mkdir -p /opt/cni/bin
tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.6.2.tgz
rm cni-plugins-linux-amd64-v1.6.2.tgz

echo "===2. Kubernetes installation==="

echo "Installing kubelet and kubeadm and kubectl."
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Initiating kubeadm"
sudo systemctl enable --now kubelet
kubeadm init
export KUBECONFIG=/etc/kubernetes/admin.conf
