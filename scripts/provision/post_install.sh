#!/bin/sh

# sh /vagrant/scripts/install_addons.sh

sudo -i -u npladm saplicense -get || true

echo "Installation sequence complete"
