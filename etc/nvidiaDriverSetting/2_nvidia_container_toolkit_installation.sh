#!/bin/bash
set -e

if ! command -v nvidia-smi &> /dev/null
then 
  echo "You have to install Cuda first!!! Check https://docs.nvidia.com/cuda/cuda-installation-guide-linux/"
  return 1;
fi

echo "===Nvidia container toolkit Installation==="
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit

sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker

while ! systemctl is-active --quiet docker; do
    sleep 1
done

sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi

sudo docker run --rm --gpus all ubuntu:18.04 nvidia-smi
