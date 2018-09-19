#!/bin/sh

echo "Installing SAP NW ..."
if [ ! -e /vagrant/distrib/install.sh ]; then
  echo "  install.sh NOT found, NW install failed, continue manually"
  exit 0
fi

if [ -e /sapmnt ]; then
  echo "  seems SAP is already installed, skipping"
  exit 0
fi

cd /vagrant/distrib
cp /vagrant/scripts/run-install.sh /tmp
chmod +x install.sh
chmod +x /tmp/run-install.sh

sudo /tmp/run-install.sh
rm /tmp/run-install.sh

# TODO remove wrong hosts lines
