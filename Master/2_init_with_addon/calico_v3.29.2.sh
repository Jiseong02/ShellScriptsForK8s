#!/bin/bash
set -e

echo "===0.Calico Installation==="
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/tigera-operator.yaml
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.2/manifests/custom-resources.yaml

echo "Waiting for all pods in all namespaces to be in 'Running' state."
kubectl get pods --all-namespaces
MAX_RETRIES=60 
SLEEP_INTERVAL=5 
RETRY_COUNT=0
while [ "$RETRY_COUNT" -lt "$MAX_RETRIES" ]; do
  NOT_READY_COUNT=$(kubectl get pods -n calico-system | grep -v "Running" | wc -l)
  if [ "$NOT_READY_COUNT" -eq 0 ]; then
    break
  else
    sleep "$SLEEP_INTERVAL"
    ((RETRY_COUNT++))
  fi
done
if [ "$NOT_READY_COUNT" -ne 0 ]; then
  echo "Timeout: Pods did not reach 'Running' state within the expected time."
  exit 1
fi
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl get nodes -o wide
