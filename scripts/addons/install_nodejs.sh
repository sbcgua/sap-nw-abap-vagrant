#!/bin/sh

node -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Installing nodejs for further scripting..."
    # Adding nodejs source for after-installation scripts
    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
    sudo apt-get install -y -q nodejs
    echo "Nodejs installed:" `node -v`
else
    echo "Nodejs detected:" `node -v`
fi
