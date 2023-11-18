#!/bin/env bash

if [ $# -eq 0 ]; then
    echo "Error: Enter size for swapfile"
    exit 1
fi

# Grab swap size from passed in argument
swapSize="$1"

# Create/Activate swapfile and add to fstab file
sudo fallocate -l ${swapSize}G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Grab UUID and offset of swapfile
UUID=$(findmnt -no UUID -T /swapfile)
offset=$(sudo filefrag -v /swapfile | awk '{ if($1=="0:"){print $4} }' | sed 's/\.$//' | sed 's/\.$//')

# Kernel stub
sudo kernelstub -a "resume=UUID=$UUID resume_offset=$offset"

# Add following line to file
mkdir -p /etc/initramfs-tools/conf.d
sudo touch /etc/initramfs-tools/conf.d/resume
echo "resume=UUID=$UUID resume_offset=$offset" | sudo tee /etc/initramfs-tools/conf.d/resume

# Update the configurations
sudo update-initramfs -u
