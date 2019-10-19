#!/bin/sh

# Timestamp
date +%s > /tmp/provision-start.timestamp

# Check if executed before
if [ -n "$(cat /etc/hosts | grep vhcalnplci.dummy.nodomain )" ]; then
    echo "Seems the system configs already patched, skipping"
    exit 0
fi

# Start system configurations
echo "Patching /etc/hosts ..."
echo "10.0.2.15 vhcalnplci vhcalnplci.dummy.nodomain" | sudo tee -a /etc/hosts
sudo sed -i.bak '/127.*vhcalnplci/d' /etc/hosts

echo "Enabling uuidd ..."
sudo systemctl enable uuidd.service
sudo service uuidd start

echo "Installing packages (mc, csh, etc) ..."
sudo apt-get -q update
sudo apt-get -y -q --no-install-recommends install mc csh libaio1 unrar expect
# + libstdc++6 ?

echo "Setting timezone to CET and enabling auto time adjutsments ..."
sudo unlink /etc/localtime
sudo ln -s /usr/share/zoneinfo/CET /etc/localtime
sudo timedatectl set-ntp on
