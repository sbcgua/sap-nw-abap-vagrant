#!/bin/sh

cd /vagrant/
if [ -n "$(cat distrib/install.sh | grep 'SYBASE LICENSE COPY' )" ]; then
    echo "Seems the system configs already patched, skipping"
    exit 0
fi

patch distrib/install.sh patch.install.sh.diff
