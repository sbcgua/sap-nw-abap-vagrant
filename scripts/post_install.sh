#!/bin/sh

node -v > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Installing nodejs for further scripting..."
    sudo apt-get install -y -q nodejs
fi

echo "Nodejs installed:" `node -v`

if [ -z "$(cat /home/vagrant/.bashrc | grep /usr/sap/NPL/D00/exe/)" ]; then
  echo "" >> /home/vagrant/.bashrc
  echo "# Path to SAP libs" >> /home/vagrant/.bashrc
  echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/usr/sap/NPL/D00/exe/" >> /home/vagrant/.bashrc
fi

# Install SSL certificates
cp /vagrant/scripts/install_ssl_certificates.sh /tmp
chmod +x /tmp/install_ssl_certificates.sh
sudo -i -u vagrant /tmp/install_ssl_certificates.sh
