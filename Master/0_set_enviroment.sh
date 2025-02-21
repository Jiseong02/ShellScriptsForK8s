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

echo "Please execute file "After-Reboot".
reboot
