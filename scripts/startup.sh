#!/bin/sh

# TODO check installed
# if [ -n "$(cat /etc/hosts | grep vhcalnplci.dummy.nodomain )" ]; then
#   echo "Seems the system configs already patched, skipping"
#   exit 0
# fi

echo "Local start/stopsap scripts..."
_VAGRANT_HOME=/home/vagrant
_VAGRANT_HOME_BIN=$_VAGRANT_HOME/.local/bin

mkdir -p $_VAGRANT_HOME_BIN
chown vagrant:vagrant $_VAGRANT_HOME_BIN
chmod 700 $_VAGRANT_HOME_BIN

cp /vagrant/scripts/startsap.sh $_VAGRANT_HOME_BIN
cp /vagrant/scripts/stopsap.sh $_VAGRANT_HOME_BIN
chmod 700 $_VAGRANT_HOME_BIN/startsap.sh
chmod 700 $_VAGRANT_HOME_BIN/stopsap.sh
chown vagrant:vagrant $_VAGRANT_HOME_BIN/startsap.sh
chown vagrant:vagrant $_VAGRANT_HOME_BIN/stopsap.sh
