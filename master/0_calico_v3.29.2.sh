#!/bin/bash
set -e

if [ ! -f /etc/kubernetes/admin.conf ]; then
  echo "Initiate Kubeadm First!"
  echo "Example: sudo kubeadm init --apiserver-advertise-address 'your-gateway-ip' --pod-network-cidr=192.168.0.0/16"
  exit 1
fi

echo "===0.Calico Installation==="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/custom-resources.yaml

echo "Check All Nodes are 'Running' before next steps."
echo "Example: watch kubectl get pods --namespace calico-system"
