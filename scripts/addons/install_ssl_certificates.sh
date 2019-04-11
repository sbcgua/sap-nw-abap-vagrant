#!/bin/sh

if [ $(id -u) = '0' ]; then
    echo "[!] SSL certificate installation script must not be run from root"
    exit 1
fi

node -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[!] Install nodejs before running this script"
    exit 1
fi

if [ -z "$(cat /home/vagrant/.bashrc | grep /usr/sap/NPL/D00/exe/)" ]; then
    echo "" >> /home/vagrant/.bashrc
    echo "# Path to SAP libs" >> /home/vagrant/.bashrc
    echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/sap/NPL/D00/exe/" >> /home/vagrant/.bashrc
fi

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/sap/NPL/D00/exe/

echo "Preparing to install certificates ..."
cp -R /vagrant/certinst.js ~/
cd ~/certinst.js
npm -q install

# echo "Certificates installed:" `node certinst.js list -s`
echo "Testing connection ..."
node certinst.js test
echo

echo "Installing certificates..."
node certinst.js install
echo

echo "List certificates ..."
node certinst.js list
echo
