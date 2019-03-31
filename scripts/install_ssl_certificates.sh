#!/bin/sh

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/sap/NPL/D00/exe/

echo "Preparing to install certificates ..."
cp -R /vagrant/certinst.js ~/
cd ~/certinst.js
npm install

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
