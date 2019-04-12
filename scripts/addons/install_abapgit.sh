#!/bin/sh

if [ $(id -u) = '0' ]; then
    echo "[!] install_abapgit script must not be run from root"
    exit 1
fi

node -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "[!] Install nodejs before running this script"
    exit 1
fi

echo "Preparing to install abapgit ..."
cp -R /vagrant/abapdeploy.js ~/
cd ~/abapdeploy.js
npm -q install

echo "Downloading latest abapgit source ..."
curl -sS https://raw.githubusercontent.com/abapGit/build/master/zabapgit.abap -o /tmp/zabapgit.abap

echo "Installing abapgit ..."
export AD_IP=localhost
export AD_USER=developer
export AD_PASS=Down1oad
node abapdeploy.js -f /tmp/zabapgit.abap -p zabapgit_full
