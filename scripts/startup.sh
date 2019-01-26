#!/bin/sh

# TODO check installed
# if [ -n "$(cat /etc/hosts | grep vhcalnplci.dummy.nodomain )" ]; then
#   echo "Seems the system configs already patched, skipping"
#   exit 0
# fi

echo "Local start/stopsap scripts..."
_LOCAL_BIN=/usr/local/bin
cp /vagrant/scripts/startsap.sh $_LOCAL_BIN
cp /vagrant/scripts/stopsap.sh $_LOCAL_BIN
chmod 755 $_LOCAL_BIN/startsap.sh
chmod 755 $_LOCAL_BIN/stopsap.sh

echo "Installing service..."
_SERVICE_PATH=/etc/systemd/system/sapnw.service
cp /vagrant/scripts/sapnw.service /etc/systemd/system/
chmod 644 $_SERVICE_PATH
systemctl daemon-reload
systemctl enable sapnw
systemctl status sapnw --no-pager --full

# systemctl start sapnw
