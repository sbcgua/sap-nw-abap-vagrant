#!/bin/sh

echo "Adding swap ..."
if [ -n "$(swapon --show)" ]; then
    echo "  swap is already activated, skipping"
    exit 0
fi

# Creating swap file
sudo fallocate -l 2G /swapfile # 2 gigabytes
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo "/swapfile none swap sw 0 0" | sudo tee -a /etc/fstab

# Tune system params
sudo sysctl vm.swappiness=10
sudo sysctl vm.vfs_cache_pressure=50
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
echo "vm.vfs_cache_pressure = 50" | sudo tee -a /etc/sysctl.conf
