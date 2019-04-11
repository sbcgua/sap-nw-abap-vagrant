#!/bin/sh

# Install nodejs
sh /vagrant/scripts/addons/install_nodejs.sh

# Install SSL certificates
sudo -i -u vagrant /vagrant/scripts/addons/install_ssl_certificates.sh
