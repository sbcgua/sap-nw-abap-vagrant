#!/bin/sh

_LOCAL_BIN=/usr/local/bin
_SERVICE_PATH=/etc/systemd/system/sapnw.service

if [ ! -e $_LOCAL_BIN/startsap.sh ]; then
    echo "Local start/stopsap scripts..."
    cp /vagrant/scripts/bin/startsap.sh $_LOCAL_BIN
    cp /vagrant/scripts/bin/stopsap.sh $_LOCAL_BIN
    chmod 755 $_LOCAL_BIN/startsap.sh
    chmod 755 $_LOCAL_BIN/stopsap.sh
fi

if [ -e /usr/sap/NPL/D00/exe/sapstart ] && [ ! -e $_SERVICE_PATH ]; then
    echo "Installing NW service..."
    cp /vagrant/scripts/service/sapnw.service /etc/systemd/system/
    chmod 644 $_SERVICE_PATH
    systemctl daemon-reload
    systemctl enable sapnw
    systemctl status sapnw --no-pager --full || true
    # systemctl start sapnw
fi
