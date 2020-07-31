#!/bin/sh

echo "Preparing sybase disk ..."
if [ -e /dev/disk/by-label/sybase ]; then
    echo "  disk already added, skipping"
    exit 0
fi

echo 'start=2048, type=83' | sudo sfdisk -q /dev/sdc # TODO improve device detection
sudo mkfs.ext4 -q -L sybase /dev/sdc1
echo "LABEL=sybase /sybase ext4 noatime 0 0" | sudo tee -a /etc/fstab
sudo mkdir /sybase
sudo mount /sybase
