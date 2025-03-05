#!/bin/bash

echo "1. System Package Updating"
sudo apt update && sudo apt upgrade -y

echo "2. ubuntu-drivers-common package installing"
sudo apt install -y ubuntu-drivers-common

echo "3. NVIDIA Driver Installation"
recommended_driver=$(sudo ubuntu-drivers devices | grep 'recommended' | grep -oP 'nvidia-driver-\K[0-9]+')

if [ -z "$recommended_driver" ]; then
    echo "No driver recommended!! Check sudo ubuntu-drivers devices"
    exit 1
fi

sudo apt install -y nvidia-driver-$recommended_driver

echo "After reboot, Proceed next steps."
sudo reboot now
