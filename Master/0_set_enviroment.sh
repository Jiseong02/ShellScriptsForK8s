#!/bin/bash
set -e

echo "===0. Environment settings==="

echo "Disabling Swap."
cd /
sudo apt-get update
sudo swapoff -a
sudo sed -i '/\sswap\s/s/^/#/' /etc/fstab

swap_units=$(systemctl --type=swap --no-legend --all | awk '{print $1}')
for unit in $swap_units; do
  echo "Masking swap unit: $unit"
  sudo systemctl mask "$unit"
done

echo "Migrating Systemd to Cgroup v2 from Cgroup v1."
sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="systemd.unified_cgroup_hierarchy=1 /' /etc/default/grub
sudo update-grub

echo "After Rebooting machine. please execute the next process."
reboot
