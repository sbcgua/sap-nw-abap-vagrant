#!/bin/sh

node -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Installing nodejs for further scripting..."
    sudo apt-get install -y nodejs
fi

echo "Nodejs installed"

export LD_LIBRARY_PATH=/usr/sap/NPL/D00/exe/


